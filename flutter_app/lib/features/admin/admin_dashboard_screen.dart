import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/graphql/graphql_queries.dart';
import '../../core/services/graphql_service.dart';
import '../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<dynamic> _categories = [];
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);

    try {
      final graphqlService = context.read<GraphQLService>();

      final catResult = await graphqlService.query(GraphQLQueries.categoriesQuery);
      if (!catResult.hasException && catResult.data?['categories'] != null) {
        _categories = catResult.data!['categories'] as List<dynamic>;
      }

      final ordersResult = await graphqlService.query(GraphQLQueries.myOrdersQuery);
      if (!ordersResult.hasException && ordersResult.data?['orders'] != null) {
        _orders = ordersResult.data!['orders'] as List<dynamic>;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddFoodModal() {
    final titleController = TextEditingController();
    final priceController = TextEditingController(text: '12.99');
    final descController = TextEditingController();
    final imgController = TextEditingController();
    String? selectedCatId = _categories.isNotEmpty ? _categories.first['_id']?.toString() : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agregar Nuevo Platillo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Nombre del Platillo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio (\$ USD)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedCatId,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['_id']?.toString(),
                    child: Text(cat['title']?.toString() ?? 'Sin categoría'),
                  );
                }).toList(),
                onChanged: (val) => setModalState(() => selectedCatId = val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imgController,
                decoration: const InputDecoration(labelText: 'URL de Imagen (Opcional)'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  onPressed: () async {
                    if (titleController.text.isEmpty || selectedCatId == null) return;

                    final graphqlService = context.read<GraphQLService>();
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(ctx);

                    final result = await graphqlService.mutate(
                      GraphQLQueries.createFoodMutation,
                      variables: {
                        'title': titleController.text.trim(),
                        'price': double.tryParse(priceController.text) ?? 9.99,
                        'categoryId': selectedCatId,
                        'description': descController.text.trim(),
                        'imgUrl': imgController.text.trim(),
                      },
                    );

                    if (!result.hasException) {
                      navigator.pop();
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('¡Platillo creado exitosamente!'),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    }
                  },
                  child: const Text('Crear Platillo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryModal() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agregar Nueva Categoría',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Nombre de Categoría'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                onPressed: () async {
                  if (titleController.text.isEmpty) return;

                  final graphqlService = context.read<GraphQLService>();
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(ctx);

                  final result = await graphqlService.mutate(
                    GraphQLQueries.createCategoryMutation,
                    variables: {
                      'title': titleController.text.trim(),
                      'description': descController.text.trim(),
                    },
                  );

                  if (!result.hasException) {
                    navigator.pop();
                    _loadAdminData();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('¡Categoría agregada!'),
                        backgroundColor: AppTheme.primary,
                      ),
                    );
                  }
                },
                child: const Text('Crear Categoría', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalRevenue = 0.0;
    for (var o in _orders) {
      totalRevenue += (o['paid_amount'] as num?)?.toDouble() ?? 0.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrador'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAdminData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Metrics Grid
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Ventas Totales',
                          value: '\$${totalRevenue.toStringAsFixed(2)}',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Total Pedidos',
                          value: '${_orders.length}',
                          icon: Icons.receipt_long,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Categorías',
                          value: '${_categories.length}',
                          icon: Icons.category_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _MetricCard(
                          title: 'Roles Activos',
                          value: 'RBAC (2)',
                          icon: Icons.security,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Actions Section
                  const Text(
                    'Gestión del Sistema',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: Colors.white,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF3E0),
                      child: Icon(Icons.add_task, color: AppTheme.primary),
                    ),
                    title: const Text('Agregar Platillo al Menú', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Crea nuevos productos con imagen y precio'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showAddFoodModal,
                  ),
                  const SizedBox(height: 8),

                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: Colors.white,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(Icons.create_new_folder_outlined, color: Colors.blue),
                    ),
                    title: const Text('Agregar Nueva Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Organiza tu catálogo de alimentos'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showAddCategoryModal,
                  ),
                ],
              ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
