import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get pixabayApiKey => _require('PIXABAY_API_KEY');
  static String get openRouterApiKey => _require('OPENROUTER_API_KEY');

  static bool get hasPixabayKey {
    final value = dotenv.env['PIXABAY_API_KEY']?.trim() ?? '';
    return value.isNotEmpty;
  }

  static String _require(String key) {
    final value = dotenv.env[key]?.trim() ?? '';
    if (value.isEmpty) {
      throw StateError(
        'Falta configurar $key en el archivo .env.',
      );
    }
    return value;
  }
}
