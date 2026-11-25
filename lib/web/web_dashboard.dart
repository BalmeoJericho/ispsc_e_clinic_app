import 'package:flutter/material.dart';
import 'web_sidebar.dart';
import 'web_home.dart';
import 'web_patients_page.dart';
import 'web_logbook_page.dart';
import 'web_analytics.dart';
import 'web_activity_logs.dart';
import 'web_employee_page.dart';
import 'web_lab_request_page.dart';

class WebDashboard extends StatefulWidget {
  const WebDashboard({super.key});

  @override
  State<WebDashboard> createState() => _WebDashboardState();
}

class _WebDashboardState extends State<WebDashboard> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          WebSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildPage(),
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// PAGE ROUTER
  ////////////////////////////////////////////////////////////

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return const WebHome();

      case 1:
        return const WebEmployeePage();

      case 2:
        return const WebPatients();

      case 3:
        return const WebLabRequestPage();

      case 4:
        return const WebLogbook();

      case 5:
        return const WebAnalytics();

      case 6:
        return const WebActivityLogs();

      default:
        return const WebHome();
    }
  }
}