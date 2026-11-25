import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

      final AuthService _authService = AuthService();
      final UserService _userService = UserService();

      bool _loading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
  if (emailController.text.trim().isEmpty ||
      passwordController.text.trim().isEmpty) {
    _showError("Please enter email and password.");
    return;
  }

  setState(() {
    _loading = true;
  });

  try {
    final credential = await _authService.login(
  email: emailController.text,
  password: passwordController.text,
);

if (!mounted) return;

final uid = credential.user!.uid;

final userData = await _userService.getCurrentUser(uid);

if (!mounted) return;

    if (userData == null) {
      await FirebaseAuth.instance.signOut();
      _showError("Account not found.");
      return;
    }

    if (userData["status"] != "active") {
      await FirebaseAuth.instance.signOut();
      _showError("Account is inactive.");
      return;
    }

    // AuthWrapper will automatically open Dashboard
  } on FirebaseAuthException catch (e) {
    _showError(e.message ?? "Login failed.");
  } finally {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}
  void _showError(String message) {
  if (!mounted) return;

  setState(() {
    errorMessage = message;
  });
}


  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;
    return isWeb ? _buildWeb() : _buildMobile();
  }

  ////////////////////////////////////////////////////////////
  /// WEB LAYOUT
  ////////////////////////////////////////////////////////////

  Widget _buildWeb() {
    return Scaffold(
      body: Row(
        children: [

          /// LEFT HERO
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/clinic_bg.jpg",
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0D47A1).withOpacity(0.9),
                          const Color(0xFF1565C0).withOpacity(0.8),
                          const Color(0xFF26C6DA).withOpacity(0.7),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [

                          Text(
                            "Your Health Matters to Us",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),

                          SizedBox(height: 25),

                          Text(
                            "Smart Digital\nClinic\nManagement",
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),

                          SizedBox(height: 20),

                          Text(
                            "Ilocos Sur Polytechnic State College Tagudin Campus",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// RIGHT LOGIN PANEL
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFFF4F6FA),
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: 420,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 30,
                            color: Colors.black.withOpacity(0.08),
                          )
                        ],
                      ),
                      child: _loginForm(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// MOBILE LAYOUT (WITH BACKGROUND IMAGE)
  ////////////////////////////////////////////////////////////

  Widget _buildMobile() {
    return Scaffold(
      body: Stack(
        children: [

          /// Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/clinic_bg.jpg",
              fit: BoxFit.cover,
            ),
          ),

          /// Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0D47A1).withOpacity(0.85),
                    const Color(0xFF1565C0).withOpacity(0.75),
                    const Color(0xFF26C6DA).withOpacity(0.65),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          /// Login Card
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black.withOpacity(0.2),
                      )
                    ],
                  ),
                  child: _loginForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// LOGIN FORM
  ////////////////////////////////////////////////////////////

  Widget _loginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Image.asset(
          'assets/school_logo.png',
          height: 70,
        ),

        const SizedBox(height: 25),

        const Text(
          "ISPSC E-Clinic Login",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 30),

        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: "Email Address",
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 18),

        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            labelText: "Password",
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "LOGIN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          "© ISPSC Clinic 2026",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

