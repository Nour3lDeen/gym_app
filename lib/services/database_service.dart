import 'package:hive_flutter/hive_flutter.dart';
import '../models/trainee_model.dart';
import '../models/subscription_type_model.dart';

class DatabaseService {
  // اسم الصندوق (Box) اللي هنخزن فيه الداتا
  static const String _boxName = "trainees_box";
  static const String _subscriptionTypesBox = "subscription_types_box";

  // دالة لفتح الصندوق وبدء Hive (بنناديها مرة واحدة أول ما التطبيق يفتح)
  static Future<void> init() async {
    await Hive.initFlutter();

    // تسجيل الـ Adapter اللي اتعمله generate
    // (تأكد انك عملت الخطوة السابقة بتاعة build_runner)
    Hive.registerAdapter(TraineeAdapter());
    Hive.registerAdapter(SubscriptionTypeAdapter());

    await Hive.openBox<Trainee>(_boxName);
    await Hive.openBox<SubscriptionType>(_subscriptionTypesBox);

    // Add any missing subscription types (including new half-month types)
    final subTypesBox = Hive.box<SubscriptionType>(_subscriptionTypesBox);
    for (final subType in SubscriptionType.getDefaults()) {
      // Only add if this subscription type doesn't exist yet
      if (!subTypesBox.containsKey(subType.id)) {
        await subTypesBox.put(subType.id, subType);
      }
    }
  }

  // 1. هات كل المشتركين
  List<Trainee> getTrainees() {
    final box = Hive.box<Trainee>(_boxName);
    return box.values.toList();
  }

  // 2. إضافة مشترك جديد
  Future<void> addTrainee(Trainee trainee) async {
    final box = Hive.box<Trainee>(_boxName);
    // بنستخدم put عشان نقدر نحدد الـ key بنفسنا (اللي هو الـ id)
    await box.put(trainee.id, trainee);
  }

  // 3. حذف مشترك
  Future<void> deleteTrainee(String id) async {
    final box = Hive.box<Trainee>(_boxName);
    await box.delete(id);
  }

  // 4. تحديث بيانات مشترك (مثلاً جدد الاشتراك أو دفع)
  Future<void> updateTrainee(Trainee trainee) async {
    final box = Hive.box<Trainee>(_boxName);
    await box.put(trainee.id, trainee); // put بتعمل update لو المفتاح موجود
  }

  // 5. دالة لمسح كل الداتا (لو احتاجنا نعمل Reset للتطبيق)
  Future<void> clearAll() async {
    final box = Hive.box<Trainee>(_boxName);
    await box.clear();
  }

  // 6. هات كل أنواع الاشتراكات
  List<SubscriptionType> getSubscriptionTypes() {
    final box = Hive.box<SubscriptionType>(_subscriptionTypesBox);
    return box.values.toList();
  }

  // 7. تحديث نوع اشتراك
  Future<void> updateSubscriptionType(SubscriptionType subType) async {
    final box = Hive.box<SubscriptionType>(_subscriptionTypesBox);
    await box.put(subType.id, subType);
  }

  // 8. هات نوع اشتراك معين
  SubscriptionType? getSubscriptionType(String id) {
    final box = Hive.box<SubscriptionType>(_subscriptionTypesBox);
    return box.get(id);
  }
}
