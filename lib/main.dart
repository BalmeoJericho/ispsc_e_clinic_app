import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'web/web_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        final firebaseUser = authSnapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!userSnapshot.hasData ||
                !userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    "User profile not found.",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            }

            final data = userSnapshot.data!.data()
                as Map<String, dynamic>;

            final role =
                (data['role'] ?? '').toString().toLowerCase();

            if (kIsWeb) {
              if (role == 'nurse') {
                return const WebDashboard();
              }

              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.lock,
                        size: 60,
                        color: Colors.red,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Access Denied",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "This account cannot access the web dashboard.",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // MOBILE ROUTING
            switch (role) {
              case 'employee':
                return const DashboardScreen(); // Replace later with EmployeeDashboard()

              case 'doctor':
                return const DashboardScreen(); // Replace later with DoctorDashboard()

              case 'nurse':
                return const DashboardScreen();

              default:
                return const Scaffold(
                  body: Center(
                    child: Text(
                      "Invalid user role.",
                    ),
                  ),
                );
            }
          },
        );
      },
    );
  }
}