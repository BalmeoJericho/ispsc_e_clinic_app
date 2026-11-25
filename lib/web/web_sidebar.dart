import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WebSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const WebSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<WebSidebar> createState() => _WebSidebarState();
}

class _WebSidebarState extends State<WebSidebar> {

////////////////////////////////////////////////////////////
/// LOGOUT CONFIRMATION
////////////////////////////////////////////////////////////

  Future<void> _confirmLogout() async {

    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

////////////////////////////////////////////////////////////
/// UI
////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 260,
      color: const Color(0xFF1E3A5F),

      child: Column(
        children: [

          const SizedBox(height: 30),

////////////////////////////////////////////////////////////
/// LOGO
////////////////////////////////////////////////////////////

          Image.asset(
            "assets/school_logo.png",
            height: 80,
          ),

          const SizedBox(height: 15),

          const Text(
            "ISPSC E-Clinic",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

////////////////////////////////////////////////////////////
/// MENU
////////////////////////////////////////////////////////////

          _buildItem(Icons.dashboard, "Overview", 0),
          _buildItem(Icons.people, "Employee Management", 1),
          _buildItem(Icons.people, "Patients", 2),

          _buildItem(
            Icons.science_outlined,
            "Laboratory Requests",
            3,
          ),

          _buildItem(Icons.book, "Logbook", 4),
          _buildItem(Icons.bar_chart, "Analytics", 5),
          _buildItem(Icons.history, "Activity Logs", 6),

          const Spacer(),

////////////////////////////////////////////////////////////
/// LOGOUT BUTTON (DIRECT)
////////////////////////////////////////////////////////////

          InkWell(
            onTap: _confirmLogout,

            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20),

              child: const Row(
                children: [

                  Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                  ),

                  SizedBox(width: 12),

                  Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////
/// NAV ITEM
////////////////////////////////////////////////////////////

  Widget _buildItem(IconData icon, String title, int index) {

    final bool isSelected = widget.selectedIndex == index;

    return InkWell(
      onTap: () => widget.onItemSelected(index),

      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20),

        color: isSelected
            ? Colors.white.withOpacity(0.1)
            : Colors.transparent,

        child: Row(
          children: [

            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Colors.white70,
            ),

            const SizedBox(width: 12),

            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}