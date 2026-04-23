import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; 
import '../../../core/env.dart';
import '../../../core/constants.dart';
import 'ingredients_review_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _errorMessage;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Image picking (Sin cambios) ────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    setState(() => _errorMessage = null);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked == null) return;
      setState(() => _selectedImage = File(picked.path));
    } catch (e) {
      setState(() => _errorMessage =
          'No se pudo acceder a la ${source == ImageSource.camera ? 'cámara' : 'galería'}.');
    }
  }

  // ── LOGICA ACTUALIZADA: Gemini SDK + JSON Mode ─────────
  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      // 1. Preparamos la imagen
      final imageBytes = await _selectedImage!.readAsBytes();
      final extension = _selectedImage!.path.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
      
      final imagePart = DataPart(mimeType, imageBytes);
      final promptPart = TextPart(
          'Analiza esta imagen de alimentos y devuelve una lista de los ingredientes que identifiques. Si no ves alimentos, devuelve una lista vacía.');

      // 2. Definimos el ESQUEMA (El truco para que nunca falle el JSON)
      final responseSchema = Schema.object(
        properties: {
          'ingredientes': Schema.array(
            description: 'Lista de ingredientes identificados',
            items: Schema.string(),
          ),
        },
        requiredProperties: ['ingredientes'],
      );

      // 3. Inicializamos el modelo de IA
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: AppEnv.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          // Forzamos a que responda SOLO el JSON con nuestra estructura
          responseMimeType: 'application/json',
          responseSchema: responseSchema,
        ),
      );

      // 4. Hacemos la petición
      final response = await model.generateContent([
        Content.multi([promptPart, imagePart])
      ]);

      if (response.text == null) {
        throw Exception('La IA no devolvió texto.');
      }

      // 5. Parseamos directamente (ya no necesitamos limpiar Markdown)
      final parsed = jsonDecode(response.text!);
      final ingredientes = List<String>.from(parsed['ingredientes'] ?? []);

      if (!mounted) return;

      if (ingredientes.isEmpty) {
        setState(() {
          _errorMessage =
              'No se detectaron ingredientes. Intenta con otra imagen.';
          _isAnalyzing = false;
        });
        return;
      }

      setState(() => _isAnalyzing = false);

      // Navegamos a la siguiente pantalla
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IngredientsReviewScreen(
            ingredients: ingredientes,
            imageFile: _selectedImage!,
          ),
        ),
      );
    } catch (e) {
      // ESTO ES VITAL: Imprime el error real en la consola de debug
      print('DEBUG ERROR GEMINI: $e'); 
      
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error real: ${e.toString()}'; // Temporalmente muestra el error en pantalla
        _isAnalyzing = false;
      });
    }
  }

  // ── UI (El resto de tu código queda exactamente igual) ──
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '¿Qué tienes en la nevera? 🥦',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Haz una foto o sube una imagen y la IA identificará los ingredientes automáticamente.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              _ImagePreviewCard(
                image: _selectedImage,
                pulseAnimation: _pulseAnimation,
                isAnalyzing: _isAnalyzing,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_camera_rounded,
                      label: 'Cámara',
                      onTap: _isAnalyzing
                          ? null
                          : () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Galería',
                      onTap: _isAnalyzing
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                _ErrorBanner(message: _errorMessage!),
              if (_errorMessage != null) const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: _selectedImage != null ? 1.0 : 0.45,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: (_selectedImage != null && !_isAnalyzing)
                        ? _analyzeImage
                        : null,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(
                      _isAnalyzing ? 'Analizando...' : 'Analizar ingredientes',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      disabledForegroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMd),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const _TipsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Sub-widgets
// ─────────────────────────────────────────────────────────

class _ImagePreviewCard extends StatelessWidget {
  final File? image;
  final Animation<double> pulseAnimation;
  final bool isAnalyzing;
  final VoidCallback onTap;

  const _ImagePreviewCard({
    required this.image,
    required this.pulseAnimation,
    required this.isAnalyzing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAnalyzing ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
          border: Border.all(
            color: image != null
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.outline,
            width: image != null ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: image != null ? 0.08 : 0.0),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg - 2),
          child: image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(image!, fit: BoxFit.cover),
                    if (isAnalyzing)
                      Container(
                        color: AppColors.onSurface.withValues(alpha: 0.45),
                        child: Center(
                          child: ScaleTransition(
                            scale: pulseAnimation,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: AppColors.onPrimary,
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Identificando ingredientes…',
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Toca para añadir imagen',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'JPG o PNG',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  const _TipsSection();

  @override
  Widget build(BuildContext context) {
    final tips = [
      (Icons.wb_sunny_rounded, 'Buena iluminación', 'La imagen debe tener buena luz natural o artificial.'),
      (Icons.grid_view_rounded, 'Ingredientes visibles', 'Coloca los ingredientes separados y bien visibles.'),
      (Icons.crop_rounded, 'Encuadre cercano', 'Acércate para que los ingredientes ocupen la imagen.'),
    ];

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consejos para mejores resultados',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusSm),
                    ),
                    child: Icon(tip.$1, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.$2,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          tip.$3,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
