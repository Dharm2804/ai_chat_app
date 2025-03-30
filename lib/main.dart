import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'src/login_signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _opacity = 1.0;
      });
      _animationController.forward();
    });

    // Show logo for 8 seconds
    Future.delayed(const Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Image.asset(
                "assets/load.gif", // Ensure this GIF exists in the assets folder
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
