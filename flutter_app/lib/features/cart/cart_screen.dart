import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import 'cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        centerTitle: true,
      ),
      body: Consumer<CartController>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Tu carrito está vacío',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explora el menú y agrega deliciosos platillos.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Explorar Menú'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: (item.imgUrl != null && item.imgUrl!.isNotEmpty)
                              ? Image.network(
                                  item.imgUrl!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 70,
                                    height: 70,
                                    color: AppTheme.primary.withValues(alpha: 0.1),
                                    child: const Icon(Icons.fastfood, color: AppTheme.primary),
                                  ),
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.fastfood, color: AppTheme.primary),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.price.toStringAsFixed(2)} c/u',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 22),
                              onPressed: () => cart.decrementQuantity(item.id),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 22),
                              onPressed: () => cart.incrementQuantity(item.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                              onPressed: () => cart.removeItem(item.id),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(fontSize: 15, color: Colors.grey)),
                        Text('\$${cart.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Costo de Envío', style: TextStyle(fontSize: 15, color: Colors.grey)),
                        Text('\$${cart.deliveryFee.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${cart.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          cart.clear();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('🎉 Pedido Exitoso'),
                              content: const Text('Tu pedido ha sido registrado con éxito. ¡Pronto estará en camino!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          'Confirmar Pedido',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
