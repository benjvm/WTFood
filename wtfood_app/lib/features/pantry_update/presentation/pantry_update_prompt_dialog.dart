import 'package:flutter/material.dart';

class PantryUpdatePromptDialog extends StatelessWidget {
  const PantryUpdatePromptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Actualizacion de despensa'),
      content: const Text(
        'Quieres actualizar tu nevera en 20 segundos?\n\nEscanea tus alimentos para mantener tus ingredientes al dia.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Actualizar'),
        ),
      ],
    );
  }
}
