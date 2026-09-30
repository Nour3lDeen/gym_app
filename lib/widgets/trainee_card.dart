import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trainee_model.dart';
import '../services/image_service.dart';

class TraineeCard extends StatelessWidget {
  final Trainee trainee;
  final VoidCallback onDelete;
  final VoidCallback onMarkPaid;
  final VoidCallback onEdit;
  final VoidCallback? onTap; // للتفاصيل
  final VoidCallback? onRenew; // تجديد الاشتراك

  const TraineeCard({
    super.key,
    required this.trainee,
    required this.onDelete,
    required this.onMarkPaid,
    required this.onEdit,
    this.onTap,
    this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    // تحديد حالة الكارت ولونه
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

    // Subscription type badge - handle both full and half month subscriptions
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // الشريط الجانبي الملون
                Container(width: 8, color: statusColor),

                // صورة المشترك
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GestureDetector(
                    onTap:
                        trainee.imagePath != null &&
                            ImageService.imageExists(trainee.imagePath)
                        ? () =>
                              _showFullScreenImage(context, trainee.imagePath!)
                        : null,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          trainee.imagePath != null &&
                              ImageService.imageExists(trainee.imagePath)
                          ? FileImage(File(trainee.imagePath!))
                          : null,
                      child:
                          trainee.imagePath == null ||
                              !ImageService.imageExists(trainee.imagePath)
                          ? Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                  ),
                ),

                // بيانات المشترك
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                trainee.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D1B2A),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Subscription type badge with half-month indicator
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: subTypeColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: subTypeColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                subTypeName,
                                style: TextStyle(
                                  color: subTypeColor.withValues(alpha: 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            if (trainee.subscriptionDurationMonths == 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "نص شهر",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        // تاريخ الانضمام
                        Row(
                          children: [
                            const Icon(
                              Icons.person_add,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "انضم: ${dateFormat.format(trainee.joinDate)}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.date_range,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "ينتهي: ${dateFormat.format(trainee.expiryDate)}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        if (trainee.phoneNumber != null &&
                            trainee.phoneNumber!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  trainee.phoneNumber!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        // ملاحظات
                        if (trainee.notes != null && trainee.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.note,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      trainee.notes!,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // أزرار التحكم
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // زر التعديل
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: onEdit,
                      tooltip: "تعديل",
                    ),
                    // زر التجديد (يظهر فقط للاشتراكات المنتهية)
                    if (onRenew != null && trainee.isExpired)
                      IconButton(
                        icon: const Icon(
                          Icons.autorenew,
                          color: Color(0xFF0D1B2A),
                        ),
                        onPressed: onRenew,
                        tooltip: "تجديد الاشتراك",
                      ),
                    if (!trainee.isPaid)
                      IconButton(
                        icon: const Icon(
                          Icons.monetization_on,
                          color: Colors.green,
                        ),
                        onPressed: onMarkPaid,
                        tooltip: "دفع",
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: "حذف",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
            // الخلفية السوداء
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black87,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // الصورة
            Center(
              child: InteractiveViewer(
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),
            // زر الإغلاق
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
