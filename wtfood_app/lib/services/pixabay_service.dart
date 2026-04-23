import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wtfood_app/core/env.dart';

class PixabayPhoto {
  const PixabayPhoto({
    required this.imageUrl,
    required this.pageUrl,
    required this.author,
  });

  final String imageUrl;
  final String pageUrl;
  final String author;

  factory PixabayPhoto.fromJson(Map<String, dynamic> json) {
    return PixabayPhoto(
      imageUrl: (json['webformatURL'] as String? ?? '').trim(),
      pageUrl: (json['pageURL'] as String? ?? '').trim(),
      author: (json['user'] as String? ?? 'Pixabay').trim(),
    );
  }
}

class PixabayService {
  const PixabayService();

  Future<PixabayPhoto?> findRecipePhoto(String recipeName) async {
    try {
      final query = recipeName.trim();
      if (query.isEmpty || !AppEnv.hasPixabayKey) {
        return null;
      }

      final uri = Uri.https(
        'pixabay.com',
        '/api/',
        {
          'key': AppEnv.pixabayApiKey,
          'q': query,
          'lang': 'es',
          'image_type': 'photo',
          'category': 'food',
          'safesearch': 'true',
          'per_page': '3',
          'order': 'popular',
        },
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception(
          'Pixabay devolvio ${response.statusCode}: ${response.body}',
        );
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final hits = (payload['hits'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      if (hits.isEmpty) {
        return null;
      }

      final photo = PixabayPhoto.fromJson(hits.first);
      if (photo.imageUrl.isEmpty) {
        return null;
      }
      return photo;
    } catch (error, stackTrace) {
      debugPrint('PixabayService error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }
}
