import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'image': 'assets/images/carousel1.jpg',
      'title': 'Medical Check Up',
      'description': 'Layanan pemeriksaan kesehatan menyeluruh untuk semua masyarakat',
      'color': const Color(0xFF1A237E),
    },
    {
      'image': 'assets/images/carousel2.jpg',
      'title': 'Layanan MCU',
      'description': 'Pemeriksaan kesehatan berkala untuk menjaga kesehatan Anda',
      'color': const Color(0xFF5B86E5),
    },
  ];

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future.microtask(() async {
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser != null) {
        await userProvider.loadCurrentUser(userProvider.currentUser!.username ?? '');
      }
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
      body: _buildSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Daftar MCU',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
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
            .where((p) => p.user.id == user.id)
            .toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWebLayout = constraints.maxWidth > 600;
            final padding = isWebLayout ? 24.0 : 16.0;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A237E), Color(0xFF5B86E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A237E).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (user.fotoProfil != null && user.fotoProfil!.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(16),
                                    child: InteractiveViewer(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: Image.network(
                                          user.fotoProfil!,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage: (user.fotoProfil != null && user.fotoProfil!.isNotEmpty)
                                  ? NetworkImage(user.fotoProfil!)
                                  : null,
                              child: (user.fotoProfil == null || user.fotoProfil!.isEmpty)
                                  ? Text(
                                      (user.namaLengkap != null && user.namaLengkap!.isNotEmpty)
                                          ? user.namaLengkap![0].toUpperCase()
                                          : '-',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A237E),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello,',
                                  style: TextStyle(
                                    fontSize: isWebLayout ? 16 : 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.namaLengkap ?? '-',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
                      height: isWebLayout ? 300 : 250,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemCount: _carouselItems.length,
                            onPageChanged: (index) {
                              setState(() {
                                _carouselIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = _carouselItems[index];
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: const EdgeInsets.all(16),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.asset(
                                          item['image'],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.asset(
                                          item['image'],
                                          fit: BoxFit.cover,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                item['color'].withOpacity(0.8),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 20,
                                          right: 20,
                                          bottom: 20,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['title'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  shadows: [
                                                    Shadow(
                                                      offset: Offset(0, 2),
                                                      blurRadius: 4,
                                                      color: Colors.black26,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                item['description'],
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 16,
                                                  shadows: const [
                                                    Shadow(
                                                      offset: Offset(0, 1),
                                                      blurRadius: 2,
                                                      color: Colors.black26,
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
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_carouselItems.length, (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _carouselIndex == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _carouselIndex == index
                                        ? const Color(0xFF1A237E)
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
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
                      height: 160,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          final services = [
                            {
                              'icon': 'assets/icons/darah.png',
                              'label': 'Hematologi',
                              'services': [
                                'Hemoglobin',
                                'Lekosit',
                                'Trombosit',
                                'Hematokrit',
                                'Hitung Jenis',
                                'LED',
                                'Eritosit',
                                'MC',
                              ],
                              'deskripsi': 'Merupakan panel pemeriksaan yg terdiri dari Hemoglobin, Lekosit, Trombosit, Hematokrit, Hitung Jenis, LED, Eritosit, dan nilai-nilai MC. Pemeriksaan Hematologi merupakan pemeriksaan dasar yang digunakan secara luas mulai sebagai pemeriksaan penyaring, diagnosis maupun untuk mengikuti perkembangan penyakit; diantaranya penyakit infeksi, kelainan darah, penyakit degeneratif, dan lainnya. Spesimen Pemeriksaan: Darah dengan antikoagulan EDTA. Persiapan Pemeriksaan: Tidak ada persiapan khusus.',
                            },
                            {
                              'icon': 'assets/icons/usus.png',
                              'label': 'Faeces',
                              'services': [
                                'Warna',
                                'Kejernihan',
                                'Berat Jenis',
                                'pH',
                                'Protein',
                                'Glukosa',
                                'Leukosit',
                                'Eritrosit',
                              ],
                              'deskripsi': 'Fecal Calprotectin adalah protein dalam faeces yang dikeluarkan ketika terjadi proses peradangan di usus. Pemeriksaan Fecal Calprotectin pada umumnya digunakan untuk membantu diagnosa dan monitoring penyakit inflammatory bowel disease (IBD), disamping menilai diare kronik karena inflamasi. Kadar Calprotectin meningkat didapatkan pada penyakit IBD, seperti Crohn\'s Disease atau ulcerative colitis. Spesimen Pemeriksaan: Tidak ada. Persiapan Pemeriksaan: Tidak ada persiapan khusus',
                            },
                            {
                              'icon': 'assets/icons/jantung.png',
                              'label': 'Jantung',
                              'services': [
                                'EKG',
                                'Treadmill',
                                'Ekokardiografi',
                                'Stress Test',
                              ],
                              'deskripsi': 'Troponin T adalah protein spesfik yang hanya ada di otot jantung. Pemeriksaan Troponin T digunakan untuk evaluasi dugaan adanya kelainan iskemi koroner akut, misalnya pada kasus nyeri dada. Dibanding dengan cardiac marker lainnya (misalnya CK-MB), pemeriksaan troponin lebih spesifik dan sensitif dalam medeteksi adanya kerusakan otot jantung. Spesimen Pemeriksaan: Darah. Persiapan Pemeriksaan: Tidak ada persiapan khusus.',
                            },
                            {
                              'icon': 'assets/icons/paruparu.png',
                              'label': 'Paru',
                              'services': [
                                'Spirometri',
                                'Rontgen Thorax',
                                'CT Scan Thorax',
                              ],
                              'deskripsi': 'Interferon-Gamma Release Assays (IGRA) adalah pemeriksaan darah yang digunakan untuk membantu dalam diagnosis penyakit Tuberkulosis (TB) maupun Infeksi Laten Tuberkulosis (LTBI). Pemeriksaan ini mengukur respon imun seluler terhadap M. Tuberculosis (M. TBC). Hasil Test IGRA yang positip mengindikasikan adanya infeksi oleh kuman TBC. Spesimen Pemeriksaan: Darah (plasma). Persiapan Pemeriksaan: Tidak ada persiapan khusus.',
                            },
                          ];

                          final service = services[index];
                          return _MenuCard(
                            iconPath: service['icon'] as String,
                            label: service['label'] as String,
                            onTap: () => _showServiceDetails(
                              context,
                              service['label'] as String,
                              service['icon'] as String,
                              service['services'] as List<String>,
                              deskripsi: service['deskripsi'] as String,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(width: 16),
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

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendaftaranList.length,
      itemBuilder: (context, index) {
        final pendaftaran = pendaftaranList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Tanggal
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy', 'id_ID').format(pendaftaran.tanggalPendaftaran),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                              Text(
                                DateFormat('MMM', 'id_ID').format(pendaftaran.tanggalPendaftaran),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nama dan detail
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pendaftaran.user.namaLengkap ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${pendaftaran.paketMcu.namaPaket} - '
                                '${pendaftaran.tanggalPendaftaran.hour.toString().padLeft(2, '0')}:${pendaftaran.tanggalPendaftaran.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        // Status
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(pendaftaran.status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pendaftaran.status,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16),
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
    return Container(
      width: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF5B86E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    iconPath,
                    width: 48,
                    height: 48,
                    color: null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
