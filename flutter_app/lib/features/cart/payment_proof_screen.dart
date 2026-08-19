import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/graphql/graphql_queries.dart';
import '../../core/services/graphql_service.dart';
import '../../core/theme/app_theme.dart';
import 'cart_controller.dart';

class PaymentProofScreen extends StatefulWidget {
  const PaymentProofScreen({
    super.key,
    required this.amount,
    this.deliveryAddress = 'Av. Principal, Edificio Central (GPS Google API)',
    this.latitude = 10.4806,
    this.longitude = -66.9036,
  });

  final double amount;
  final String deliveryAddress;
  final double latitude;
  final double longitude;

  @override
  State<PaymentProofScreen> createState() => _PaymentProofScreenState();
}

class _PaymentProofScreenState extends State<PaymentProofScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankController = TextEditingController(text: 'Banesco / Pago Móvil');
  final _referenceController = TextEditingController();
  final _proofUrlController = TextEditingController(text: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c');
  
  XFile? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bankController.dispose();
    _referenceController.dispose();
    _proofUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImage = image;
          _proofUrlController.text = image.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📷 Imagen seleccionada: ${image.name}'),
              backgroundColor: AppTheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir la galería: $e')),
        );
      }
    }
  }

  Future<void> _submitPaymentProof() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final graphqlService = context.read<GraphQLService>();
      final cart = context.read<CartController>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      final result = await graphqlService.mutate(
        GraphQLQueries.placeOrderMutation,
        variables: {
          'amount': widget.amount,
          'paymentMethod': 'TRANSFER',
          'bankName': _bankController.text.trim(),
          'paymentReference': _referenceController.text.trim(),
          'paymentProofUrl': _proofUrlController.text.trim(),
          'deliveryAddress': widget.deliveryAddress,
          'latitude': widget.latitude,
          'longitude': widget.longitude,
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
            title: const Text('🎉 ¡Pago Registrado!'),
            content: Text('Tu transferencia ($orderId) ha sido enviada con la referencia ${_referenceController.text.trim()}. Estará en verificación.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  navigator.pop();
                  navigator.pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Error al registrar la transferencia en el servidor.')),
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
        title: const Text('Comprobante de Pago'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total a Transferir:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '\$${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Banco de Origen / Método',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bankController,
                decoration: InputDecoration(
                  hintText: 'Ej. Banesco, Mercantil, BBVA, Chase',
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Ingresa el banco emisor' : null,
              ),
              const SizedBox(height: 16),

              const Text(
                'Número de Referencia del Pago',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _referenceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ej. 94810239',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Ingresa el número de referencia' : null,
              ),
              const SizedBox(height: 16),

              const Text(
                'Foto del Comprobante de Pago',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),

              // Gallery Image Selector Card
              InkWell(
                onTap: _pickImageFromGallery,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppTheme.primary,
                        child: Icon(Icons.photo_library, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pickedImage != null ? 'Imagen Seleccionada' : 'Buscar Foto en el Teléfono',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _pickedImage != null ? _pickedImage!.name : 'Toca para abrir la galería e imágenes',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image Preview Card
              const Text(
                'Vista Previa:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _pickedImage != null
                    ? Image.file(
                        File(_pickedImage!.path),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        _proofUrlController.text,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long, size: 40, color: Colors.grey),
                              SizedBox(height: 4),
                              Text('Vista Previa de Comprobante', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSubmitting ? null : _submitPaymentProof,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirmar y Enviar Comprobante',
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
