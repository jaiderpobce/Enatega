import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/graphql/graphql_queries.dart';
import '../../core/services/graphql_service.dart';
import '../../core/theme/app_theme.dart';
import '../chat/chat_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    setState(() => _isLoading = true);

    try {
      final graphqlService = context.read<GraphQLService>();
      final result = await graphqlService.query(
        GraphQLQueries.orderByIdQuery,
        variables: {'id': widget.orderId},
      );

      if (!result.hasException && result.data?['order'] != null) {
        _orderData = result.data!['order'] as Map<String, dynamic>;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  int _getStepIndex(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return 1;
      case 'PICKED':
        return 2;
      case 'DELIVERED':
        return 3;
      case 'PENDING':
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _orderData?['order_status']?.toString() ?? 'PENDING';
    final code = _orderData?['order_id']?.toString() ?? 'ORD-0000';
    final amount = (_orderData?['paid_amount'] as num?)?.toDouble() ?? 0.0;
    final method = _orderData?['payment_method']?.toString() ?? 'CASH';
    final bankName = _orderData?['bank_name']?.toString();
    final reference = _orderData?['payment_reference']?.toString();
    final proofUrl = _orderData?['payment_proof_url']?.toString();
    final paymentStatus = _orderData?['payment_status']?.toString() ?? 'PENDING';
    final deliveryAddressText = _orderData?['delivery_address_text']?.toString() ?? 'Ubicación Capturada por GPS (Google API)';
    final latitude = (_orderData?['latitude'] as num?)?.toDouble() ?? 10.4806;
    final longitude = (_orderData?['longitude'] as num?)?.toDouble() ?? -66.9036;

    final currentStep = _getStepIndex(status);

    return Scaffold(
      appBar: AppBar(
        title: Text('Rastreo $code'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrder,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrder,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Header Status Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.delivery_dining, size: 56, color: Colors.white),
                        const SizedBox(height: 12),
                        Text(
                          status == 'DELIVERED'
                              ? '¡Pedido Entregado!'
                              : status == 'PICKED'
                                  ? '¡Tu repartidor va en camino!'
                                  : status == 'ACCEPTED'
                                      ? '¡Restaurante preparando tu orden!'
                                      : '¡Pedido Recibido!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Código de Orden: $code',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chat Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        'Contactar Repartidor (Chat)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(orderCode: code),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progress Timeline
                  const Text(
                    'Estado de la Entrega',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _TimelineStep(
                    title: '1. Pedido Recibido',
                    subtitle: 'Hemos confirmado tu solicitud en el sistema',
                    icon: Icons.receipt_long,
                    isActive: currentStep >= 0,
                    isCompleted: currentStep > 0,
                  ),
                  _TimelineStep(
                    title: '2. En Preparación',
                    subtitle: 'El restaurante está preparando tu comida',
                    icon: Icons.soup_kitchen,
                    isActive: currentStep >= 1,
                    isCompleted: currentStep > 1,
                  ),
                  _TimelineStep(
                    title: '3. En Camino (Rider)',
                    subtitle: 'El repartidor recogió tu pedido',
                    icon: Icons.two_wheeler,
                    isActive: currentStep >= 2,
                    isCompleted: currentStep > 2,
                  ),
                  _TimelineStep(
                    title: '4. Entregado',
                    subtitle: '¡Que disfrutes tu comida!',
                    icon: Icons.check_circle_outline,
                    isActive: currentStep >= 3,
                    isCompleted: currentStep >= 3,
                    isLast: true,
                  ),
                  const SizedBox(height: 24),

                  // Transfer / Bank Proof Details (If Transfer)
                  if (method == 'TRANSFER' && (bankName != null || reference != null)) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance, color: AppTheme.primary, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Datos de Transferencia Bancaria',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: paymentStatus == 'PAID'
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : paymentStatus == 'REJECTED'
                                          ? Colors.red.withValues(alpha: 0.15)
                                          : Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  paymentStatus == 'PAID'
                                      ? '✅ PAGO APROBADO'
                                      : paymentStatus == 'REJECTED'
                                          ? '❌ PAGO RECHAZADO'
                                          : '⏳ VERIFICANDO PAGO',
                                  style: TextStyle(
                                    color: paymentStatus == 'PAID'
                                        ? Colors.green
                                        : paymentStatus == 'REJECTED'
                                            ? Colors.red
                                            : Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Banco de Origen: ${bankName ?? "N/A"}', style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Referencia: ${reference ?? "N/A"}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          if (proofUrl != null && proofUrl.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                proofUrl,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Delivery Location GPS Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppTheme.primary,
                          child: Icon(Icons.location_on, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ubicación de Entrega (Google API)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(deliveryAddressText, style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                'GPS: Lat ${latitude.toStringAsFixed(4)}, Lng ${longitude.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Método de Pago:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              method == 'TRANSFER' ? 'Transferencia Bancaria' : 'Efectivo',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.isCompleted,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? Colors.green
        : isActive
            ? AppTheme.primary
            : Colors.grey.shade400;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isActive ? Colors.black : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
