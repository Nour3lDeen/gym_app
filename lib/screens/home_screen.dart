import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/gym_cubit.dart';
import '../cubits/gym_state.dart';
import 'add_trainee_screen.dart';
import 'settings_screen.dart';
import 'trainee_details_screen.dart';
import '../widgets/trainee_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Captain Ahmed Gym"),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // ✅ تعديل 1: إخفاء الكيبورد قبل فتح الإعدادات
                FocusScope.of(context).unfocus();
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // ✅ تعديل 2: إخفاء الكيبورد قبل فتح شاشة الإضافة
            FocusScope.of(context).unfocus();

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTraineeScreen()),
            );
          },
          label: const Text(
            "إضافة مشترك",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.add),
        ),
        body: GestureDetector(
          // إخفاء الكيبورد عند اللمس في أي مكان فارغ
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              _buildDashboardHeader(context),

              // --- حقل البحث ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: TextFormField(
                  autofocus: false,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  onChanged: (value) =>
                      context.read<GymCubit>().updateSearch(value),
                  decoration: InputDecoration(
                    hintText: "بحث بالاسم أو رقم الهاتف...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),

              // --- تصميم الفلتر الجديد ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocBuilder<GymCubit, GymState>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          _buildTabFilter(
                            context,
                            "الكل",
                            TraineeFilter.all,
                            state.activeFilter,
                          ),
                          _buildTabFilter(
                            context,
                            "منتهي",
                            TraineeFilter.expired,
                            state.activeFilter,
                          ),
                          _buildTabFilter(
                            context,
                            "قرب ينتهي",
                            TraineeFilter.nearingExpiry,
                            state.activeFilter,
                          ),
                          _buildTabFilter(
                            context,
                            "لم يدفع",
                            TraineeFilter.notPaid,
                            state.activeFilter,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              Expanded(
                child: BlocBuilder<GymCubit, GymState>(
                  builder: (context, state) {
                    if (state.status == GymStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.filteredTrainees.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "لا يوجد مشتركين في هذه القائمة",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: state.filteredTrainees.length,
                      itemBuilder: (context, index) {
                        final trainee = state.filteredTrainees[index];
                        return TraineeCard(
                          trainee: trainee,

                          // فتح صفحة التفاصيل
                          onTap: () {
                            // ✅ تعديل 3: إخفاء الكيبورد قبل فتح التفاصيل
                            FocusScope.of(context).unfocus();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TraineeDetailsScreen(trainee: trainee),
                              ),
                            );
                          },

                          // 1. زر التعديل
                          onEdit: () {
                            // ✅ تعديل 4: إخفاء الكيبورد قبل فتح التعديل
                            FocusScope.of(context).unfocus();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddTraineeScreen(trainee: trainee),
                              ),
                            );
                          },

                          // 2. زر الحذف
                          onDelete: () => _confirmDelete(context, trainee.id),

                          // 3. زر الدفع
                          onMarkPaid: () => _confirmPayment(context, trainee),

                          // 4. زر التجديد
                          onRenew: () => _confirmRenewal(context, trainee),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- تصميم زر الفلتر الجديد (Tab Style) ---
  Widget _buildTabFilter(
    BuildContext context,
    String label,
    TraineeFilter filter,
    TraineeFilter currentFilter,
  ) {
    final isSelected = currentFilter == filter;
    return GestureDetector(
      onTap: () => context.read<GymCubit>().updateFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D1B2A) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D1B2A) : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context) {
    return BlocBuilder<GymCubit, GymState>(
      builder: (context, state) {
        final total = state.allTrainees.length;
        final expired = state.allTrainees.where((t) => t.isExpired).length;
        final notPaid = state.allTrainees.where((t) => !t.isPaid).length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF0D1B2A),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const Text(
                "ملخص الجيم",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("العدد الكلي", total.toString(), Colors.white),
                  Container(width: 1, height: 40, color: Colors.white24),
                  _buildStatItem(
                    "اشتراك منتهي",
                    expired.toString(),
                    Colors.redAccent,
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  _buildStatItem("لم يدفع", notPaid.toString(), Colors.amber),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String count, Color countColor) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: countColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  // --- بوب اب تأكيد الدفع ---
  void _confirmPayment(BuildContext context, dynamic trainee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.green),
            SizedBox(width: 10),
            Text("تأكيد الدفع"),
          ],
        ),
        content: Text(
          "هل تريد تأكيد استلام الاشتراك من الكابتن ${trainee.name}؟",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              trainee.isPaid = true;
              trainee.save(); // Hive Save
              context.read<GymCubit>().refreshList();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم تسجيل الدفع!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("تأكيد"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من حذف هذا المشترك؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              context.read<GymCubit>().deleteTrainee(id);
              Navigator.pop(ctx);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- بوب اب تأكيد التجديد ---
  void _confirmRenewal(BuildContext context, dynamic trainee) {
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
        content: Text("هل تريد تجديد اشتراك ${trainee.name} لمدة شهر إضافي؟"),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم تجديد الاشتراك بنجاح!"),
                  backgroundColor: Color(0xFF0D1B2A),
                ),
              );
            },
            child: const Text("تأكيد"),
          ),
        ],
      ),
    );
  }
}