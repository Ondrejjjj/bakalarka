import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();

  // Kontroléry pre textové polia
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _icoController = TextEditingController();

  bool _isRegistering = false; // Prepínač medzi Loginom a Registráciou

  void _handleAuth() async {
    if (_isRegistering) {
      // Registrácia novej firmy (Admin)
      await _auth.registerAdminAndCompany(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        companyName: _companyNameController.text.trim(),
        ico: _icoController.text.trim(),
      );
      _showSnack("Firma úspešne zaregistrovaná!");
    } else {
      // Tu by išlo klasické prihlásenie (zatiaľ len print pre test)
      print("Prihlasujem: ${_emailController.text}");
      _showSnack("Pokus o prihlásenie...");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikona a názov
              Icon(Icons.lock_person_rounded, size: 80, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                _isRegistering ? "Založiť firmu" : "Vitajte v Trezore",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),

              // Spoločné polia: Email a Heslo
              _buildTextField(_emailController, "Email", Icons.email_outlined, false),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, "Heslo", Icons.lock_outline, true),

              // Polia navyše, ak sa registruje FIRMA
              if (_isRegistering) ...[
                const SizedBox(height: 16),
                _buildTextField(_companyNameController, "Názov firmy", Icons.business_rounded, false),
                const SizedBox(height: 16),
                _buildTextField(_icoController, "IČO", Icons.numbers_rounded, false),
              ],

              const SizedBox(height: 32),

              // Hlavné tlačidlo
              FilledButton(
                onPressed: _handleAuth,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_isRegistering ? "Vytvoriť firemný účet" : "Prihlásiť sa"),
              ),

              const SizedBox(height: 16),

              // Prepínač medzi Loginom a Registráciou
              TextButton(
                onPressed: () => setState(() => _isRegistering = !_isRegistering),
                child: Text(_isRegistering
                    ? "Už máte účet? Prihláste sa"
                    : "Nová firma? Zaregistrujte sa tu"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pomocná funkcia pre pekný Material 3 TextField
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
    );
  }
}