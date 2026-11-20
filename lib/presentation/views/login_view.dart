import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isLoginMode = true; // Alterna entre Iniciar Sesión y Registrarse
  bool _isLoading = false;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registrar usuario en Firebase Authentication
  Future<void> _registrarUsuario() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje("Por favor completa todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _mostrarMensaje("¡Cuenta creada con éxito en Firebase!");
      setState(() {
        _isLoginMode = true;
        _passwordController.clear();
      });
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error al registrarse: ${e.message}";
      if (e.code == 'weak-password') mensaje = "La contraseña es muy débil (mínimo 6 caracteres).";
      if (e.code == 'email-already-in-use') mensaje = "El correo ya está registrado.";
      if (e.code == 'invalid-email') mensaje = "El formato del correo no es válido.";
      _mostrarMensaje(mensaje);
    } catch (e) {
      _mostrarMensaje("Error inesperado: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Iniciar sesión validando en la nube
  Future<void> _iniciarSesion() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje("Por favor ingresa tus datos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Redirige al contenedor principal de la aplicación de finanzas
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainContainerScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error al iniciar sesión: ${e.message}";
      if (e.code == 'user-not-found') mensaje = "No existe un usuario con este correo.";
      if (e.code == 'wrong-password') mensaje = "Contraseña incorrecta.";
      if (e.code == 'invalid-credential') mensaje = "Correo o contraseña incorrectos.";
      _mostrarMensaje(mensaje);
    } catch (e) {
      _mostrarMensaje("Error inesperado: $e");
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0052FF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFF0052FF),
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isLoginMode ? "Finanzas Inteligentes" : "Crea tu Cuenta Cloud",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Casa de Divisas & IA",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Selector Login / Registro
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => setState(() => _isLoginMode = true),
                          style: TextButton.styleFrom(
                            backgroundColor: _isLoginMode ? Colors.white : Colors.transparent,
                            foregroundColor: _isLoginMode ? const Color(0xFF0052FF) : Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Iniciar Sesión", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => setState(() => _isLoginMode = false),
                          style: TextButton.styleFrom(
                            backgroundColor: !_isLoginMode ? Colors.white : Colors.transparent,
                            foregroundColor: !_isLoginMode ? const Color(0xFF0052FF) : Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Registrarse", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0052FF)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0052FF)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: _isLoading ? null : (_isLoginMode ? _iniciarSesion : _registrarUsuario),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isLoginMode ? "Entrar a la Plataforma" : "Registrarme Ahora",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}