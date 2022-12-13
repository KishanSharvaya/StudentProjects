import 'package:path/path.dart';
import 'package:soleoserp/models/DB_Models/productdetails.dart';
import 'package:sqflite/sqflite.dart';

class OfflineDbHelper {
  static OfflineDbHelper _offlineDbHelper;
  static Database database;

  static const TABLE_PRODUCT_CART = "product_cart";

  static createInstance() async {
    _offlineDbHelper = OfflineDbHelper();
    database = await openDatabase(
        join(await getDatabasesPath(), 'grocery_shop_database.db'),
        onCreate: (db, version) => _createDb(db),
        version: 1);
  }

  static void _createDb(Database db) {
    String ProductName, Unit, LoginUserID;
/*

int id;
  int ProductID;
  double Quantity, Amount, NetAmount;
  String ProductName, ProductImage;
*/
    db.execute(
      'CREATE TABLE $TABLE_PRODUCT_CART(id INTEGER PRIMARY KEY AUTOINCREMENT, ProductID INTEGER,Quantity DOUBLE, Amount DOUBLE, NetAmount DOUBLE , ProductName TEXT, ProductImage TEXT)',
    );
  }

  static OfflineDbHelper getInstance() {
    return _offlineDbHelper;
  }

  ///Here Customer Contact Table Implimentation

  Future<int> insertProductToCart(ProductCartModel model) async {
    final db = await database;

    return await db.insert(
      TABLE_PRODUCT_CART,
      model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProductCartModel>> getProductCartList() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(TABLE_PRODUCT_CART);

    return List.generate(maps.length, (i) {
      return ProductCartModel(
        maps[i]['ProductID'],
        maps[i]['Quantity'],
        maps[i]['Amount'],
        maps[i]['NetAmount'],
        maps[i]['ProductName'],
        maps[i]['ProductImage'],
        id: maps[i]['id'],
      );
    });
  }

  Future<void> updateContact(ProductCartModel model) async {
    final db = await database;

    await db.update(
      TABLE_PRODUCT_CART,
      model.toJson(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> deleteContact(int id) async {
    final db = await database;

    await db.delete(
      TABLE_PRODUCT_CART,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteContactTable() async {
    final db = await database;

    await db.delete(TABLE_PRODUCT_CART);
  }
}
