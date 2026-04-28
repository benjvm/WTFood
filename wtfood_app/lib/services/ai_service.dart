import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/env.dart';

/// Servicio centralizado para todas las llamadas a la IA via OpenRouter.
///
/// OpenRouter expone una API REST compatible con el estándar de OpenAI,
/// por lo que no se necesita ningún SDK externo, solo `http`.
///
/// Modelos usados:
/// - Análisis de imagen  → google/gemini-2.5-flash  (vision)
/// - Generación de receta → google/gemini-2.5-flash  (texto, JSON)
///
/// Cambia los valores de [_modelVision] y [_modelText] para usar
/// cualquier otro modelo disponible en OpenRouter sin tocar las screens.
class AiService {
  const AiService._();
  static const AiService instance = AiService._();

  // ── Configuración ─────────────────────────────────────────────────────────
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  /// Modelo con capacidad de visión (para analizar la foto de ingredientes).
  static const String _modelVision = 'google/gemini-2.5-flash-lite-preview-09-2025';

  /// Modelo de texto (para generar la receta en JSON).
  static const String _modelText = 'google/gemini-2.5-flash-lite-preview-09-2025';

  // ── Método privado: llamada genérica a OpenRouter ─────────────────────────
  Future<String> _call({
    required String model,
    required List<Map<String, dynamic>> messages,
    double temperature = 0.5,
    int maxTokens = 2048,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer ${AppEnv.openRouterApiKey}',
        'Content-Type': 'application/json',
        // Cabeceras opcionales recomendadas por OpenRouter para analytics
        'HTTP-Referer': 'https://tu-app.com',
        'X-Title': 'FridgeAI',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
        // Pedimos respuesta JSON estructurada (compatible con OpenAI JSON mode)
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'OpenRouter error ${response.statusCode}: ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        body['choices']?[0]?['message']?['content'] as String?;

    if (content == null || content.isEmpty) {
      throw Exception('La IA devolvió una respuesta vacía.');
    }

    return content;
  }

  // ── 1. Analizar imagen y extraer ingredientes ─────────────────────────────
  /// Recibe los [imageBytes] de la foto y la extensión del archivo
  /// ([mimeType] como `image/jpeg` o `image/png`) y devuelve la lista
  /// de ingredientes identificados.
  Future<List<String>> analyzeIngredients({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    final base64Image = base64Encode(imageBytes);

    final rawJson = await _call(
      model: _modelVision,
      temperature: 0.2,
      maxTokens: 512,
      messages: [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text':
                  'Analiza esta imagen de alimentos y devuelve ÚNICAMENTE un objeto JSON '
                  'con la clave "ingredientes" que contenga un array de strings con los '
                  'ingredientes que identifiques. Si no ves alimentos, devuelve el array vacío. '
                  'Ejemplo: {"ingredientes": ["tomate", "cebolla", "pimiento"]}',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:$mimeType;base64,$base64Image',
              },
            },
          ],
        },
      ],
    );

    final parsed = jsonDecode(rawJson) as Map<String, dynamic>;
    return List<String>.from(parsed['ingredientes'] ?? []);
  }

  // ── 2. Generar receta a partir de ingredientes ────────────────────────────
  /// Recibe la [ingredientsList] separada por comas y devuelve el mapa
  /// JSON con la estructura completa de la receta.
  Future<Map<String, dynamic>> generateRecipe(String ingredientsList) async {
    const schema = '''
{
  "nombre": "string - nombre del plato",
  "descripcion": "string - descripción apetitosa de 2-3 frases",
  "tiempo_preparacion": "string - ej: 15 min",
  "tiempo_coccion": "string - ej: 30 min",
  "porciones": "integer - número de porciones",
  "dificultad": "string - Fácil | Media | Difícil",
  "ingredientes": [
    { "cantidad": "string", "unidad": "string", "nombre": "string" }
  ],
  "pasos": ["string"],
  "consejos": "string - tip del chef"
}''';

    final rawJson = await _call(
      model: _modelText,
      temperature: 0.7,
      maxTokens: 2048,
      messages: [
        {
          'role': 'system',
          'content':
              'Eres un chef profesional. Responde ÚNICAMENTE con un objeto JSON '
              'que siga exactamente este esquema, sin texto adicional:\n$schema',
        },
        {
          'role': 'user',
          'content':
              'Con los siguientes ingredientes: $ingredientsList, '
              'crea una receta detallada y deliciosa.',
        },
      ],
    );

    return jsonDecode(rawJson) as Map<String, dynamic>;
  }
}
