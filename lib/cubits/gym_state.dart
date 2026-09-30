import 'package:equatable/equatable.dart';
import '../models/trainee_model.dart';

enum TraineeFilter { all, expired, nearingExpiry, notPaid }
enum GymStatus { initial, loading, success, failure }

class GymState extends Equatable {
  final GymStatus status;
  final List<Trainee> allTrainees;
  final List<Trainee> filteredTrainees;
  final TraineeFilter activeFilter;
  final String searchQuery;
  
  // 1. الإضافة الجديدة: رقم للإصدار
  final int refreshId; 

  const GymState({
    this.status = GymStatus.initial,
    this.allTrainees = const [],
    this.filteredTrainees = const [],
    this.activeFilter = TraineeFilter.all,
    this.searchQuery = '',
    this.refreshId = 0, // القيمة الافتراضية
  });

  GymState copyWith({
    GymStatus? status,
    List<Trainee>? allTrainees,
    List<Trainee>? filteredTrainees,
    TraineeFilter? activeFilter,
    String? searchQuery,
    int? refreshId, // 2. نضيفه هنا
  }) {
    return GymState(
      status: status ?? this.status,
      allTrainees: allTrainees ?? this.allTrainees,
      filteredTrainees: filteredTrainees ?? this.filteredTrainees,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      refreshId: refreshId ?? this.refreshId, // 3. وهنا
    );
  }

  @override
  // 4. أهم خطوة: نضيفه في الـ props عشان المقارنة تختلف
  List<Object> get props => [status, allTrainees, filteredTrainees, activeFilter, searchQuery, refreshId];
}
