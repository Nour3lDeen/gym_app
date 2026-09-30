import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/trainee_model.dart';
import '../cubits/gym_cubit.dart';
import '../services/image_service.dart';
import 'add_trainee_screen.dart';
import 'dart:ui' as ui;

class TraineeDetailsScreen extends StatelessWidget {
  final Trainee trainee;

  const TraineeDetailsScreen({super.key, required this.trainee});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    // تحديد حالة الاشتراك ولونه
    Color statusColor = Colors.green;
    String statusText = "نشط";

    if (trainee.isExpired) {
      statusColor = Colors.red;
      statusText = "منتهي";
    } else if (!trainee.isPaid) {
      statusColor = Colors.orange;
      statusText = "لم يدفع";
    } else if (trainee.isNearingExpiry) {
      statusColor = Colors.amber;
      statusText = "قرب ينتهي";
    }

    // نوع الاشتراك
    Color subTypeColor;
    String subTypeName;
    final baseSubTypeId = trainee.subscriptionTypeId.replaceAll('_half', '');
    switch (baseSubTypeId) {
      case 'gold':
        subTypeColor = const Color(0xFFFFD700);
        subTypeName = 'Gold';
        break;
      case 'platinum':
        subTypeColor = const Color(0xFF7B68EE);
        subTypeName = 'Platinum';
        break;
      default:
        subTypeColor = const Color(0xFFC0C0C0);
        subTypeName = 'Silver';
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text("تفاصيل المشترك"),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTraineeScreen(trainee: trainee),
                  ),
                );
              },
              tooltip: "تعديل",
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // رأس الصفحة مع الصورة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D1B2A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // الصورة
                    GestureDetector(
                      onTap:
                          trainee.imagePath != null &&
                              ImageService.imageExists(trainee.imagePath)
                          ? () => _showFullScreenImage(
                              context,
                              trainee.imagePath!,
                            )
                          : null,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white24,
                        backgroundImage:
                            trainee.imagePath != null &&
                                ImageService.imageExists(trainee.imagePath)
                            ? FileImage(File(trainee.imagePath!))
                            : null,
                        child:
                            trainee.imagePath == null ||
                                !ImageService.imageExists(trainee.imagePath)
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white54,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // الاسم
                    Text(
                      trainee.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // حالة الاشتراك ونوعه
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: subTypeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: subTypeColor),
                          ),
                          child: Text(
                            subTypeName,
                            style: TextStyle(
                              color: subTypeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (trainee.subscriptionDurationMonths == 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "نص شهر",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // بطاقة البيانات
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.phone,
                          "رقم الهاتف",
                          trainee.phoneNumber ?? "غير محدد",
                        ),
                        const Divider(),
                        _buildInfoRow(
                          Icons.person_add,
                          "تاريخ الانضمام",
                          dateFormat.format(trainee.joinDate),
                        ),
                        const Divider(),
                        _buildInfoRow(
                          Icons.calendar_today,
                          "بداية الاشتراك",
                          dateFormat.format(trainee.subscriptionDate),
                        ),
                        const Divider(),
                        _buildInfoRow(
                          Icons.event_busy,
                          "نهاية الاشتراك",
                          dateFormat.format(trainee.expiryDate),
                        ),
                        const Divider(),
                        _buildInfoRow(
                          Icons.timer,
                          "الأيام المتبقية",
                          trainee.isExpired
                              ? "منتهي"
                              : "${trainee.daysRemaining} يوم",
                          valueColor: trainee.isExpired ? Colors.red : null,
                        ),
                        const Divider(),
                        _buildInfoRow(
                          Icons.payment,
                          "حالة الدفع",
                          trainee.isPaid ? "تم الدفع" : "لم يدفع",
                          valueColor: trainee.isPaid
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // الملاحظات
              if (trainee.notes != null && trainee.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.note, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                "ملاحظات",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D1B2A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            trainee.notes!,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // زر تجديد الاشتراك (يظهر فقط للاشتراكات المنتهية)
              if (trainee.isExpired)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmRenewal(context),
                      icon: const Icon(Icons.autorenew),
                      label: const Text(
                        "تجديد الاشتراك",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B2A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF0D1B2A),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRenewal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.autorenew, color: Color(0xFF0D1B2A)),
            SizedBox(width: 10),
            Text("تجديد الاشتراك"),
          ],
        ),
        content: Text(
          "هل تريد تجديد اشتراك ${trainee.name} لمدة شهر إضافي؟\n\nسيتم تحديث تاريخ الاشتراك ووضع حالة الدفع كـ 'لم يدفع'.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D1B2A),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<GymCubit>().renewSubscription(trainee);
              Navigator.pop(ctx);
              Navigator.pop(context); // الرجوع للشاشة الرئيسية
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم تجديد الاشتراك بنجاح!"),
                  backgroundColor: Color(0xFF0D1B2A),
                ),
              );
            },
            child: const Text("تأكيد التجديد"),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black87,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Center(
              child: InteractiveViewer(
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
