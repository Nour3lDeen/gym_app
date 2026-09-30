import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/trainee_model.dart';
import '../models/subscription_type_model.dart';

class BackupService {
  static const String _backupFileName = "gym_backup.json";

  // Get the backup directory path
  static Future<String> getBackupPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_backupFileName';
  }

  // Export all data to a JSON file
  static Future<String> exportBackup() async {
    final traineesBox = Hive.box<Trainee>('trainees_box');
    final subscriptionTypesBox = Hive.box<SubscriptionType>(
      'subscription_types_box',
    );

    final traineesData = traineesBox.values
        .map(
          (t) => {
            'id': t.id,
            'name': t.name,
            'phoneNumber': t.phoneNumber,
            'subscriptionDate': t.subscriptionDate.toIso8601String(),
            'isPaid': t.isPaid,
            'subscriptionTypeId': t.subscriptionTypeId,
            'subscriptionDurationMonths': t.subscriptionDurationMonths,
            'joinDate': t.joinDate.toIso8601String(),
            'notes': t.notes,
            'imagePath': t.imagePath,
          },
        )
        .toList();

    final subscriptionTypesData = subscriptionTypesBox.values
        .map(
          (s) => {
            'id': s.id,
            'name': s.name,
            'price': s.price,
            'durationMonths': s.durationMonths,
          },
        )
        .toList();

    final backupData = {
      'version': 1,
      'exportDate': DateTime.now().toIso8601String(),
      'trainees': traineesData,
      'subscriptionTypes': subscriptionTypesData,
    };

    final backupPath = await getBackupPath();
    final file = File(backupPath);
    await file.writeAsString(jsonEncode(backupData));

    return backupPath;
  }

  // Import data from a JSON file
  static Future<bool> importBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Clear existing data
      final traineesBox = Hive.box<Trainee>('trainees_box');
      final subscriptionTypesBox = Hive.box<SubscriptionType>(
        'subscription_types_box',
      );

      await traineesBox.clear();
      await subscriptionTypesBox.clear();

      // Restore subscription types first
      final subscriptionTypesData =
          backupData['subscriptionTypes'] as List<dynamic>;
      for (final subData in subscriptionTypesData) {
        final subType = SubscriptionType(
          id: subData['id'],
          name: subData['name'],
          price: (subData['price'] as num).toDouble(),
          durationMonths: subData['durationMonths'],
        );
        await subscriptionTypesBox.put(subType.id, subType);
      }

      // Restore trainees
      final traineesData = backupData['trainees'] as List<dynamic>;
      for (final traineeData in traineesData) {
        final trainee = Trainee(
          id: traineeData['id'],
          name: traineeData['name'],
          phoneNumber: traineeData['phoneNumber'],
          subscriptionDate: DateTime.parse(traineeData['subscriptionDate']),
          isPaid: traineeData['isPaid'],
          subscriptionTypeId: traineeData['subscriptionTypeId'] ?? 'silver',
          subscriptionDurationMonths:
              traineeData['subscriptionDurationMonths'] ?? 1,
          joinDate: traineeData['joinDate'] != null
              ? DateTime.parse(traineeData['joinDate'])
              : DateTime.parse(
                  traineeData['subscriptionDate'],
                ), // fallback للبيانات القديمة
          notes: traineeData['notes'],
          imagePath: traineeData['imagePath'],
        );
        await traineesBox.put(trainee.id, trainee);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Import from the default backup location
  static Future<bool> importFromDefaultLocation() async {
    final backupPath = await getBackupPath();
    return importBackup(backupPath);
  }
}
