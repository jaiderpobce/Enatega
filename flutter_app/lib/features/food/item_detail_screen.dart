import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/cart_model.dart';
import '../../core/theme/app_theme.dart';
import '../cart/cart_controller.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({
    super.key,
    required this.foodData,
  });

  final Map<String, dynamic> foodData;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final food = widget.foodData;
    final title = food['title']?.toString() ?? 'Platillo';
    final description = food['description']?.toString() ?? 'Sin descripción disponible.';
    final imgUrl = food['img_url']?.toString();
    final price = (food['price'] as num?)?.toDouble() ?? 9.99;
    final totalPrice = price * _quantity;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (imgUrl != null && imgUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imgUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.fastfood, size: 64, color: AppTheme.primary),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${price.toStringAsFixed(2)} c/u',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              label: Text(
                'Agregar al Carrito • \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              onPressed: () {
                final cartItem = CartItemModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  foodId: food['_id']?.toString() ?? '',
                  title: title,
                  price: price,
                  imgUrl: imgUrl,
                  quantity: _quantity,
                );

                context.read<CartController>().addItem(cartItem);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title agregado al carrito!'),
                    backgroundColor: AppTheme.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
