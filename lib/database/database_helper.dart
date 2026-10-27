import 'dart:convert';
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
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onOpen: (db) async {
        await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL DEFAULT '0'
      )
    ''');
      },
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          icon TEXT NOT NULL DEFAULT ''
        )''');
        await db.execute('''CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          amount INTEGER NOT NULL CHECK(amount > 0),
          type TEXT NOT NULL,
          date TEXT NOT NULL,
          note TEXT DEFAULT '',
          FOREIGN KEY(category_id) REFERENCES categories(id)
        )''');
        await db.execute('CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final cols = await db.rawQuery('PRAGMA table_info(categories)');
          if (!cols.any((c) => c['name'] == 'icon')) {
            await db.execute("ALTER TABLE categories ADD COLUMN icon TEXT NOT NULL DEFAULT ''");
          }
          await db.execute('CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
        }
      },
    );
  }

  Future<void> ensureCategories() async {
    final db = await database;
    const defaults = <Map<String, String>>[
      {'name': 'Ăn uống', 'type': 'Chi tiêu', 'icon': 'restaurant'},
      {'name': 'Mua sắm', 'type': 'Chi tiêu', 'icon': 'shopping_bag'},
      {'name': 'Di chuyển', 'type': 'Chi tiêu', 'icon': 'directions_car'},
      {'name': 'Giải trí', 'type': 'Chi tiêu', 'icon': 'movie'},
      {'name': 'Học phí', 'type': 'Chi tiêu', 'icon': 'school'},
      {'name': 'Hóa đơn', 'type': 'Chi tiêu', 'icon': 'receipt'},
      {'name': 'Khác', 'type': 'Chi tiêu', 'icon': 'category'},
      {'name': 'Lương', 'type': 'Thu nhập', 'icon': 'payments'},
      {'name': 'Thưởng', 'type': 'Thu nhập', 'icon': 'paid'},
      {'name': 'Làm thêm', 'type': 'Thu nhập', 'icon': 'work'},
      {'name': 'Khác', 'type': 'Thu nhập', 'icon': 'category'},
    ];
    await db.transaction((txn) async {
      for (final item in defaults) {
        final rows = await txn.query('categories', columns: ['id'],
          where: 'name = ? AND type = ?', whereArgs: [item['name'], item['type']], limit: 1);
        if (rows.isEmpty) await txn.insert('categories', item);
      }
    });
  }

  Future<List<Map<String, Object?>>> getCategories(String type) async {
    final db = await database;
    return db.query('categories', where: 'type = ?', whereArgs: [type], orderBy: 'id ASC');
  }

  Future<int> addCategory(String name, String type) async {
    final db = await database;
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('Tên danh mục không được trống');
    final existing = await db.query('categories', where: 'name = ? AND type = ?',
        whereArgs: [clean, type], limit: 1);
    if (existing.isNotEmpty) throw StateError('Danh mục đã tồn tại');
    return db.insert('categories', {'name': clean, 'type': type, 'icon': 'category'});
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM transactions WHERE category_id = ?', [id])) ?? 0;
    if (count > 0) throw StateError('Danh mục đang có giao dịch, không thể xóa');
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getTransactions() async {
    final db = await database;
    return db.rawQuery('''SELECT t.*, c.name AS category_name
      FROM transactions t LEFT JOIN categories c ON c.id = t.category_id
      ORDER BY t.date DESC, t.id DESC''');
  }

  Future<Map<String, Object?>?> getTransactionById(int id) async {
    final db = await database;
    final rows = await db.query('transactions', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, int>> getSummary() async {
    final db = await database;
    final rows = await db.rawQuery('''SELECT
      COALESCE(SUM(CASE WHEN type = 'Thu nhập' THEN amount ELSE 0 END), 0) AS income,
      COALESCE(SUM(CASE WHEN type = 'Chi tiêu' THEN amount ELSE 0 END), 0) AS expense
      FROM transactions''');
    final income = (rows.first['income'] as num).toInt();
    final expense = (rows.first['expense'] as num).toInt();
    return {'income': income, 'expense': expense, 'balance': income - expense};
  }

  String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _checkCategory(Database db, int id, String type) async {
    final rows = await db.query('categories', columns: ['id'],
      where: 'id = ? AND type = ?', whereArgs: [id, type], limit: 1);
    if (rows.isEmpty) throw ArgumentError('Danh mục không phù hợp với loại giao dịch');
  }

  Future<int> insertTransaction({required int categoryId, required int amount,
      required String type, required DateTime date, String note = ''}) async {
    if (amount <= 0) throw ArgumentError('Số tiền phải lớn hơn 0');
    final db = await database;
    await _checkCategory(db, categoryId, type);
    return db.insert('transactions', {'category_id': categoryId, 'amount': amount,
      'type': type, 'date': _date(date), 'note': note});
  }

  Future<int> updateTransaction({required int id, required int categoryId,
      required int amount, required String type, required DateTime date, String note = ''}) async {
    if (amount <= 0) throw ArgumentError('Số tiền phải lớn hơn 0');
    final db = await database;
    await _checkCategory(db, categoryId, type);
    return db.update('transactions', {'category_id': categoryId, 'amount': amount,
      'type': type, 'date': _date(date), 'note': note}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> _total(String type) async {
    final db = await database;
    final rows = await db.rawQuery('SELECT COALESCE(SUM(amount), 0) AS total FROM transactions WHERE type = ?', [type]);
    return (rows.first['total'] as num).toInt();
  }
  Future<int> getTotalIncome() => _total('Thu nhập');
  Future<int> getTotalExpense() => _total('Chi tiêu');
  Future<int> getBalance() async => await getTotalIncome() - await getTotalExpense();

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query('settings', where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String> exportBackupJson() async {
    final db = await database;
    return const JsonEncoder.withIndent('  ').convert({
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': await db.query('categories'),
      'transactions': await db.query('transactions'),
      'settings': await db.query('settings'),
    });
  }
}
