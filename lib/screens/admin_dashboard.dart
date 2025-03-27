import 'package:flutter/material.dart';
import 'pencarian_pasien_screen.dart';
import 'riwayat_pendaftaran_screen.dart';
import 'laporan_pemasukan_screen.dart';
import 'kelola_paket_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PencarianPasienScreen(),
    const RiwayatPendaftaranScreen(),
    const LaporanPemasukanScreen(),
    const KelolaPaketScreen(),
  ];

  final List<String> _titles = [
    'Pencarian Pasien',
    'Riwayat Pendaftaran MCU',
    'Laporan Pemasukan',
    'Kelola Paket MCU',
  ];

  final List<IconData> _icons = [
    Icons.search,
    Icons.history,
    Icons.monetization_on,
    Icons.medical_services,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFF40E0D0),
            child: Column(
              children: [
                // Logo dan Nama RS
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_hospital,
                          color: Color(0xFF40E0D0),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'RUMAH SAKIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.3)),
                // Menu Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _titles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(
                          _icons[index],
                          color: _selectedIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                        ),
                        title: Text(
                          _titles[index],
                          style: TextStyle(
                            color: _selectedIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            fontWeight: _selectedIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: _selectedIndex == index,
                        selectedTileColor: Colors.white.withOpacity(0.1),
                        onTap: () => setState(() => _selectedIndex = index),
                      );
                    },
                  ),
                ),
                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF40E0D0),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Implementasi logout
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder screens
class RiwayatPendaftaranScreen extends StatelessWidget {
  const RiwayatPendaftaranScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Riwayat Pendaftaran Screen'));
  }
}

class LaporanPemasukanScreen extends StatelessWidget {
  const LaporanPemasukanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Laporan Pemasukan Screen'));
  }
}

class KelolaPaketScreen extends StatelessWidget {
  const KelolaPaketScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Kelola Paket Screen'));
  }
}
