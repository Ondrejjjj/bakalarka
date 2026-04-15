import 'package:bakalarka/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/sync_service.dart'; // PRIDANÉ: Import SyncService
import 'package:bakalarka/main.dart';
import 'package:bakalarka/database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final BiometricService _biometricService = BiometricService();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _icoController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  bool _isRegistering = false;
  bool _isTechnician = true;
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

  // Pomocná metóda na získanie AuthService
  AuthService _getAuthService() {
    final database = Provider.of<AppDatabase>(context, listen: false);
    return AuthService(database);
  }


  Future<void> _startSyncProcess() async {
    final database = Provider.of<AppDatabase>(context, listen: false);
    final syncService = SyncService(database);


    await syncService.restoreAllUserData();

    await syncService.startLiveSync();
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

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      final authService = _getAuthService();

      if (_isRegistering) {
        if (_isTechnician) {
          await authService.registerTechnician(
            email: email,
            password: password,
            inviteCode: _inviteCodeController.text.trim(),
          );
        } else {
          await authService.registerAdminAndCompany(
            email: email,
            password: password,
            companyName: _companyNameController.text.trim(),
            ico: _icoController.text.trim(),
          );
        }
      } else {
        await authService.signIn(email, password);
      }

      await _storage.write(key: 'user_password', value: password);

      // --- PRIDANÉ: Spustenie synchronizácie po úspešnom prihlásení ---
      await _startSyncProcess();

      if (_isRegistering && _canCheckBiometrics) {
        await _showBiometricActivationDialog();
      } else {
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
      String? savedEmail = await _storage.read(key: 'user_email');
      String? savedPassword = await _storage.read(key: 'user_password');

      if (savedEmail != null && savedPassword != null) {
        bool authenticated = await _biometricService.authenticate();
        if (authenticated) {
          setState(() => _isLoading = true);
          final authService = _getAuthService();
          await authService.signIn(savedEmail, savedPassword);

          // --- PRIDANÉ: Spustenie synchronizácie po biometrickom prihlásení ---
          await _startSyncProcess();

          _goToHome();
        }
      } else {
        _showSnack(S.of(context).najprvManualne);
      }
    } catch (e) {
      _showSnack(S.of(context).biometriaZlyhala);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showBiometricActivationDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).biometriaTitle),
        content: Text(S.of(context).biometriaContent),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goToHome();
            },
            child: Text(S.of(context).rozumiem),
          ),
        ],
      ),
    );
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
                      ? (_isTechnician ? S.of(context).registrTV : S.of(context).zalozFV)
                      : S.of(context).nadpisV,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                if (_isRegistering) _buildRoleToggle(),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                  validator: (value) => (value == null || !value.contains('@')) ? S.of(context).zadajteEmail : null,
                ),
                const SizedBox(height: 16),

                _buildPasswordField(),

                if (_isRegistering) ...[
                  const SizedBox(height: 16),
                  if (_isTechnician)
                    _buildNormalField(_inviteCodeController, S.of(context).kodOdAdmina, Icons.vpn_key_rounded)
                  else ...[
                    _buildNormalField(_companyNameController, S.of(context).nazovFV, Icons.business_rounded),
                    const SizedBox(height: 16),
                    _buildNormalField(_icoController, "IČO", Icons.numbers_rounded),
                  ],
                ],

                const SizedBox(height: 32),

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
                        child: Text(_isRegistering ? S.of(context).registrV : S.of(context).prihlasV),
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
                  child: Text(_isRegistering ? S.of(context).uzmateUV : S.of(context).RegistraciaV),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- POMOCNÉ METÓDY PRE UI ---

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
            child: _toggleButton(S.of(context).somTV, _isTechnician, () => setState(() => _isTechnician = true)),
          ),
          Expanded(
            child: _toggleButton(S.of(context).somAV, !_isTechnician, () => setState(() => _isTechnician = false)),
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
          decoration: _inputDecoration(S.of(context).hesloV, Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) => (value == null || value.isEmpty) ? S.of(context).zadajteHeslo : null,
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
      validator: (value) => (value == null || value.isEmpty) ? S.of(context).povinnePole : null,
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