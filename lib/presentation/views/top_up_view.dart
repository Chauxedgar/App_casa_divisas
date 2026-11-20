import 'package:flutter/material.dart';
import '../../data/services/mercadopago_service.dart';
import 'payment_webview_view.dart';

class TopUpView extends StatefulWidget {
  const TopUpView({Key? key}) : super(key: key);

  @override
  State<TopUpView> createState() => _TopUpViewState();
}

class _TopUpViewState extends State<TopUpView> {
  final TextEditingController _montoController = TextEditingController();
  bool _isLoading = false;

  void _procesarRecarga() async {
    final textoMonto = _montoController.text.trim();
    if (textoMonto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa un monto válido")),
      );
      return;
    }

    final double? monto = double.tryParse(textoMonto);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El monto ingresado no es válido")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Consumimos la API real de Mercado Pago usando tus credenciales del .env
      final String? urlPago = await MercadoPagoService.crearPreferenciaPago(
        monto: monto, 
        moneda: "USD",
      );

      setState(() {
        _isLoading = false;
      });

      if (urlPago != null) {
        // Navegamos al visor web con la pasarela real de tu cuenta
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewView(paymentUrl: urlPago),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo generar la preferencia de pago con Mercado Pago.")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Recargar Saldo", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner informativo de Mercado Pago
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF009EE3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF009EE3).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Color(0xFF009EE3), size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Pagos Seguros con Mercado Pago",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF002D62)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tus recargas se procesan de forma cifrada mediante tarjetas, PSE o efectivo.",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              "¿Cuánto deseas recargar?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
            ),
            const SizedBox(height: 12),

            // Campo de texto para el monto
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: "\$ ",
                prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0052FF)),
                hintText: "0.00",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 24),

            // Botones rápidos de montos predeterminados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickAmountButton("50"),
                _buildQuickAmountButton("100"),
                _buildQuickAmountButton("500"),
                _buildQuickAmountButton("1000"),
              ],
            ),
            const SizedBox(height: 40),

            // Botón de Pagar con Mercado Pago
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _procesarRecarga,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009EE3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Continuar a Mercado Pago",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return OutlinedButton(
      onPressed: () {
        _montoController.text = amount;
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        "\$$amount",
        style: const TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold),
      ),
    );
  }
}