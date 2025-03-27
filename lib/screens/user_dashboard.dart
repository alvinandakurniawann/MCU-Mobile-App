import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:medcheck_mobile/screens/user/riwayat_mcu_screen.dart';
import 'package:medcheck_mobile/screens/user/daftar_mcu_screen.dart';
import 'package:medcheck_mobile/screens/user/profil_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DaftarMCUScreen(),
    const RiwayatMCUScreen(),
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            backgroundColor: const Color(0xFF40E0D0),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.local_hospital, color: Colors.white, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'RUMAH SAKIT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.add_box, color: Colors.white),
                selectedIcon: Icon(Icons.add_box_outlined, color: Colors.white),
                label:
                    Text('Daftar MCU', style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history, color: Colors.white),
                selectedIcon: Icon(Icons.history_outlined, color: Colors.white),
                label:
                    Text('Riwayat MCU', style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person, color: Colors.white),
                selectedIcon: Icon(Icons.person_outline, color: Colors.white),
                label: Text('Profil', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
