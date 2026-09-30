import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/gym_cubit.dart';
import '../cubits/gym_state.dart';
import '../services/database_service.dart';
import '../services/backup_service.dart';
import '../models/subscription_type_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color kPrimaryColor = const Color(0xFF0D1B2A);
  final Color kGoldColor = const Color(0xFFFFD700);

  List<SubscriptionType> _subscriptionTypes = [];
  final Map<String, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    _loadSubscriptionTypes();
  }

  void _loadSubscriptionTypes() {
    final dbService = DatabaseService();
    setState(() {
      _subscriptionTypes = dbService.getSubscriptionTypes();
      for (var subType in _subscriptionTypes) {
        _priceControllers[subType.id] = TextEditingController(
          text: subType.price.toStringAsFixed(0),
        );
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text("الإعدادات"),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalRevenueCard(context),
              const SizedBox(height: 20),
              _buildSubscriptionTypesCard(),
              const SizedBox(height: 20),
              _buildBackupCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalRevenueCard(BuildContext context) {
    return BlocBuilder<GymCubit, GymState>(
      builder: (context, state) {
        double totalExpected = 0;
        final dbService = DatabaseService();

        for (var trainee in state.allTrainees) {
          if (!trainee.isExpired) {
            final subType = dbService.getSubscriptionType(
              trainee.subscriptionTypeId,
            );
            if (subType != null) {
              totalExpected += subType.price;
            }
          }
        }

        final notPaidTotal = state.allTrainees
            .where((t) => !t.isPaid && !t.isExpired)
            .fold<double>(0, (sum, trainee) {
              final subType = dbService.getSubscriptionType(
                trainee.subscriptionTypeId,
              );
              return sum + (subType?.price ?? 0);
            });

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: kGoldColor, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    "إجمالي الإيرادات المتوقعة",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "${totalExpected.toStringAsFixed(0)} جنيه",
                style: TextStyle(
                  color: kGoldColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "لم يتم تحصيل: ${notPaidTotal.toStringAsFixed(0)} جنيه",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionTypesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_membership, color: kPrimaryColor),
              const SizedBox(width: 10),
              const Text(
                "أسعار الاشتراكات",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._subscriptionTypes.map(
            (subType) => _buildSubscriptionTypeItem(subType),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveSubscriptionPrices,
              icon: const Icon(Icons.save),
              label: const Text("حفظ الأسعار"),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kGoldColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTypeItem(SubscriptionType subType) {
    Color badgeColor;
    IconData badgeIcon;

    // Handle both full and half month subscriptions
    final baseId = subType.id.replaceAll('_half', '');
    switch (baseId) {
      case 'gold':
        badgeColor = const Color(0xFFFFD700);
        badgeIcon = Icons.star;
        break;
      case 'platinum':
        badgeColor = const Color(0xFF7B68EE);
        badgeIcon = Icons.diamond;
        break;
      default: // silver
        badgeColor = const Color(0xFFC0C0C0);
        badgeIcon = Icons.workspace_premium;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(badgeIcon, color: badgeColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              subType.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: _priceControllers[subType.id],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                suffixText: "جنيه",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSubscriptionPrices() async {
    final dbService = DatabaseService();

    for (var subType in _subscriptionTypes) {
      final controller = _priceControllers[subType.id];
      if (controller != null) {
        final newPrice = double.tryParse(controller.text) ?? subType.price;
        subType.price = newPrice;
        await dbService.updateSubscriptionType(subType);
      }
    }

    // Refresh the cubit to reflect changes
    if (mounted) {
      context.read<GymCubit>().refreshList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم حفظ الأسعار بنجاح!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildBackupCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.backup, color: kPrimaryColor),
              const SizedBox(width: 10),
              const Text(
                "النسخ الاحتياطي",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _performBackup(context),
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text("إنشاء نسخة"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _performRestore(context),
                  icon: const Icon(Icons.cloud_download),
                  label: const Text("استعادة"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _performBackup(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final backupPath = await BackupService.exportBackup();
      if (!mounted) return;
      Navigator.pop(context);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("تم بنجاح"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("تم إنشاء النسخة الاحتياطية في:"),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(backupPath, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("حسناً"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ في إنشاء النسخة: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _performRestore(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 10),
            Text("تأكيد الاستعادة"),
          ],
        ),
        content: const Text(
          "سيتم استبدال جميع البيانات الحالية بالنسخة الاحتياطية. هل أنت متأكد؟",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);

              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                final success = await BackupService.importFromDefaultLocation();
                if (!mounted) return;
                Navigator.pop(context);

                if (success) {
                  _loadSubscriptionTypes();
                  if (!mounted) return;
                  context.read<GymCubit>().refreshList();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تمت الاستعادة بنجاح!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("لم يتم العثور على نسخة احتياطية"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("خطأ في الاستعادة: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("استعادة"),
          ),
        ],
      ),
    );
  }
}
