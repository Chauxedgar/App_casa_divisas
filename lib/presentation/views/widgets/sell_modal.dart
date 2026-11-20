import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SellModal extends StatefulWidget {
  const SellModal({Key? key}) : super(key: key);

  @override
  State<SellModal> createState() => _SellModalState();
}

class _SellModalState extends State<SellModal> {
  int _saleType = 0; // 0: Vender a la plataforma, 1: Crear orden P2P
  String _selectedCurrency = 'USD';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  final Map<String, double> _marketRates = {
    'USD': 4120.50,
    'EUR': 4450.20,
    'GBP': 5200.00,
  };

  final supabase = Supabase.instance.client;

  Future<void> _ejecutarAccionVenta() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _mostrarMensaje("Por favor ingresa una cantidad válida");
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _mostrarMensaje("Cantidad inválida");
      return;
    }

    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;

    try {
      if (_saleType == 0) {
        // Opción 1: Vender directamente a la plataforma
        final double rate = _marketRates[_selectedCurrency]!;
        final double totalCOP = amount * rate;

        // Registro de la transacción en la tabla 'transactions' de Supabase
        await supabase.from('transactions').insert({
          'user_id': user?.id ?? 'anonimo',
          'type': 'sell_to_platform',
          'currency': _selectedCurrency,
          'amount': amount,
          'price_per_unit': rate,
          'total_cop': totalCOP,
        });

        _mostrarMensaje("¡Venta exitosa a la plataforma por \$${totalCOP.toStringAsFixed(2)} COP!");
      } else {
        // Opción 2: Crear orden P2P para otros usuarios
        final priceText = _priceController.text.trim();
        final double? customPrice = double.tryParse(priceText);
        
        if (customPrice == null || customPrice <= 0) {
          _mostrarMensaje("Ingresa un precio unitario válido para la orden P2P");
          setState(() => _isLoading = false);
          return;
        }

        // Inserción de la orden P2P en la tabla 'p2p_market_orders' de Supabase
        await supabase.from('p2p_market_orders').insert({
          'user_id': user?.id ?? 'anonimo',
          'seller_email': user?.email ?? 'usuario',
          'currency': _selectedCurrency,
          'amount': amount,
          'price_per_unit': customPrice,
          'status': 'active',
        });

        _mostrarMensaje("¡Orden P2P publicada con éxito en el mercado!");
      }

      Navigator.pop(context);
    } catch (e) {
      _mostrarMensaje("Error al procesar la operación: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Módulo de Venta - Casa C",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Selector de tipo de venta
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(value: 0, label: Text('A la Plataforma'), icon: Icon(Icons.flash_on)),
                ButtonSegment<int>(value: 1, label: Text('Crear Orden P2P'), icon: Icon(Icons.people_outline)),
              ],
              selected: {_saleType},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _saleType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 20),

            // Selector de Divisa
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: InputDecoration(
                labelText: "Seleccionar Divisa",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _marketRates.keys.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  key: Key(currency),
                  child: Text("$currency (Ref: ${_marketRates[currency]} COP)"),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) setState(() => _selectedCurrency = newValue);
              },
            ),
            const SizedBox(height: 16),

            // Cantidad
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Cantidad a vender ($_selectedCurrency)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.monetization_on_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Campo extra si es P2P (Precio personalizado)
            if (_saleType == 1) ...[
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Precio de venta por unidad (en COP)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.sell_outlined),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Botón de acción
            ElevatedButton(
              onPressed: _isLoading ? null : _ejecutarAccionVenta,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _saleType == 0 ? "Vender Instantáneo a la Plataforma" : "Publicar Oferta P2P",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}