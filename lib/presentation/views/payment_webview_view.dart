import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewView extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebViewView({Key? key, required this.paymentUrl}) : super(key: key);

  @override
  State<PaymentWebViewView> createState() => _PaymentWebViewViewState();
}

class _PaymentWebViewViewState extends State<PaymentWebViewView> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Solo inicializamos el WebView si NO estamos en la Web
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.paymentUrl));
    } else {
      _isLoading = false;
    }
  }

  void _abrirEnNavegadorWeb() async {
    final Uri uri = Uri.parse(widget.paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pasarela de Pagos - Mercado Pago", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: kIsWeb
          ? Center(
              // Vista adaptada para Web (ya que el WebView nativo no corre directamente en navegadores de escritorio)
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment, size: 64, color: Color(0xFF009EE3)),
                    const SizedBox(height: 16),
                    const Text(
                      "Simulación de Pasarela de Pagos",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Estás ejecutando la aplicación en el navegador web. Haz clic en el botón de abajo para completar tu recarga segura en Mercado Pago.",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _abrirEnNavegadorWeb,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("Ir al Checkout de Mercado Pago"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009EE3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              // Vista para móviles (Android / iOS) con WebView integrado
              children: [
                if (_controller != null) WebViewWidget(controller: _controller!),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF009EE3),
                    ),
                  ),
              ],
            ),
    );
  }
}