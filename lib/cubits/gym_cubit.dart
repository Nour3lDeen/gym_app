import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/database_service.dart';
import '../models/trainee_model.dart';
import 'gym_state.dart';

class GymCubit extends Cubit<GymState> {
  final DatabaseService _dbService;

  GymCubit(this._dbService) : super(const GymState());

  // 1. تحميل البيانات
  void loadTrainees() {
    emit(state.copyWith(status: GymStatus.loading));
    try {
      refreshList(); // نستخدم دالة التحديث الموحدة
    } catch (e) {
      emit(state.copyWith(status: GymStatus.failure));
    }
  }

  // 2. إضافة مشترك
  Future<void> addTrainee(Trainee trainee) async {
    try {
      await _dbService.addTrainee(trainee);
      refreshList();
    } catch (e) {
      emit(state.copyWith(status: GymStatus.failure));
    }
  }

  // 3. تعديل بيانات مشترك
  Future<void> updateTraineeData(Trainee trainee) async {
    try {
      await _dbService.updateTrainee(trainee);
      trainee.save(); // حفظ التعديل في Hive
      refreshList(); // تحديث القائمة
    } catch (e) {
      emit(state.copyWith(status: GymStatus.failure));
    }
  }

  // 4. حذف مشترك
  Future<void> deleteTrainee(String id) async {
    try {
      await _dbService.deleteTrainee(id);
      refreshList();
    } catch (e) {
      // Handle error
    }
  }

  // 5. تجديد الاشتراك (يضيف شهر واحد)
  Future<void> renewSubscription(Trainee trainee) async {
    try {
      // لو الاشتراك منتهي، نبدأ من تاريخ النهارده
      // لو لسه شغال، نبدأ من تاريخ الانتهاء الحالي
      final newStartDate = trainee.isExpired
          ? DateTime.now()
          : trainee.expiryDate;

      trainee.subscriptionDate = newStartDate;
      trainee.isPaid = false; // دورة دفع جديدة
      await trainee.save();

      refreshList();
    } catch (e) {
      emit(state.copyWith(status: GymStatus.failure));
    }
  }

  // 5. تحديث الفلتر
  void updateFilter(TraineeFilter filter) {
    // بنحدث الفلتر في الـ state الأول
    emit(state.copyWith(activeFilter: filter));
    // وبعدين نطبق الفلتر
    _applyFilter();
  }

  // 6. تحديث البحث
  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilter();
  }

  // --- دوال مساعدة (هنا التعديل المهم) ---

  void refreshList() {
    // 1. نجيب الداتا
    final updatedList = _dbService.getTrainees();

    // 2. نحدث الحالة ونزود الـ refreshId
    emit(
      state.copyWith(
        status: GymStatus.success,
        allTrainees: updatedList,
        refreshId:
            state.refreshId + 1, // <--- السر كله هنا: بنجبره يحس بالتغيير
      ),
    );

    // 3. نطبق الفلتر
    _applyFilter();
  }

  void _applyFilter() {
    List<Trainee> filtered;
    final all = state
        .allTrainees; // مش محتاجين [...] هنا خلاص الـ refreshId قام بالواجب

    switch (state.activeFilter) {
      case TraineeFilter.expired:
        filtered = all.where((t) => t.isExpired).toList();
        break;
      case TraineeFilter.nearingExpiry:
        filtered = all.where((t) => t.isNearingExpiry).toList();
        break;
      case TraineeFilter.notPaid:
        filtered = all.where((t) => !t.isPaid).toList();
        break;
      case TraineeFilter.all:
        filtered = all;
        break;
    }

    // تطبيق البحث
    final query = state.searchQuery.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((t) {
        final nameMatch = t.name.toLowerCase().contains(query);
        final phoneMatch =
            t.phoneNumber?.toLowerCase().contains(query) ?? false;
        return nameMatch || phoneMatch;
      }).toList();
    }

    emit(state.copyWith(filteredTrainees: filtered));
  }
}
