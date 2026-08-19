import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/graphql/graphql_queries.dart';
import '../../core/services/graphql_service.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import 'location_picker_screen.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController(text: 'Casa');
  final _addressController = TextEditingController();
  final _detailsController = TextEditingController();
  
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final graphqlService = context.read<GraphQLService>();
      final result = await graphqlService.mutate(
        GraphQLQueries.createAddressMutation,
        variables: {
          'label': _labelController.text.trim(),
          'delivery_address': _addressController.text.trim(),
          'details': _detailsController.text.trim(),
          'latitude': _latitude ?? 10.4806,
          'longitude': _longitude ?? -66.9036,
          'selected': true,
        },
      );

      if (!result.hasException) {
        if (!mounted) return;
        await context.read<AuthController>().fetchProfile(silent: true);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Dirección guardada exitosamente!'),
              backgroundColor: AppTheme.primary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar dirección en servidor.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openGoogleMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLatitude: _latitude ?? 10.4806,
          initialLongitude: _longitude ?? -66.9036,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _addressController.text = result['address']?.toString() ?? _addressController.text;
        _latitude = (result['latitude'] as num?)?.toDouble() ?? _latitude;
        _longitude = (result['longitude'] as num?)?.toDouble() ?? _longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📍 Ubicación seleccionada en mapa: Lat ${_latitude!.toStringAsFixed(4)}, Lng ${_longitude!.toStringAsFixed(4)}'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Dirección'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Google GPS Location Button Card
              InkWell(
                onTap: _openGoogleMapPicker,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppTheme.primary,
                        child: Icon(Icons.map, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🗺️ Abrir Mapa de Google (Google Maps)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _latitude != null
                                  ? 'GPS: Lat ${_latitude!.toStringAsFixed(4)}, Lng ${_longitude!.toStringAsFixed(4)}'
                                  : 'Toca para abrir el mapa anclado a tu GPS y mover el marcador',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Etiqueta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  hintText: 'Ej. Casa, Oficina, Apartamento',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              const Text(
                'Dirección de Entrega',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Calle, Avenida, Edificio o Número',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Ingresa la dirección' : null,
              ),
              const SizedBox(height: 16),

              const Text(
                'Detalles / Referencia (Opcional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _detailsController,
                decoration: InputDecoration(
                  hintText: 'Ej. Piso 4, Apto 4B, cerca del parque',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _saveAddress,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar Dirección',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
