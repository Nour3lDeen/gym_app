import 'package:hive/hive.dart';

part 'subscription_type_model.g.dart';

@HiveType(typeId: 1)
class SubscriptionType extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  int durationMonths;

  SubscriptionType({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMonths,
  });

  // Default subscription types
  static List<SubscriptionType> getDefaults() {
    return [
      // اشتراكات الشهر الكامل
      SubscriptionType(
        id: 'silver',
        name: 'Silver',
        price: 200.0,
        durationMonths: 1,
      ),
      SubscriptionType(
        id: 'gold',
        name: 'Gold',
        price: 300.0,
        durationMonths: 1,
      ),
      SubscriptionType(
        id: 'platinum',
        name: 'Platinum',
        price: 400.0,
        durationMonths: 1,
      ),
      // اشتراكات نص الشهر (15 يوم)
      SubscriptionType(
        id: 'silver_half',
        name: 'Silver (نص شهر)',
        price: 100.0,
        durationMonths: 0, // 0 = نص شهر
      ),
      SubscriptionType(
        id: 'gold_half',
        name: 'Gold (نص شهر)',
        price: 150.0,
        durationMonths: 0,
      ),
      SubscriptionType(
        id: 'platinum_half',
        name: 'Platinum (نص شهر)',
        price: 200.0,
        durationMonths: 0,
      ),
    ];
  }
}
