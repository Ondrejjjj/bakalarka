import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import 'package:bakalarka/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final BiometricService _biometricService = BiometricService();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _icoController = TextEditingController();
  final _inviteCodeController = TextEditingController(); // Kód pre technika

  bool _isRegistering = false;
  bool _isTechnician = true; // Defaultne prepnuté na technika pri registrácii
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _canCheckBiometrics = false;

  bool _has8Chars = false;
  bool _hasUppercase = false;
  bool _hasDigits = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  void _checkBiometrics() async {
    try {
      bool available = await _biometricService.isBiometricAvailable();
      if (mounted) {
        setState(() => _canCheckBiometrics = available);
      }
    } catch (e) {
      if (mounted) setState(() => _canCheckBiometrics = false);
    }
  }

  Future<void> _showBiometricActivationDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Biometria dostupná"),
        content: const Text("Vaše údaje boli uložené. Nabudúce sa môžete prihlásiť odtlačkom prsta."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goToHome();
            },
            child: const Text("Rozumiem"),
          ),
        ],
      ),
    );
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
  }

  Future<void> _saveCredentials() async {
    try {
      await _storage.write(key: 'user_email', value: _emailController.text.trim());
      await _storage.write(key: 'user_password', value: _passwordController.text.trim());
    } catch (e) {
      print("Chyba ukladania: $e");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- UPRAVENÁ LOGIKA AUTENTIFIKÁCIE ---
  void _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isRegistering) {
        if (_isTechnician) {
          // A. REGISTRÁCIA TECHNIKA (Cez kód)
          await _auth.registerTechnician(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            inviteCode: _inviteCodeController.text.trim(),
          );
        } else {
          // B. REGISTRÁCIA ADMINA (Nová firma)
          await _auth.registerAdminAndCompany(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            companyName: _companyNameController.text.trim(),
            ico: _icoController.text.trim(),
          );
        }

        await _saveCredentials();
        if (_canCheckBiometrics) {
          await _showBiometricActivationDialog();
        } else {
          _goToHome();
        }

      } else {
        // C. KLASICKÉ PRIHLÁSENIE
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await _saveCredentials();
        _goToHome();
      }
    } catch (e) {
      _showSnack(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleBiometricLogin() async {
    try {
      bool authenticated = await _biometricService.authenticate();
      if (authenticated) {
        String? savedEmail = await _storage.read(key: 'user_email');
        String? savedPassword = await _storage.read(key: 'user_password');

        if (savedEmail != null && savedPassword != null) {
          setState(() => _isLoading = true);
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: savedEmail,
            password: savedPassword,
          );
          _goToHome();
        } else {
          _showSnack("Najprv sa musíte prihlásiť manuálne.");
        }
      }
    } catch (e) {
      _showSnack("Biometria zlyhala.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.lock_person_rounded, size: 80, color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  _isRegistering
                      ? (_isTechnician ? "Registrácia technika" : "Založiť firmu")
                      : "Vitajte v Trezore",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // PREPÍNAČ ADMIN / TECHNIK (zobrazí sa len pri registrácii)
                if (_isRegistering) _buildRoleToggle(),

                const SizedBox(height: 24),

                // EMAIL
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                  validator: (value) => (value == null || !value.contains('@')) ? "Zadajte platný email" : null,
                ),
                const SizedBox(height: 16),

                // HESLO
                _buildPasswordField(),

                // DYNAMICKÉ POLIA PODĽA ROLE
                if (_isRegistering) ...[
                  const SizedBox(height: 16),
                  if (_isTechnician)
                    _buildNormalField(_inviteCodeController, "Kód od admina (6 miestny)", Icons.vpn_key_rounded)
                  else ...[
                    _buildNormalField(_companyNameController, "Názov firmy", Icons.business_rounded),
                    const SizedBox(height: 16),
                    _buildNormalField(_icoController, "IČO", Icons.numbers_rounded),
                  ],
                ],

                const SizedBox(height: 32),

                // TLAČIDLÁ
                _isLoading
                    ? const CircularProgressIndicator()
                    : Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _handleAuth,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(_isRegistering ? "Registrovať" : "Prihlásiť sa"),
                      ),
                    ),
                    if (!_isRegistering && _canCheckBiometrics) ...[
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        onPressed: _handleBiometricLogin,
                        icon: const Icon(Icons.fingerprint, size: 32),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(60, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegistering = !_isRegistering;
                      _formKey.currentState?.reset();
                    });
                  },
                  child: Text(_isRegistering ? "Už máte účet? Prihláste sa" : "Nový v systéme? Zaregistrujte sa"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Prepínač medzi technikom a adminom
  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _toggleButton("Som Technik", _isTechnician, () => setState(() => _isTechnician = true)),
          ),
          Expanded(
            child: _toggleButton("Som Admin", !_isTechnician, () => setState(() => _isTechnician = false)),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // --- ZVYŠOK POMOCNÝCH WIDGETOV ---
  Widget _buildPasswordField() {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: (value) {
            setState(() {
              _has8Chars = value.length >= 8;
              _hasUppercase = value.contains(RegExp(r'[A-Z]'));
              _hasDigits = value.contains(RegExp(r'[0-9]'));
              _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
            });
          },
          decoration: _inputDecoration("Heslo", Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) => (value == null || value.isEmpty) ? "Zadajte heslo" : null,
        ),
        if (_isRegistering) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _buildValidationChip("8+ znakov", _has8Chars),
              _buildValidationChip("A-Z", _hasUppercase),
              _buildValidationChip("0-9", _hasDigits),
              _buildValidationChip("!@#", _hasSpecialChar),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildValidationChip(String label, bool isValid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isValid ? Colors.green : Colors.grey.shade400),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isValid ? Icons.check : Icons.close, size: 14, color: isValid ? Colors.green : Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isValid ? Colors.green.shade700 : Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildNormalField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
      validator: (value) => (value == null || value.isEmpty) ? "Povinné pole" : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
    );
  }
}