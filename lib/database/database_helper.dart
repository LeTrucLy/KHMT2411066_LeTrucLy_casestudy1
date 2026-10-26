import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;

  Future<Database> get database async => _database ??= await _open();

  Future<Database> _open() async {
    final dbPath = join(await getDatabasesPath(), 'expense_manager.db');
    return openDatabase(
      dbPath,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            icon TEXT NOT NULL DEFAULT ''
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_id INTEGER NOT NULL,
            amount INTEGER NOT NULL CHECK(amount > 0),
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            note TEXT DEFAULT '',
            FOREIGN KEY (category_id) REFERENCES categories(id)
          )
        ''');
      },

    // Thêm đoạn này để nâng cấp database
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        final columns = await db.rawQuery(
          'PRAGMA table_info(categories)',
        );

        final hasIcon = columns.any(
          (column) => column['name'] == 'icon',
        );

        if (!hasIcon) {
          await db.execute(
            "ALTER TABLE categories ADD COLUMN icon TEXT NOT NULL DEFAULT ''",
          );
        }
      }
    },

  );
}

  Future<Map<String, int>> getSummary() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN type = 'Thu nhập' THEN amount ELSE 0 END), 0) AS income,
        COALESCE(SUM(CASE WHEN type = 'Chi tiêu' THEN amount ELSE 0 END), 0) AS expense
      FROM transactions
    ''');
    final income = (rows.first['income'] as num).toInt();
    final expense = (rows.first['expense'] as num).toInt();
    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  Future<void> ensureCategories() async {
    final db = await database;
    const defaults = <Map<String, String>>[
      {'name': 'Ăn uống', 'type': 'Chi tiêu', 'icon': 'restaurant'},
      {'name': 'Mua sắm', 'type': 'Chi tiêu', 'icon': 'shopping_bag'},
      {'name': 'Di chuyển', 'type': 'Chi tiêu', 'icon': 'directions_car'},
      {'name': 'Giải trí', 'type': 'Chi tiêu', 'icon': 'movie'},
      {'name': 'Học phí', 'type': 'Chi tiêu', 'icon': 'school'},
      {'name': 'Khác', 'type': 'Chi tiêu', 'icon': 'category'},
      {'name': 'Lương', 'type': 'Thu nhập', 'icon': 'payments'},
      {'name': 'Thưởng', 'type': 'Thu nhập', 'icon': 'paid'},
      {'name': 'Khác', 'type': 'Thu nhập', 'icon': 'category'},
    ];
    for (final item in defaults) {
      final found = await db.query(
        'categories',
        columns: ['id'],
        where: 'name = ? AND type = ?',
        whereArgs: [item['name'], item['type']],
        limit: 1,
      );
      if (found.isEmpty) {
        await db.insert('categories', item);
      }
    }
  }

  Future<List<Map<String, Object?>>> getCategories(String type) async {
    final db = await database;
    return db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'id ASC',
    );
  }

  Future<List<Map<String, Object?>>> getTransactions() async {
    final db = await database;
    return db.rawQuery('''
      SELECT t.*, c.name AS category_name
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.category_id
      ORDER BY t.date DESC, t.id DESC
    ''');
  }

  Future<Map<String, Object?>?> getTransactionById(int id) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _checkCategory(Database db, int id, String type) async {
    final rows = await db.query(
      'categories',
      columns: ['id'],
      where: 'id = ? AND type = ?',
      whereArgs: [id, type],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw ArgumentError('Danh mục không phù hợp với loại giao dịch');
    }
  }

  Future<int> insertTransaction({
    required int categoryId,
    required int amount,
    required String type,
    required DateTime date,
    String note = '',
  }) async {
    if (amount <= 0) throw ArgumentError('Số tiền phải lớn hơn 0');
    final db = await database;
    await _checkCategory(db, categoryId, type);
    return db.insert('transactions', {
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'date': _date(date),
      'note': note,
    });
  }

  Future<int> updateTransaction({
    required int id,
    required int categoryId,
    required int amount,
    required String type,
    required DateTime date,
    String note = '',
  }) async {
    if (amount <= 0) throw ArgumentError('Số tiền phải lớn hơn 0');
    final db = await database;
    await _checkCategory(db, categoryId, type);
    return db.update(
      'transactions',
      {
        'category_id': categoryId,
        'amount': amount,
        'type': type,
        'date': _date(date),
        'note': note,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> _total(String type) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total '
      'FROM transactions WHERE type = ?',
      [type],
    );
    return (rows.first['total'] as num).toInt();
  }

  Future<int> getTotalIncome() => _total('Thu nhập');
  Future<int> getTotalExpense() => _total('Chi tiêu');
  Future<int> getBalance() async =>
      await getTotalIncome() - await getTotalExpense();
}
