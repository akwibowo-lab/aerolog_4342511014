import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../viewmodels/aerolog_viewmodel.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final AeroLogViewModel viewModel;
  const LoginScreen({super.key, required this.viewModel});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Akut Wibowo');
  final _callsignController = TextEditingController(text: 'JDB-4342511014');
  final _pinController = TextEditingController();
  bool _obscurePin = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _nameController.dispose();
    _callsignController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    try {
      if (_formKey.currentState!.validate()) {
        widget.viewModel.login(
          _nameController.text,
          _callsignController.text,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DashboardScreen(viewModel: widget.viewModel),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Validasi Gagal: Mohon lengkapi identitas dan PIN Keamanan Pilot!',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan autentikasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _quickGuestLogin() {
    widget.viewModel.login('Pilot Tamu', 'GUEST-01');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(viewModel: widget.viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.radar_rounded,
                          size: 56,
                          color: AppTheme.primaryNavy,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Autentikasi Pilot AeroLog',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Masuk menggunakan Callsign Remote Pilot untuk mengelola misi penerbangan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap Pilot',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nama Pilot tidak boleh kosong!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _callsignController,
                          decoration: const InputDecoration(
                            labelText: 'Callsign / NIM Pilot',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Callsign / NIM wajib diisi!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pinController,
                          obscureText: _obscurePin,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'PIN Keamanan (Min. 4 Digit)',
                            hintText: 'Contoh: 1234',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePin
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => _obscurePin = !_obscurePin);
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'PIN Keamanan wajib diisi!';
                            }
                            if (val.trim().length < 4) {
                              return 'PIN minimal terdiri dari 4 karakter!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? true),
                          title: const Text(
                            'Ingat sesi penerbangan saya',
                            style: TextStyle(fontSize: 13),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _submitLogin,
                          icon: const Icon(Icons.login_rounded),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'Masuk ke Beranda Misi',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _quickGuestLogin,
                          child: const Text('Masuk Cepat sebagai Observer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
