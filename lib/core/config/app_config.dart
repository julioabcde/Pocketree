
import 'dart:io';

import 'package:pocketree/core/config/environment.dart';

/// Konfigurasi aplikasi untuk mengatur environment, base URL, dan timeout
/// 
///  Environment:
///  - Development: localhost (Android Emulator: 10.0.2.2, Physical Device: sesuai IP lokal)
///  - Staging: staging-api.pocketree.com
///  - Production: api.pocketree.com
class AppConfig {
  static const Environment currentEnvironment = Environment.development;

  static const Map<Environment, String> _baseUrls = {
    Environment.development: 'http://localhost:8000',
    Environment.staging: 'https://staging-api.pocketree.com',
    Environment.production: 'https://api.pocketree.com',
  };

  static const String androidEmulatorHost = 'http://10.0.2.2:8000';
  static const String physicalDeviceHost = 'http://192.168.1.100:8000';

  static String getBaseUrl() {
    final baseUrl = _baseUrls[currentEnvironment]!;

    if (currentEnvironment == Environment.development) {
      return _getDevelopmentUrl();
    }

    return baseUrl;
  }

  static String _getDevelopmentUrl() {
    if (Platform.isAndroid) {
      return androidEmulatorHost;
    }

    if (Platform.isIOS) {
      return 'http://localhost:8000';
    }

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://localhost:8000';
    }

    return 'http://localhost:8000';
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String apiVersion = 'v1';

  static const bool enableLogging = true;
  static const bool enableCrashReporting = false;
}