import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/graphql/graphql_queries.dart';
import '../../core/services/graphql_service.dart';
import '../../core/theme/app_theme.dart';
import 'cart_controller.dart';
import 'payment_proof_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isSubmitting = false;
  String _selectedPaymentMethod = 'CASH'; // 'CASH' or 'TRANSFER'
  double _discountPercent = 0.0;
  final TextEditingController _couponController = TextEditingController();

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code == 'ENATEGA10' || code == 'DESCUENTO10') {
      setState(() => _discountPercent = 0.10);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Cupón de 10% de descuento aplicado!'),
          backgroundColor: AppTheme.primary,
        ),
      );
    } else if (code.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cupón no válido. Prueba con: ENATEGA10')),
      );
    }
  }

  Future<void> _processCashCheckout(CartController cart, double grandTotal) async {
    setState(() => _isSubmitting = true);

    try {
      final graphqlService = context.read<GraphQLService>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      final result = await graphqlService.mutate(
        GraphQLQueries.placeOrderMutation,
        variables: {
          'amount': grandTotal,
          'paymentMethod': 'CASH',
        },
      );

      if (!result.hasException && result.data?['placeOrder'] != null) {
        final orderData = result.data!['placeOrder'] as Map<String, dynamic>;
        final orderId = orderData['order_id']?.toString() ?? 'ORD-0000';

        cart.clear();

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('🎉 ¡Pedido Registrado!'),
            content: Text('Tu pedido $orderId ha sido guardado. Pagarás \$${grandTotal.toStringAsFixed(2)} en efectivo al recibir.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  navigator.pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Error al registrar el pedido en el servidor.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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

          final discountAmount = cart.subtotal * _discountPercent;
          final grandTotal = (cart.subtotal - discountAmount) + cart.deliveryFee;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Items List
                    ...cart.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: (item.imgUrl != null && item.imgUrl!.isNotEmpty)
                                  ? Image.network(
                                      item.imgUrl!,
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 65,
                                        height: 65,
                                        color: AppTheme.primary.withValues(alpha: 0.1),
                                        child: const Icon(Icons.fastfood, color: AppTheme.primary),
                                      ),
                                    )
                                  : Container(
                                      width: 65,
                                      height: 65,
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
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)} c/u',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
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
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () => cart.decrementQuantity(item.id),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () => cart.incrementQuantity(item.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => cart.removeItem(item.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 24),

                    // Coupon Input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            decoration: InputDecoration(
                              hintText: 'Código Promocional (ej. ENATEGA10)',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                          onPressed: _applyCoupon,
                          child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Payment Method Selector
                    const Text(
                      'Método de Pago',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () => setState(() => _selectedPaymentMethod = 'CASH'),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _selectedPaymentMethod == 'CASH' ? AppTheme.primary.withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedPaymentMethod == 'CASH' ? AppTheme.primary : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.payments_outlined, color: AppTheme.primary),
                            SizedBox(width: 12),
                            Text('💵 Efectivo en la Entrega', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () => setState(() => _selectedPaymentMethod = 'TRANSFER'),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _selectedPaymentMethod == 'TRANSFER' ? AppTheme.primary.withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedPaymentMethod == 'TRANSFER' ? AppTheme.primary : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_balance, color: AppTheme.primary),
                                SizedBox(width: 12),
                                Text('🏦 Transferencia / Pago Móvil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text('Ingresa tu banco, referencia y foto de comprobante', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                        const Text('Subtotal', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text('\$${cart.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (_discountPercent > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Descuento Cupón (10%)', style: TextStyle(fontSize: 14, color: Colors.green)),
                          Text('-\$${discountAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Costo de Envío', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text('\$${cart.deliveryFee.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${grandTotal.toStringAsFixed(2)}',
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
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (_selectedPaymentMethod == 'TRANSFER') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentProofScreen(amount: grandTotal),
                                    ),
                                  );
                                } else {
                                  _processCashCheckout(cart, grandTotal);
                                }
                              },
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _selectedPaymentMethod == 'TRANSFER'
                                    ? 'Continuar al Comprobante Bancario'
                                    : 'Confirmar Pedido (Efectivo)',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
