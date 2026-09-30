import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart'; // عشان ننتقل للصفحة الرئيسية

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. إعداد الأنيميشن (المدة 2 ثانية)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // 2. أنيميشن الظهور (Fade In)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // 3. أنيميشن التكبير (Scale) مع تأثير "نطة" خفيفة (BackOut)
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // تشغيل الأنيميشن
    _controller.forward();

    // 4. الانتقال للشاشة الرئيسية بعد 3 ثواني
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لون الخلفية (كحلي غامق يليق مع الذهبي)
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // اللوجو
                SizedBox(
                  width: 250, // حجم اللوجو
                  height: 250,
                  child: Image.asset('assets/logo.png'),
                ),
                const SizedBox(height: 20),
                // نص ترحيبي أو لودينج (اختياري)
                const CircularProgressIndicator(
                  color: Colors.amber, // لون ذهبي
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
