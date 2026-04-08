import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dljlibyya';
  static const String _uploadPreset = 'WTFood_users';

  Future<String> uploadProfileImage(File imageFile) async {
    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      throw Exception(
        'Faltan las credenciales de Cloudinary. '
        'Configura CLOUDINARY_CLOUD_NAME y CLOUDINARY_UPLOAD_PRESET.',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Error al subir la imagen (${response.statusCode}): $responseBody',
      );
    }

    final Map<String, dynamic> jsonMap =
        jsonDecode(responseBody) as Map<String, dynamic>;
    final secureUrl = jsonMap['secure_url'] as String?;

    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary no devolvio una secure_url valida.');
    }

    return secureUrl;
  }
}
