import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Barra Superior (Header con título, selector de idioma y avatar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Welcome back,",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          // Selector de idioma simulado (EN / ES)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "EN / ES",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0052FF)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Edgar Chaux",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                    ],
                  ),
                  // Avatar de Usuario
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0052FF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF0052FF),
                      child: Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Tarjeta de Balance General con Gradiente (Hero Card)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0052FF), Color(0xFF00D4FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0052FF).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TOTAL BALANCE",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "\$45,230.80",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Etiqueta de rendimiento (+4.2% Last 30 days)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.arrow_upward, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                "+4.2%",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Last 30 days",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Botones de Buy y Sell
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0052FF),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Buy",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Sell",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 3. Título de Mercado de Divisas
              const Text(
                "Currency Market",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Lista de Tarjetas de Divisas
              _buildCurrencyTile(
                iconSymbol: "\$",
                pair: "USD / COP",
                subtext: "USD / COP",
                price: "\$4,120.50",
                change: "+0.85%",
                isPositive: true,
              ),
              const SizedBox(height: 12),
              _buildCurrencyTile(
                iconSymbol: "€",
                pair: "EUR / USD",
                subtext: "EUR / USD",
                price: "1.085",
                change: "-0.24%",
                isPositive: false,
              ),
              const SizedBox(height: 12),
              _buildCurrencyTile(
                iconSymbol: "£",
                pair: "GBP / USD",
                subtext: "GBP / USD",
                price: "1.263",
                change: "+0.12%",
                isPositive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Componente reutilizable para cada divisa
  Widget _buildCurrencyTile({
    required String iconSymbol,
    required String pair,
    required String subtext,
    required String price,
    required String change,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  iconSymbol,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0052FF),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pair,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1C1E)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtext,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1C1E)),
              ),
              const SizedBox(height: 2),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}