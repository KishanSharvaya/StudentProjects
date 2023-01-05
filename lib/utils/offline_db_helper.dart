import 'package:path/path.dart';
import 'package:soleoserp/models/common/inquiry_product_model.dart';
import 'package:sqflite/sqflite.dart';

class OfflineDbHelper {
  static OfflineDbHelper _offlineDbHelper;
  static Database database;

  static const TABLE_PRODUCT_CART = "product_cart";
  static const TABLE_INQUIRY_PRODUCT = "inquiry_product";

  static createInstance() async {
    _offlineDbHelper = OfflineDbHelper();
    database = await openDatabase(
        join(await getDatabasesPath(), 'grocery_shop_database.db'),
        onCreate: (db, version) => _createDb(db),
        version: 2);
  }

  static void _createDb(Database db) {
    String ProductName, Unit, LoginUserID;

    db.execute(
      'CREATE TABLE $TABLE_PRODUCT_CART(id INTEGER PRIMARY KEY AUTOINCREMENT, ProductID INTEGER,Quantity DOUBLE, Amount DOUBLE, NetAmount DOUBLE , ProductName TEXT, ProductImage TEXT)',
    );
    db.execute(
      'CREATE TABLE $TABLE_INQUIRY_PRODUCT(id INTEGER PRIMARY KEY AUTOINCREMENT, InquiryNo TEXT,LoginUserID TEXT, CompanyId TEXT, ProductName TEXT, ProductID TEXT, Quantity TEXT, UnitPrice TEXT,TotalAmount TEXT)',
    );
  }

  static OfflineDbHelper getInstance() {
    return _offlineDbHelper;
  }

  ///Here InquiryProduct Table Implimentation

  Future<int> insertInquiryProduct(InquiryProductModel model) async {
    final db = await database;

    return await db.insert(
      TABLE_INQUIRY_PRODUCT,
      model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<InquiryProductModel>> getInquiryProduct() async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query(TABLE_INQUIRY_PRODUCT);

    return List.generate(maps.length, (i) {
      return InquiryProductModel(
        maps[i]['InquiryNo'],
        maps[i]['LoginUserID'],
        maps[i]['CompanyId'],
        maps[i]['ProductName'],
        maps[i]['ProductID'],
        maps[i]['Quantity'],
        maps[i]['UnitPrice'],
        maps[i]['TotalAmount'],
        id: maps[i]['id'],
      );
    });
  }

  Future<void> updateInquiryProduct(InquiryProductModel model) async {
    final db = await database;

    await db.update(
      TABLE_INQUIRY_PRODUCT,
      model.toJson(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> deleteInquiryProduct(int id) async {
    final db = await database;

    await db.delete(
      TABLE_INQUIRY_PRODUCT,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteALLInquiryProduct() async {
    final db = await database;

    await db.delete(TABLE_INQUIRY_PRODUCT);
  }
}
