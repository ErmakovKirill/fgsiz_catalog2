import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Продолжительность анимации
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Тип анимации
    );
    _controller.forward(); // Запускаем анимацию
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home'); // Замените '/home' на маршрут главного экрана
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox( // Логотип компании
                width: 400,
                child: Image.asset(
                  'assets/images/main_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox( // Бренд 1
                    width: 200, // Увеличиваем ширину бренда
                    child: Image.asset(
                      'assets/images/brand1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox( // Бренд 2
                    width: 200,
                    child: Image.asset(
                      'assets/images/brand2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}