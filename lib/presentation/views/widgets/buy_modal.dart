import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../payment_webview_view.dart';

class BuyModal extends StatefulWidget {
  const BuyModal({Key? key}) : super(key: key);

  @override
  State<BuyModal> createState() => _BuyModalState();
}

class _BuyModalState extends State<BuyModal> {
  int _buyMode = 0; // 0: Comprar a la plataforma, 1: Comprar de Mercado P2P
  String _selectedCurrency = 'USD';
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  final Map<String, double> _platformRates = {
    'USD': 4120.50,
    'EUR': 4450.20,
    'GBP': 5200.00,
  };

  final supabase = Supabase.instance.client;

  Future<void> _irAPasarelaDePagos() async {
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

    final double rate = _platformRates[_selectedCurrency]!;
    final double totalCOP = amount * rate;

    setState(() => _isLoading = true);

    try {
      final String accessToken = dotenv.env['MP_ACCESS_TOKEN'] ?? 
          'APP_USR-3274464687555599-110300-c2a73e5ebd833758bd20561334a3a6dc-3761183938';

      final response = await http.post(
        Uri.parse('https://api.mercadopago.com/checkout/preferences'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "items": [
            {
              "title": "Compra de $amount $_selectedCurrency - Casa C",
              "quantity": 1,
              "currency_id": "COP",
              "unit_price": totalCOP,
            }
          ],
          "back_urls": {
            "success": "https://www.mercadopago.com.co",
            "failure": "https://www.mercadopago.com.co",
            "pending": "https://www.mercadopago.com.co"
          },
          "auto_return": "approved",
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String checkoutUrl = data['sandbox_init_point'] ?? data['init_point'];

        if (!mounted) return;
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewView(
              paymentUrl: checkoutUrl,
            ),
          ),
        );
      } else {
        _mostrarMensaje("Error al conectar con Mercado Pago");
      }
    } catch (e) {
      _mostrarMensaje("Error de red: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _comprarP2P(Map<String, dynamic> orderData) async {
    final String orderId = orderData['id'].toString();
    final double pricePerUnit = double.parse(orderData['price_per_unit'].toString());
    final double amount = double.parse(orderData['amount'].toString());
    final String currency = orderData['currency'].toString();
    final double totalCOP = amount * pricePerUnit;

    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;

    try {
      await supabase.from('transactions').insert({
        'user_id': user?.id ?? 'anonimo',
        'type': 'buy_p2p',
        'seller_id': orderData['user_id'],
        'currency': currency,
        'amount': amount,
        'price_per_unit': pricePerUnit,
        'total_cop': totalCOP,
      });

      await supabase
          .from('p2p_market_orders')
          .update({'status': 'completed'})
          .eq('id', orderId);

      _mostrarMensaje("¡Compra P2P completada con éxito por \$${totalCOP.toStringAsFixed(2)} COP!");
      Navigator.pop(context);
    } catch (e) {
      _mostrarMensaje("Error al completar la orden P2P: $e");
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Módulo de Compra - Casa C",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(value: 0, label: Text('A la Plataforma'), icon: Icon(Icons.flash_on)),
              ButtonSegment<int>(value: 1, label: Text('Mercado P2P'), icon: Icon(Icons.people)),
            ],
            selected: {_buyMode},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                _buyMode = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 20),

          if (_buyMode == 0) ...[
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: InputDecoration(
                labelText: "Seleccionar Divisa",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _platformRates.keys.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text("$currency (Tasa: ${_platformRates[currency]} COP)"),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) setState(() => _selectedCurrency = newValue);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Cantidad a comprar ($_selectedCurrency)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.monetization_on_outlined),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _irAPasarelaDePagos,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("Continuar a Pasarela de Pagos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            const Text(
              "Órdenes P2P Disponibles de la Comunidad:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: supabase
                    .from('p2p_market_orders')
                    .stream(primaryKey: ['id'])
                    .eq('status', 'active'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null || (snapshot.data! as List).isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "No hay órdenes P2P activas en este momento. ¡Crea una desde el módulo de venta!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data! as List;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index];
                      final currency = data['currency'] ?? 'USD';
                      final amount = data['amount'] ?? 0.0;
                      final price = data['price_per_unit'] ?? 0.0;
                      final sellerEmail = data['seller_email'] ?? 'Usuario P2P';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          title: Text("$amount $currency a \$${price.toStringAsFixed(2)} COP c/u",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Vendedor: $sellerEmail"),
                          trailing: ElevatedButton(
                            onPressed: _isLoading ? null : () => _comprarP2P(data),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0052FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Comprar"),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}