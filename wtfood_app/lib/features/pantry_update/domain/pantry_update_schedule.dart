enum PantryUpdateSchedule {
  daily,
  everyTwoDays,
  weekly,
  never;

  String get storageKey {
    switch (this) {
      case PantryUpdateSchedule.daily:
        return 'daily';
      case PantryUpdateSchedule.everyTwoDays:
        return 'every_two_days';
      case PantryUpdateSchedule.weekly:
        return 'weekly';
      case PantryUpdateSchedule.never:
        return 'never';
    }
  }

  String get title {
    switch (this) {
      case PantryUpdateSchedule.daily:
        return 'Todos los dias';
      case PantryUpdateSchedule.everyTwoDays:
        return 'Cada dos dias';
      case PantryUpdateSchedule.weekly:
        return 'Una vez a la semana';
      case PantryUpdateSchedule.never:
        return 'Nunca';
    }
  }

  String get settingsSummary {
    switch (this) {
      case PantryUpdateSchedule.daily:
        return 'Te recordaremos revisar tu nevera todos los dias.';
      case PantryUpdateSchedule.everyTwoDays:
        return 'Te recordaremos revisar tu nevera cada dos dias.';
      case PantryUpdateSchedule.weekly:
        return 'Te recordaremos revisar tu nevera una vez por semana.';
      case PantryUpdateSchedule.never:
        return 'No recibiras recordatorios para actualizar tu nevera.';
    }
  }

  String get confirmationMessage {
    switch (this) {
      case PantryUpdateSchedule.daily:
        return 'Recibiras un recordatorio diario.';
      case PantryUpdateSchedule.everyTwoDays:
        return 'Recibiras un recordatorio cada dos dias.';
      case PantryUpdateSchedule.weekly:
        return 'Recibiras un recordatorio semanal.';
      case PantryUpdateSchedule.never:
        return 'Has desactivado los recordatorios de despensa.';
    }
  }

  Duration? get interval {
    switch (this) {
      case PantryUpdateSchedule.daily:
        return const Duration(days: 1);
      case PantryUpdateSchedule.everyTwoDays:
        return const Duration(days: 2);
      case PantryUpdateSchedule.weekly:
        return const Duration(days: 7);
      case PantryUpdateSchedule.never:
        return null;
    }
  }

  bool get isEnabled => interval != null;

  static PantryUpdateSchedule fromStorageKey(String? value) {
    switch (value) {
      case 'daily':
        return PantryUpdateSchedule.daily;
      case 'weekly':
        return PantryUpdateSchedule.weekly;
      case 'never':
        return PantryUpdateSchedule.never;
      case 'every_two_days':
      default:
        return PantryUpdateSchedule.everyTwoDays;
    }
  }
}
