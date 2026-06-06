import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../search/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'package:uuid/uuid.dart';

class CartState {
  final List<CartItemEntity> items;

  const CartState({this.items = const []});

  double get subtotalMru =>
      items.fold(0, (sum, item) => sum + (item.product.price * 37.0 * item.quantity));

  double get totalShippingMru =>
      items.fold(0, (sum, item) => sum + ((item.shippingFeeMru ?? 0) * item.quantity));

  double get totalServiceMru =>
      items.fold(0, (sum, item) => sum + ((item.serviceFeeMru ?? 0) * item.quantity));

  double get totalMru => subtotalMru + totalShippingMru + totalServiceMru;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItemEntity>? items}) =>
      CartState(items: items ?? this.items);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(ProductEntity product, {int quantity = 1}) {
    final existing = state.items.indexWhere(
      (i) => i.product.url == product.url,
    );
    if (existing >= 0) {
      final updated = state.items[existing].copyWith(
        quantity: state.items[existing].quantity + quantity,
      );
      final items = [...state.items];
      items[existing] = updated;
      state = state.copyWith(items: items);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItemEntity(
            id: const Uuid().v4(),
            product: product,
            quantity: quantity,
          ),
        ],
      );
    }
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != itemId).toList(),
    );
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }
    state = state.copyWith(
      items: state.items
          .map((i) => i.id == itemId ? i.copyWith(quantity: quantity) : i)
          .toList(),
    );
  }

  void clear() => state = const CartState();
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});
