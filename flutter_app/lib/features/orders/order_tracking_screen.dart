import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/graphql/graphql_queries.dart';
import '../../core/services/graphql_service.dart';
import '../../core/theme/app_theme.dart';

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
                  const SizedBox(height: 28),

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
                  const SizedBox(height: 28),

                  // Payment Summary
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
                        const Text('Monto Total Pagado:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
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
