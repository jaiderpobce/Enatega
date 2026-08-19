class CartItemModel {
  CartItemModel({
    required this.id,
    required this.foodId,
    required this.title,
    required this.price,
    this.imgUrl,
    this.quantity = 1,
    this.selectedVariationTitle,
  });

  final String id;
  final String foodId;
  final String title;
  final double price;
  final String? imgUrl;
  int quantity;
  final String? selectedVariationTitle;

  double get totalPrice => price * quantity;

  CartItemModel copyWith({
    String? id,
    String? foodId,
    String? title,
    double? price,
    String? imgUrl,
    int? quantity,
    String? selectedVariationTitle,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      title: title ?? this.title,
      price: price ?? this.price,
      imgUrl: imgUrl ?? this.imgUrl,
      quantity: quantity ?? this.quantity,
      selectedVariationTitle: selectedVariationTitle ?? this.selectedVariationTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'title': title,
      'price': price,
      'imgUrl': imgUrl,
      'quantity': quantity,
      'selectedVariationTitle': selectedVariationTitle,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      foodId: json['foodId'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      imgUrl: json['imgUrl'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      selectedVariationTitle: json['selectedVariationTitle'] as String?,
    );
  }
}
