import 'package:flutter/foundation.dart';
import '../../core/models/cart_model.dart';

class CartController extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  double _deliveryFee = 2.50;

  List<CartItemModel> get items => List.unmodifiable(_items);
  double get deliveryFee => _deliveryFee;

  int get totalCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get grandTotal {
    if (_items.isEmpty) return 0.0;
    return subtotal + _deliveryFee;
  }

  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    notifyListeners();
  }

  void addItem(CartItemModel newItem) {
    final existingIndex = _items.indexWhere(
      (item) => item.foodId == newItem.foodId && item.selectedVariationTitle == newItem.selectedVariationTitle,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += newItem.quantity;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void incrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
