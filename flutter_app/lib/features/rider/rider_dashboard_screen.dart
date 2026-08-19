import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/graphql/graphql_queries.dart';
import '../../core/services/graphql_service.dart';
import '../../core/theme/app_theme.dart';

class RiderDashboardScreen extends StatefulWidget {
  const RiderDashboardScreen({super.key});

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiderOrders();
  }

  Future<void> _loadRiderOrders() async {
    setState(() => _isLoading = true);

    try {
      final graphqlService = context.read<GraphQLService>();
      final result = await graphqlService.query(GraphQLQueries.myOrdersQuery);

      if (!result.hasException && result.data?['orders'] != null) {
        _orders = result.data!['orders'] as List<dynamic>;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String orderId, String nextStatus) async {
    try {
      final graphqlService = context.read<GraphQLService>();
      final result = await graphqlService.mutate(
        GraphQLQueries.updateOrderStatusMutation,
        variables: {
          'id': orderId,
          'status': nextStatus,
        },
      );

      if (!result.hasException) {
        await _loadRiderOrders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Estado actualizado a: $nextStatus'),
              backgroundColor: AppTheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar estado: $e')),
        );
      }
    }
  }

  Widget _buildActionButton(String orderId, String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text('Aceptar Entrega', style: TextStyle(color: Colors.white)),
          onPressed: () => _updateStatus(orderId, 'ACCEPTED'),
        );
      case 'ACCEPTED':
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          icon: const Icon(Icons.two_wheeler, color: Colors.white),
          label: const Text('Recoger Pedido', style: TextStyle(color: Colors.white)),
          onPressed: () => _updateStatus(orderId, 'PICKED'),
        );
      case 'PICKED':
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          icon: const Icon(Icons.done_all, color: Colors.white),
          label: const Text('Marcar Entregado', style: TextStyle(color: Colors.white)),
          onPressed: () => _updateStatus(orderId, 'DELIVERED'),
        );
      case 'DELIVERED':
      default:
        return const Chip(
          label: Text('Entregado 🎉', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xFFE8F5E9),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Repartidor (Rider)'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRiderOrders,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delivery_dining_outlined, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No hay pedidos para repartir',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = _orders[index] as Map<String, dynamic>;
                      final id = order['_id']?.toString() ?? '';
                      final orderId = order['order_id']?.toString() ?? 'ORD-0000';
                      final status = order['order_status']?.toString() ?? 'PENDING';
                      final amount = (order['paid_amount'] as num?)?.toDouble() ?? 0.0;
                      final date = order['createdAt']?.toString() ?? '';

                      return Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  orderId,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '\$${amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Fecha: $date',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: _buildActionButton(id, status),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
