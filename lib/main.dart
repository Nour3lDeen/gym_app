import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/cubits/gym_cubit.dart';
import 'package:gym_app/screens/splash_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart'; // import notification service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await DatabaseService.init();
  await NotificationService.init();
  
  // ضيف السطر ده هنا عشان يطلب الإذن أول ما التطبيق يفتح
  await NotificationService.requestPermissions(); 

  runApp(const GymApp());
}

// أضف هذه الثوابت في بداية الملف أو في ملف منفصل
const Color kPrimaryColor = Color(0xFF0D1B2A); // كحلي غامق
const Color kGoldColor = Color(0xFFFFD700);    // ذهبي

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GymCubit(DatabaseService())..loadTrainees(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Captain Ahmed Gym',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5), // خلفية فاتحة مريحة للعين
          primaryColor: kPrimaryColor,
          fontFamily: 'Cairo',
          appBarTheme: const AppBarTheme(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: kGoldColor,
            foregroundColor: kPrimaryColor,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: kPrimaryColor,
            primary: kPrimaryColor,
            secondary: kGoldColor,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}