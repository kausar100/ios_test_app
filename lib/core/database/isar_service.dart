import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/cart/data/models/cart_item.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [CartItemSchema],
        directory: dir.path,
      );
    }
    return Isar.getInstance()!;
  }

  Future<void> addToCart(CartItem newItem) async {
    final isar = await db;
    final existingItem = await isar.cartItems
        .filter()
        .productIdEqualTo(newItem.productId)
        .findFirst();

    await isar.writeTxn(() async {
      if (existingItem != null) {
        existingItem.quantity += newItem.quantity;
        await isar.cartItems.put(existingItem);
      } else {
        await isar.cartItems.put(newItem);
      }
    });
  }

  Future<List<CartItem>> getAllCartItems() async {
    final isar = await db;
    return await isar.cartItems.where().findAll();
  }

  Future<void> updateQuantity(int id, int quantity) async {
    final isar = await db;
    final item = await isar.cartItems.get(id);
    if (item != null) {
      if (quantity <= 0) {
        await isar.writeTxn(() => isar.cartItems.delete(id));
      } else {
        item.quantity = quantity;
        await isar.writeTxn(() => isar.cartItems.put(item));
      }
    }
  }

  Future<void> deleteCartItem(int id) async {
    final isar = await db;
    await isar.writeTxn(() => isar.cartItems.delete(id));
  }

  Future<void> clearCart() async {
    final isar = await db;
    await isar.writeTxn(() => isar.cartItems.clear());
  }

  Stream<List<CartItem>> watchCartItems() async* {
    final isar = await db;
    yield* isar.cartItems.where().watch(fireImmediately: true);
  }
}
