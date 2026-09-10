import 'package:flutter/material.dart';
import 'core/services/app_bootstrapper.dart';

void main() {
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();
  
  // Launch the unified AppBootstrapper which handles:
  // 1. System Initialization (Firebase, DI, Hive, AppConfig)
  // 2. Onboarding Status Check
  // 3. Auth Session Restoration
  // 4. Core App UI & Providers
  runApp(const AppBootstrapper());
}
