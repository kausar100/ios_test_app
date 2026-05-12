import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/isar_service.dart';
import '../../data/models/cart_item.dart';

final isarServiceProvider = Provider((ref) => IsarService());

final cartItemsProvider = StreamProvider<List<CartItem>>((ref) {
  return ref.watch(isarServiceProvider).watchCartItems();
});

class CartNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> addItem(CartItem item) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(isarServiceProvider).addToCart(item);
    });
  }

  Future<void> updateQuantity(int id, int quantity) async {
    await ref.read(isarServiceProvider).updateQuantity(id, quantity);
  }

  Future<void> deleteItem(int id) async {
    await ref.read(isarServiceProvider).deleteCartItem(id);
  }

  Future<void> clearCart() async {
    await ref.read(isarServiceProvider).clearCart();
  }
}

final cartNotifierProvider = AsyncNotifierProvider<CartNotifier, void>(() {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartItemsProvider).value ?? [];
  return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
});
