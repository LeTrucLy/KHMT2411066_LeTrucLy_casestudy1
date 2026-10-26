
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_manager.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            amount REAL NOT NULL CHECK(amount > 0),
            date TEXT NOT NULL,
            note TEXT,
            FOREIGN KEY (category_id)
              REFERENCES categories(id)
          )
        ''');

        final categories = [
          {'name': 'Ăn uống', 'type': 'expense'},
          {'name': 'Mua sắm', 'type': 'expense'},
          {'name': 'Di chuyển', 'type': 'expense'},
          {'name': 'Giải trí', 'type': 'expense'},
          {'name': 'Khác', 'type': 'expense'},
          {'name': 'Lương', 'type': 'income'},
          {'name': 'Thưởng', 'type': 'income'},
          {'name': 'Khác', 'type': 'income'},
        ];

        for (final category in categories) {
          await db.insert('categories', category);
        }
      },
    );
  }

  // Lấy danh sách danh mục
  Future<List<Map<String, dynamic>>> getCategories({
    String? type,
  }) async {
    final db = await database;

    return db.query(
      'categories',
      where: type == null ? null : 'type = ?',
      whereArgs: type == null ? null : [type],
      orderBy: 'id ASC',
    );
  }

  // Thêm giao dịch
  Future<int> insertTransaction({
    required int categoryId,
    required String type,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final db = await database;

    return db.insert('transactions', {
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    });
  }

  // Lấy danh sách giao dịch
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;

    return db.rawQuery('''
      SELECT
        t.id,
        t.category_id,
        t.type,
        t.amount,
        t.date,
        t.note,
        c.name AS category_name
      FROM transactions t
      INNER JOIN categories c
        ON t.category_id = c.id
      ORDER BY t.date DESC, t.id DESC
    ''');
  }

  // Sửa giao dịch
  Future<int> updateTransaction({
    required int id,
    required int categoryId,
    required String type,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final db = await database;

    return db.update(
      'transactions',
      {
        'category_id': categoryId,
        'type': type,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Xóa giao dịch
  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tính tổng thu nhập hoặc chi tiêu
  Future<double> getTotalByType(String type) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) AS total
      FROM transactions
      WHERE type = ?
      ''',
      [type],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
