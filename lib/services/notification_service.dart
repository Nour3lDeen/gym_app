import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // تهيئة الإشعارات
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      // استخدام أيقونة التطبيق الافتراضية
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
          channelKey: 'gym_channel',
          channelName: 'Gym Subscription Alerts',
          channelDescription: 'تنبيهات اشتراكات الجيم',
          defaultColor: const Color(0xFF0D1B2A),
          importance: NotificationImportance.Max,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );
  }

  // طلب الإذن (مهم لأندرويد 13+)
  static Future<void> requestPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // جدولة إشعار (قبل الانتهاء بـ 3 أيام)
  static Future<void> scheduleExpiryNotification({
    required int id,
    required String name,
    required DateTime expiryDate,
  }) async {
    // ميعاد التنبيه: قبل الانتهاء بـ 3 أيام
    final scheduledDate = expiryDate.subtract(const Duration(days: 3));

    // لو التاريخ ده عدى خلاص، منعملش حاجة
    if (scheduledDate.isBefore(DateTime.now())) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'gym_channel',
        title: 'تنبيه اشتراك الجيم',
        body: 'اشتراك الكابتن $name قرب يخلص (باقي 3 أيام)',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduledDate,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  // إلغاء إشعار (لو المشترك جدد مثلاً)
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
