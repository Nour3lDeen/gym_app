import 'package:hive/hive.dart';

// هذا السطر مهم جداً وسيظهر تحته خط أحمر حتى نقوم بتشغيل أمر البناء لاحقاً
part 'trainee_model.g.dart';

@HiveType(typeId: 0)
class Trainee extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? phoneNumber;

  @HiveField(3)
  DateTime subscriptionDate;

  @HiveField(4)
  bool isPaid;

  @HiveField(5)
  String? _subscriptionTypeId; // Made nullable for migration

  @HiveField(6)
  int? _subscriptionDurationMonths; // Made nullable for migration

  @HiveField(7)
  DateTime? _joinDate; // Made nullable for migration - تاريخ الانضمام للجيم

  @HiveField(8)
  String? notes; // ملاحظات عن المشترك

  @HiveField(9)
  String? imagePath; // مسار صورة المشترك

  // Getters with default values for backward compatibility
  String get subscriptionTypeId => _subscriptionTypeId ?? 'silver';
  set subscriptionTypeId(String value) => _subscriptionTypeId = value;

  int get subscriptionDurationMonths => _subscriptionDurationMonths ?? 1;
  set subscriptionDurationMonths(int value) =>
      _subscriptionDurationMonths = value;

  // joinDate getter - fallback to subscriptionDate for old data
  DateTime get joinDate => _joinDate ?? subscriptionDate;
  set joinDate(DateTime value) => _joinDate = value;

  Trainee({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.subscriptionDate,
    required this.isPaid,
    String? subscriptionTypeId,
    int? subscriptionDurationMonths,
    DateTime? joinDate,
    this.notes,
    this.imagePath,
  }) : _subscriptionTypeId = subscriptionTypeId ?? 'silver',
       _subscriptionDurationMonths = subscriptionDurationMonths ?? 1,
       _joinDate = joinDate;

  // ---------------------------------------------
  // Logic Functions (حسابات الاشتراك)
  // ---------------------------------------------

  // 1. حساب تاريخ الانتهاء (باستخدام الأشهر الفعلية أو نص شهر)
  DateTime get expiryDate {
    // نص شهر = 15 يوم
    if (subscriptionDurationMonths == 0) {
      return subscriptionDate.add(const Duration(days: 15));
    }

    // إضافة الأشهر بشكل صحيح مع معالجة الحالات الخاصة
    int targetMonth = subscriptionDate.month + subscriptionDurationMonths;
    int targetYear = subscriptionDate.year;

    // معالجة تجاوز الأشهر للسنة
    while (targetMonth > 12) {
      targetMonth -= 12;
      targetYear += 1;
    }

    // معالجة الأيام الزائدة (مثل 31 يناير -> 28/29 فبراير)
    int targetDay = subscriptionDate.day;
    int daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    if (targetDay > daysInTargetMonth) {
      targetDay = daysInTargetMonth;
    }

    return DateTime(targetYear, targetMonth, targetDay);
  }

  // 2. هل الاشتراك انتهى بالفعل؟
  bool get isExpired {
    final now = DateTime.now();
    // نستخدم isAfter ونقارن باليوم فقط لتجنب فروق الساعات والدقائق
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return today.isAfter(expiry);
  }

  // 3. هل الاشتراك سينتهي قريباً؟ (مثلاً باقي 3 أيام أو أقل)
  // بشرط ألا يكون قد انتهى بالفعل
  bool get isNearingExpiry {
    if (isExpired) return false; // لو منتهي خلاص مش محتاج تنبيه قرب انتهاء

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    final difference = expiry.difference(today).inDays;
    return difference <= 3 && difference >= 0;
  }

  // دالة مساعدة لمعرفة عدد الأيام المتبقية
  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }
}
