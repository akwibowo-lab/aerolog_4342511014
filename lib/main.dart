import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'viewmodels/aerolog_viewmodel.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AeroLogApp());
}

class AeroLogApp extends StatefulWidget {
  const AeroLogApp({super.key});

  @override
  State<AeroLogApp> createState() => _AeroLogAppState();
}

class _AeroLogAppState extends State<AeroLogApp> {
  // Instance ViewModel disimpan pada root state agar tahan terhadap rotasi layar
  final AeroLogViewModel _viewModel = AeroLogViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroLog - Drone Mission & Flight Log',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(viewModel: _viewModel),
    );
  }
}
