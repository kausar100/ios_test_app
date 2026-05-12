import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/isar_service.dart';
import '../../data/models/cart_item.dart';

final isarServiceProvider = Provider((ref) => IsarService());

final cartItemsProvider = StreamProvider<List<CartItem>>((ref) {
  return ref.watch(isarServiceProvider).watchCartItems();
});

class CartNotifier extends StateNotifier<AsyncValue<void>> {
  final IsarService _isarService;

  CartNotifier(this._isarService) : super(const AsyncValue.data(null));

  Future<void> addItem(CartItem item) async {
    state = const AsyncValue.loading();
    try {
      await _isarService.addToCart(item);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateQuantity(int id, int quantity) async {
    await _isarService.updateQuantity(id, quantity);
  }

  Future<void> deleteItem(int id) async {
    await _isarService.deleteCartItem(id);
  }

  Future<void> clearCart() async {
    await _isarService.clearCart();
  }
}

final cartNotifierProvider = StateNotifierProvider<CartNotifier, AsyncValue<void>>((ref) {
  return CartNotifier(ref.watch(isarServiceProvider));
});

final cartTotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartItemsProvider).value ?? [];
  return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
});
