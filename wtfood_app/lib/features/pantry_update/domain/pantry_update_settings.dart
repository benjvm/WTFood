import 'package:cloud_firestore/cloud_firestore.dart';

import 'pantry_update_schedule.dart';

class PantryUpdateSettings {
  const PantryUpdateSettings({
    this.schedule = PantryUpdateSchedule.everyTwoDays,
    this.lastScanAt,
    this.lastPromptAt,
  });

  final PantryUpdateSchedule schedule;
  final DateTime? lastScanAt;
  final DateTime? lastPromptAt;

  factory PantryUpdateSettings.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return const PantryUpdateSettings();
    }

    return PantryUpdateSettings(
      schedule: PantryUpdateSchedule.fromStorageKey(
        data['schedule'] as String?,
      ),
      lastScanAt: _parseDateTime(data['lastScanAt']),
      lastPromptAt: _parseDateTime(data['lastPromptAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'schedule': schedule.storageKey,
    'lastScanAt': lastScanAt == null ? null : Timestamp.fromDate(lastScanAt!),
    'lastPromptAt': lastPromptAt == null
        ? null
        : Timestamp.fromDate(lastPromptAt!),
  };

  PantryUpdateSettings copyWith({
    PantryUpdateSchedule? schedule,
    DateTime? lastScanAt,
    bool clearLastScanAt = false,
    DateTime? lastPromptAt,
    bool clearLastPromptAt = false,
  }) {
    return PantryUpdateSettings(
      schedule: schedule ?? this.schedule,
      lastScanAt: clearLastScanAt ? null : (lastScanAt ?? this.lastScanAt),
      lastPromptAt: clearLastPromptAt
          ? null
          : (lastPromptAt ?? this.lastPromptAt),
    );
  }

  bool shouldShowPrompt({DateTime? now}) {
    final interval = schedule.interval;
    final lastScanAt = this.lastScanAt;

    if (interval == null || lastScanAt == null) {
      return false;
    }

    final currentTime = now ?? DateTime.now();
    if (currentTime.isBefore(lastScanAt.add(interval))) {
      return false;
    }

    final lastPromptAt = this.lastPromptAt;
    if (lastPromptAt == null || lastPromptAt.isBefore(lastScanAt)) {
      return true;
    }

    return !currentTime.isBefore(lastPromptAt.add(interval));
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
