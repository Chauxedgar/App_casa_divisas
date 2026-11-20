import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MercadoPagoService {
  static Future<String?> crearPreferenciaPago({
    required double monto,
    required String moneda,
  }) async {
    // Obtenemos el Token de acceso desde el archivo .env
    final accessToken = dotenv.env['MP_ACCESS_TOKEN'];
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("Falta configurar el MP_ACCESS_TOKEN en el archivo .env");
    }

    const url = 'https://api.mercadopago.com/checkout/preferences';

    // Estructura de la orden de compra que consume Mercado Pago
    final body = jsonEncode({
      "items": [
        {
          "title": "Recarga de Saldo - Casa de Divisas",
          "quantity": 1,
          "currency_id": moneda, // Ej: "USD" o "COP"
          "unit_price": monto
        }
      ],
      "back_urls": {
        "success": "https://www.google.com",
        "failure": "https://www.google.com",
        "pending": "https://www.google.com"
      },
      "auto_return": "approved",
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: body,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Retorna la URL oficial de la pasarela de pago generada para tu cuenta
        return data['init_point']; 
      } else {
        print("Error al crear preferencia: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Excepción de red: $e");
      return null;
    }
  }
}