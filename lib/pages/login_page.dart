import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import 'package:bakalarka/main.dart'; // Skontroluj, či sa tvoja Home trieda volá MyHomePage alebo HomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final BiometricService _biometricService = BiometricService();

  // Nastavenie pre Android, aby to nepadalo na šifrovaní
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _icoController = TextEditingController();

  bool _isRegistering = false;
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

  // Bezpečné overenie dostupnosti biometrie (aby appka nespadla na štarte)
  void _checkBiometrics() async {
    try {
      bool available = await _biometricService.isBiometricAvailable();
      if (mounted) {
        setState(() => _canCheckBiometrics = available);
      }
    } catch (e) {
      print("Chyba biometrie pri štarte (ignoring): $e");
      if (mounted) {
        setState(() => _canCheckBiometrics = false);
      }
    }
  }

  // --- DIALÓG UŽ LEN OZNAMUJE MOŽNOSŤ ---
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
    // Tu si daj pozor na názov triedy, v main.dart máš asi MyHomePage alebo HomePage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
  }

  // --- KĽÚČOVÁ ZMENA: Ukladáme hneď ---
  Future<void> _saveCredentials() async {
    try {
      await _storage.write(key: 'user_email', value: _emailController.text.trim());
      await _storage.write(key: 'user_password', value: _passwordController.text.trim());
      print("DEBUG: Údaje úspešne uložené do SecureStorage");
    } catch (e) {
      print("DEBUG: Chyba pri ukladaní údajov: $e");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- LOGIKA PRIHLÁSENIA / REGISTRÁCIE ---
  void _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isRegistering) {
        // 1. Registrácia vo Firebase
        await _auth.registerAdminAndCompany(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          companyName: _companyNameController.text.trim(),
          ico: _icoController.text.trim(),
        );

        // 2. OKAMŽITÉ ULOŽENIE ÚDAJOV
        await _saveCredentials();

        // 3. Rozhodnutie kam ďalej
        if (_canCheckBiometrics) {
          await _showBiometricActivationDialog();
        } else {
          _goToHome();
        }

      } else {
        // 1. Prihlásenie vo Firebase
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // 2. OKAMŽITÉ ULOŽENIE ÚDAJOV (Update hesla ak sa zmenilo)
        await _saveCredentials();

        // 3. Rozhodnutie kam ďalej
        // Ak už raz máme biometriu "aktivovanú" (vieme to zistiť, alebo len proste ideme ďalej)
        // Pre jednoduchosť - ak je dostupná a sme tu prvýkrát, môžeme ukázať dialóg,
        // ale pre plynulosť poďme rovno domov.
        _goToHome();
      }
    } catch (e) {
      _showSnack("Chyba: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- BIOMETRICKÉ PRIHLÁSENIE ---
  void _handleBiometricLogin() async {
    try {
      // 1. Najprv overíme odtlačok
      bool authenticated = await _biometricService.authenticate();

      if (authenticated) {
        // 2. Ak je odtlačok OK, vytiahneme údaje
        String? savedEmail = await _storage.read(key: 'user_email');
        String? savedPassword = await _storage.read(key: 'user_password');

        if (savedEmail != null && savedPassword != null) {
          setState(() => _isLoading = true);
          // 3. Prihlásime do Firebase na pozadí
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: savedEmail,
            password: savedPassword,
          );
          // 4. Ideme dnu
          _goToHome();
        } else {
          _showSnack("Najprv sa musíte aspoň raz prihlásiť manuálne.");
        }
      }
    } catch (e) {
      // Tu zachytíme tú nešťastnú chybu "List<Object?>", ak by nastala
      print("Biometria chyba: $e");
      _showSnack("Biometria zlyhala alebo nie je nastavená.");
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
                  _isRegistering ? "Založiť firmu" : "Vitajte v Trezore",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

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

                if (_isRegistering) ...[
                  const SizedBox(height: 16),
                  _buildNormalField(_companyNameController, "Názov firmy", Icons.business_rounded),
                  const SizedBox(height: 16),
                  _buildNormalField(_icoController, "IČO", Icons.numbers_rounded),
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
                    // Tlačidlo odtlačku sa zobrazí len ak je biometria dostupná
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
                  child: Text(_isRegistering ? "Už máte účet? Prihláste sa" : "Nová firma? Zaregistrujte sa tu"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- POMOCNÉ WIDGETY ---
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