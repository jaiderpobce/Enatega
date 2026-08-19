import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/graphql/graphql_queries.dart';
import '../../core/services/graphql_service.dart';
import '../../core/theme/app_theme.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
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

  Future<void> _updatePaymentStatus(String orderId, String paymentStatus, String orderStatus) async {
    try {
      final graphqlService = context.read<GraphQLService>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      final result = await graphqlService.mutate(
        GraphQLQueries.updatePaymentStatusMutation,
        variables: {
          'id': orderId,
          'paymentStatus': paymentStatus,
          'orderStatus': orderStatus,
        },
      );

      if (!result.hasException && mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              paymentStatus == 'PAID'
                  ? '✅ ¡Pago aprobado con éxito! El pedido pasó a Preparación.'
                  : '❌ Pago rechazado.',
            ),
            backgroundColor: paymentStatus == 'PAID' ? Colors.green : Colors.redAccent,
          ),
        );
        _fetchOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Widget _buildProofImage(String? proofUrl, {double height = 150, BoxFit fit = BoxFit.cover}) {
    if (proofUrl != null && proofUrl.isNotEmpty) {
      if (proofUrl.startsWith('/') || proofUrl.startsWith('file://')) {
        final cleanPath = proofUrl.replaceFirst('file://', '');
        final file = File(cleanPath);
        if (file.existsSync()) {
          return Image.file(
            file,
            height: height,
            width: double.infinity,
            fit: fit,
          );
        }
      }

      return Image.network(
        proofUrl,
        height: height,
        width: double.infinity,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallbackReceipt(height, fit),
      );
    }

    return _buildFallbackReceipt(height, fit);
  }

  Widget _buildFallbackReceipt(double height, BoxFit fit) {
    return Image.network(
      'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c',
      height: height,
      width: double.infinity,
      fit: fit,
    );
  }

  void _showProofImageZoom(String? imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildProofImage(imageUrl, height: 320, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              icon: const Icon(Icons.close),
              label: const Text('Cerrar'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Pagos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _orders.isEmpty
                ? const Center(child: Text('No hay pedidos registrados.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final id = order['_id']?.toString() ?? '';
                      final code = order['order_id']?.toString() ?? 'ORD-0000';
                      final paidAmount = (order['paid_amount'] as num?)?.toDouble() ?? 0.0;
                      final paymentMethod = order['payment_method']?.toString() ?? 'CASH';
                      final bankName = order['bank_name']?.toString() ?? 'N/A';
                      final reference = order['payment_reference']?.toString() ?? 'N/A';
                      final proofUrl = order['payment_proof_url']?.toString();
                      final paymentStatus = order['payment_status']?.toString() ?? 'PENDING';
                      final orderStatus = order['order_status']?.toString() ?? 'PENDING';

                      final isApproved = paymentStatus == 'PAID';
                      final isRejected = paymentStatus == 'REJECTED';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                          border: Border.all(
                            color: isApproved
                                ? Colors.green.shade300
                                : isRejected
                                    ? Colors.red.shade300
                                    : Colors.orange.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  code,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isApproved
                                        ? Colors.green.withValues(alpha: 0.15)
                                        : isRejected
                                            ? Colors.red.withValues(alpha: 0.15)
                                            : Colors.orange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isApproved
                                        ? 'PAGO APROBADO'
                                        : isRejected
                                            ? 'RECHAZADO'
                                            : 'POR VERIFICAR',
                                    style: TextStyle(
                                      color: isApproved
                                          ? Colors.green
                                          : isRejected
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
                            Text('Monto: \$${paidAmount.toStringAsFixed(2)} | Método: $paymentMethod'),
                            Text('Banco Emisor: $bankName'),
                            Text(
                              'Referencia: $reference',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                            Text('Estado Orden: $orderStatus', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 12),

                            // Proof Image Section (Always Displayed)
                            const Text(
                              'Comprobante de Pago:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => _showProofImageZoom(proofUrl),
                              child: Container(
                                height: 160,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade100,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      _buildProofImage(proofUrl, height: 160, fit: BoxFit.cover),
                                      Container(
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.7),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                            SizedBox(width: 4),
                                            Text('Toca para ampliar', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Approval Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.check_circle_outline, size: 18),
                                    label: const Text('Aprobar'),
                                    onPressed: () => _updatePaymentStatus(id, 'PAID', 'ACCEPTED'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(color: Colors.redAccent),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.cancel_outlined, size: 18),
                                    label: const Text('Rechazar'),
                                    onPressed: () => _updatePaymentStatus(id, 'REJECTED', 'CANCELLED'),
                                  ),
                                ),
                              ],
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
