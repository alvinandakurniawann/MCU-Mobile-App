import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/pendaftaran_provider.dart';
import 'daftar_mcu_screen.dart';
import 'riwayat_mcu_screen.dart';
import 'profil_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  int _carouselIndex = 0;

  final List<String> _carouselImages = [
    'assets/images/carousel1.jpg',
    'assets/images/carousel2.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future.microtask(() async {
      if (!mounted) return;
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      await context.read<PendaftaranProvider>().loadPendaftaranList();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWebLayout = constraints.maxWidth > 600;

          if (isWebLayout) {
            return Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth > 800,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  backgroundColor: const Color(0xFF1A237E),
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                  selectedLabelTextStyle: const TextStyle(color: Colors.white),
                  unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.7)),
                  unselectedLabelTextStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Beranda'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.medical_services_outlined),
                      selectedIcon: Icon(Icons.medical_services),
                      label: Text('Daftar MCU'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: Text('Riwayat MCU'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profil'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _buildSelectedScreen(),
                ),
              ],
            );
          }

          return Column(
            children: [
              Expanded(
                child: _buildSelectedScreen(),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFF1A237E),
                  unselectedItemColor: Colors.grey,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Beranda',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.medical_services_outlined),
                      activeIcon: Icon(Icons.medical_services),
                      label: 'Daftar MCU',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.history_outlined),
                      activeIcon: Icon(Icons.history),
                      label: 'Riwayat MCU',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person),
                      label: 'Profil',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const DaftarMCUScreen();
      case 2:
        return const RiwayatMCUScreen();
      case 3:
        return const ProfilScreen();
      default:
        return const Center(
          child: Text('Halaman tidak ditemukan'),
        );
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1A237E),
        ),
      );
    }

    return Consumer2<UserProvider, PendaftaranProvider>(
      builder: (context, userProvider, pendaftaranProvider, child) {
        if (pendaftaranProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1A237E),
            ),
          );
        }

        final user = userProvider.currentUser;
        if (user == null) {
          return const Center(
            child: Text('User tidak ditemukan'),
          );
        }

        final userPendaftaran = pendaftaranProvider.pendaftaranList
            .where((p) =>
                p.user.id == user.id && p.status.toLowerCase() != 'completed')
            .toList();

        userPendaftaran.sort(
            (a, b) => a.tanggalPendaftaran.compareTo(b.tanggalPendaftaran));

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWebLayout = constraints.maxWidth > 600;
            final padding = isWebLayout ? 24.0 : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF5B86E5), Color(0xFF36D1C4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, User',
                                  style: TextStyle(
                                    fontSize: isWebLayout ? 24 : 20,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.namaLengkap,
                                  style: TextStyle(
                                    fontSize: isWebLayout ? 28 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              backgroundImage: (user.fotoProfil != null && user.fotoProfil!.isNotEmpty)
                                  ? NetworkImage(user.fotoProfil!)
                                  : null,
                              child: (user.fotoProfil == null || user.fotoProfil!.isEmpty)
                                  ? const Icon(Icons.person, color: Colors.white, size: 24)
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.medical_services, color: Colors.white, size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Jadwal MCU Mendatang',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userPendaftaran.isEmpty
                                          ? 'Belum ada jadwal MCU'
                                          : '${userPendaftaran.length} jadwal MCU',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Carousel Section
                  SizedBox(
                    height: isWebLayout ? 200 : 175,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          itemCount: _carouselImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _carouselIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                _carouselImages[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_carouselImages.length, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _carouselIndex == index
                                      ? const Color(0xFF1A237E)
                                      : Colors.grey[300],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Menu Section
                  Text(
                    'Layanan MCU',
                    style: TextStyle(
                      fontSize: isWebLayout ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.hardEdge,
                      children: [
                        _MenuCard(
                          iconPath: 'assets/icons/darah.png',
                          label: 'Hematologi',
                          onTap: () => _showServiceDetails(
                            context,
                            'Hematologi',
                            'assets/icons/darah.png',
                            [
                              'Hemoglobin',
                              'Lekosit',
                              'Trombosit',
                              'Hematokrit',
                              'Hitung Jenis',
                              'LED',
                              'Eritosit',
                              'MC',
                            ],
                            deskripsi: 'Merupakan panel pemeriksaan yg terdiri dari Hemoglobin, Lekosit, Trombosit, Hematokrit, Hitung Jenis, LED, Eritosit, dan nilai-nilai MC. Pemeriksaan Hematologi merupakan pemeriksaan dasar yang digunakan secara luas mulai sebagai pemeriksaan penyaring, diagnosis maupun untuk mengikuti perkembangan penyakit; diantaranya penyakit infeksi, kelainan darah, penyakit degeneratif, dan lainnya. Spesimen Pemeriksaan: Darah dengan antikoagulan EDTA. Persiapan Pemeriksaan: Tidak ada persiapan khusus.',
                          ),
                        ),
                        _MenuCard(
                          iconPath: 'assets/icons/jantung.png',
                          label: 'Jantung',
                          onTap: () => _showServiceDetails(
                            context,
                            'Jantung',
                            'assets/icons/jantung.png',
                            [
                              'EKG',
                              'Treadmill',
                              'Ekokardiografi',
                            ],
                            deskripsi: 'Troponin T adalah protein spesifik yang hanya ada di otot jantung. Pemeriksaan Troponin T digunakan untuk evaluasi dugaan adanya kelainan iskemi koroner akut, misalnya pada kasus nyeri dada. Dibanding dengan cardiac marker lainnya (misalnya CK-MB), pemeriksaan troponin lebih spesifik dan sensitif dalam mendeteksi adanya kerusakan otot jantung. Spesimen Pemeriksaan: Darah. Persiapan Pemeriksaan: Tidak ada persiapan khusus.',
                          ),
                        ),
                        _MenuCard(
                          iconPath: 'assets/icons/paruparu.png',
                          label: 'Paru-paru',
                          onTap: () => _showServiceDetails(
                            context,
                            'Paru-paru',
                            'assets/icons/paruparu.png',
                            [
                              'Spirometri',
                              'Rontgen Thorax',
                            ],
                            deskripsi: 'Interferon-Gamma Release Assays (IGRA) adalah pemeriksaan darah yang digunakan untuk membantu dalam diagnosis penyakit Tuberkulosis (TB) maupun Infeksi Laten Tuberkulosis (LTBI). Pemeriksaan ini mengukur respon imun seluler terhadap M. Tuberculosis (M. TBC). Hasil Test IGRA yang positif mengindikasikan adanya infeksi oleh kuman TBC. Spesimen Pemeriksaan: Darah (plasma). Persiapan Pemeriksaan: Tidak ada persiapan khusus.',
                          ),
                        ),
                        _MenuCard(
                          iconPath: 'assets/icons/usus.png',
                          label: 'Faeces',
                          onTap: () => _showServiceDetails(
                            context,
                            'Faeces',
                            'assets/icons/usus.png',
                            [
                              'USG Abdomen',
                              'Kolonoskopi',
                            ],
                            deskripsi: 'Fecal Calprotectin adalah protein dalam faeces yang dikeluarkan ketika terjadi proses peradangan di usus. Pemeriksaan Fecal Calprotectin pada umumnya digunakan untuk membantu diagnosa dan monitoring penyakit inflammatory bowel disease (IBD), disamping menilai diare kronik karena inflamasi. Kadar Calprotectin meningkat didapatkan pada penyakit IBD, seperti Crohn\'s Disease atau ulcerative colitis. Spesimen Pemeriksaan: Faeses. Persiapan Pemeriksaan: Tidak ada persiapan khusus.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Upcoming MCU Section
                  Text(
                    'Jadwal MCU Mendatang',
                    style: TextStyle(
                      fontSize: isWebLayout ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUpcomingMCUList(userPendaftaran),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showServiceDetails(BuildContext context, String title, String iconPath, List<String> services, {String? deskripsi}) {
    // Pisahkan deskripsi utama, spesimen, dan persiapan
    String mainDesc = deskripsi ?? '-';
    String spesimen = '';
    String persiapan = '';
    if (deskripsi != null) {
      final spesimenMatch = RegExp(r'Spesimen Pemeriksaan *: *([^\.]+)').firstMatch(deskripsi);
      final persiapanMatch = RegExp(r'Persiapan Pemeriksaan *: *([^\.]+)').firstMatch(deskripsi);
      if (spesimenMatch != null) {
        spesimen = spesimenMatch.group(1)?.trim() ?? '';
        mainDesc = mainDesc.replaceAll(spesimenMatch.group(0)!, '').trim();
      }
      if (persiapanMatch != null) {
        persiapan = persiapanMatch.group(1)?.trim() ?? '';
        mainDesc = mainDesc.replaceAll(persiapanMatch.group(0)!, '').trim();
      }
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Image.asset(
              iconPath,
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Detail Pemeriksaan $title',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Deskripsi:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mainDesc,
                  style: const TextStyle(fontSize: 15),
                ),
                if (spesimen.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    'Spesimen Pemeriksaan',
                    spesimen,
                    Icons.bloodtype,
                  ),
                ],
                if (persiapan.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    'Persiapan Pemeriksaan',
                    persiapan,
                    Icons.info_outline,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Tutup',
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMCUList(List<dynamic> pendaftaranList) {
    if (pendaftaranList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text(
            'Belum ada jadwal MCU mendatang',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendaftaranList.length,
      itemBuilder: (context, index) {
        final pendaftaran = pendaftaranList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(pendaftaran.status).withOpacity(0.1),
              child: Icon(
                _getStatusIcon(pendaftaran.status),
                color: _getStatusColor(pendaftaran.status),
              ),
            ),
            title: Text(
              pendaftaran.paketMcu.namaPaket,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Tanggal: ${pendaftaran.tanggalPendaftaran.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Harga: Rp ${pendaftaran.paketMcu.harga.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: _buildStatusChip(pendaftaran.status),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      avatar: Icon(
        _getStatusIcon(status),
        color: Colors.white,
        size: 16,
      ),
      label: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getStatusColor(status),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: const Color(0xFF1A237E),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A237E), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback? onTap;
  final String? deskripsi;

  const _MenuCard({
    required this.iconPath,
    required this.label,
    this.onTap,
    this.deskripsi,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 3,
          child: Container(
            width: 180,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF5B86E5), Color(0xFF36D1C4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
