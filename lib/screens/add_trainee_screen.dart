import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:uuid/uuid.dart';
import '../cubits/gym_cubit.dart';
import '../models/trainee_model.dart';
import '../models/subscription_type_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/image_service.dart';

class AddTraineeScreen extends StatefulWidget {
  final Trainee? trainee; // لو فاضي يبقى إضافة، لو مليان يبقى تعديل

  const AddTraineeScreen({super.key, this.trainee});

  @override
  State<AddTraineeScreen> createState() => _AddTraineeScreenState();
}

class _AddTraineeScreenState extends State<AddTraineeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  late DateTime _subscriptionDate;
  late DateTime _joinDate;
  late bool _isPaid;
  late String _selectedSubscriptionTypeId;
  String? _imagePath;

  List<SubscriptionType> _subscriptionTypes = [];

  // الألوان الخاصة بنا
  final Color kPrimaryColor = const Color(0xFF0D1B2A);
  final Color kGoldColor = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    // التحقق هل نحن في وضع التعديل أم الإضافة
    _nameController = TextEditingController(text: widget.trainee?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.trainee?.phoneNumber ?? '',
    );
    _notesController = TextEditingController(text: widget.trainee?.notes ?? '');
    _subscriptionDate = widget.trainee?.subscriptionDate ?? DateTime.now();
    _joinDate = widget.trainee?.joinDate ?? DateTime.now();
    _isPaid = widget.trainee?.isPaid ?? true;
    _selectedSubscriptionTypeId =
        widget.trainee?.subscriptionTypeId ?? 'silver';
    _imagePath = widget.trainee?.imagePath;

    // Load subscription types
    _subscriptionTypes = DatabaseService().getSubscriptionTypes();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.trainee != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(isEditing ? "تعديل بيانات المشترك" : "إضافة مشترك جديد"),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormCard(),
                  const SizedBox(height: 30),
                  _buildSaveButton(isEditing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
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
          // صورة المشترك
          Center(
            child: GestureDetector(
              onTap: _showImagePickerOptions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        _imagePath != null &&
                            ImageService.imageExists(_imagePath)
                        ? FileImage(File(_imagePath!))
                        : null,
                    child:
                        _imagePath == null ||
                            !ImageService.imageExists(_imagePath)
                        ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel("اسم الكابتن"),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration("الاسم ثلاثي", Icons.person),
            validator: (val) => val!.isEmpty ? "الاسم مطلوب" : null,
          ),
          const SizedBox(height: 20),

          _buildLabel("رقم الهاتف"),
          TextFormField(
            controller: _phoneController,
            decoration: _inputDecoration("01xxxxxxxxx", Icons.phone),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),

          _buildLabel("تاريخ الانضمام"),
          _buildDatePicker(
            date: _joinDate,
            onPicked: (picked) => setState(() => _joinDate = picked),
            icon: Icons.person_add,
          ),
          const SizedBox(height: 20),

          _buildLabel("نوع الاشتراك"),
          _buildSubscriptionTypeSelector(),
          const SizedBox(height: 20),

          _buildLabel("تاريخ الاشتراك"),
          _buildDatePicker(
            date: _subscriptionDate,
            onPicked: (picked) => setState(() => _subscriptionDate = picked),
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 20),

          _buildLabel("ملاحظات"),
          TextFormField(
            controller: _notesController,
            decoration: _inputDecoration(
              "ملاحظات عن المشترك (اختياري)",
              Icons.note,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: kGoldColor,
            title: const Text(
              "تم دفع الاشتراك؟",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            value: _isPaid,
            onChanged: (val) => setState(() => _isPaid = val),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required DateTime date,
    required Function(DateTime) onPicked,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: kPrimaryColor,
                  onPrimary: kGoldColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryColor),
            const SizedBox(width: 10),
            Text(
              intl.DateFormat('yyyy-MM-dd').format(date),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _subscriptionTypes.map((subType) {
          final isSelected = _selectedSubscriptionTypeId == subType.id;

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

          return InkWell(
            onTap: () =>
                setState(() => _selectedSubscriptionTypeId = subType.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? badgeColor.withValues(alpha: 0.1) : null,
                border: Border(
                  bottom: subType != _subscriptionTypes.last
                      ? BorderSide(color: Colors.grey.shade200)
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(badgeIcon, color: badgeColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subType.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${subType.price.toStringAsFixed(0)} جنيه / شهر",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: kPrimaryColor),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => _saveTrainee(isEditing),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: kGoldColor,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          isEditing ? "حفظ التعديلات" : "إضافة المشترك",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 5),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: kPrimaryColor),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "اختر صورة",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: kPrimaryColor),
                ),
                title: const Text("الكاميرا"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kGoldColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: kGoldColor),
                ),
                title: const Text("المعرض"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_imagePath != null) ...[
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  title: const Text("حذف الصورة"),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // Generate temp ID for new trainees
    final traineeId = widget.trainee?.id ?? const Uuid().v4();
    final path = await ImageService.pickAndCompressImage(source, traineeId);
    if (path != null) {
      setState(() => _imagePath = path);
    }
  }

  void _removeImage() {
    if (_imagePath != null) {
      ImageService.deleteImage(_imagePath);
      setState(() => _imagePath = null);
    }
  }

  void _saveTrainee(bool isEditing) {
    if (_formKey.currentState!.validate()) {
      // Get selected subscription type details
      final selectedSubType = _subscriptionTypes.firstWhere(
        (s) => s.id == _selectedSubscriptionTypeId,
        orElse: () => _subscriptionTypes.first,
      );

      if (isEditing) {
        // منطق التعديل
        final updatedTrainee = widget.trainee!;
        updatedTrainee.name = _nameController.text;
        updatedTrainee.phoneNumber = _phoneController.text;
        updatedTrainee.subscriptionDate = _subscriptionDate;
        updatedTrainee.isPaid = _isPaid;
        updatedTrainee.subscriptionTypeId = _selectedSubscriptionTypeId;
        updatedTrainee.subscriptionDurationMonths =
            selectedSubType.durationMonths;
        updatedTrainee.joinDate = _joinDate;
        updatedTrainee.notes = _notesController.text.isEmpty
            ? null
            : _notesController.text;
        updatedTrainee.imagePath = _imagePath;

        // حفظ التعديل في Hive من خلال الـ Cubit
        context.read<GymCubit>().updateTraineeData(updatedTrainee);

        // إعادة جدولة الإشعار (للبساطة سنلغي القديم ونعمل جديد بنفس الـ ID)
        NotificationService.scheduleExpiryNotification(
          id: updatedTrainee.id.hashCode,
          name: updatedTrainee.name,
          expiryDate: updatedTrainee.expiryDate,
        );
      } else {
        // منطق الإضافة الجديدة
        final newTrainee = Trainee(
          id: const Uuid().v4(),
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          subscriptionDate: _subscriptionDate,
          isPaid: _isPaid,
          subscriptionTypeId: _selectedSubscriptionTypeId,
          subscriptionDurationMonths: selectedSubType.durationMonths,
          joinDate: _joinDate,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          imagePath: _imagePath,
        );

        context.read<GymCubit>().addTrainee(newTrainee);
        NotificationService.scheduleExpiryNotification(
          id: newTrainee.id.hashCode,
          name: newTrainee.name,
          expiryDate: newTrainee.expiryDate,
        );
      }
      Navigator.pop(context);
    }
  }
}
