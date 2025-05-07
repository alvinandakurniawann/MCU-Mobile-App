import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
      // TODO: Upload ke backend dan update userProvider.currentUser.fotoProfil
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF5B86E5), Color(0xFF36D1C4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (user.fotoProfil != null && user.fotoProfil!.isNotEmpty
                                      ? NetworkImage(user.fotoProfil!) as ImageProvider
                                      : null),
                              child: (user.fotoProfil == null || user.fotoProfil!.isEmpty) && _imageFile == null
                                  ? const Icon(Icons.person, size: 60, color: Color(0xFF1A237E))
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.namaLengkap,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.username,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            _biodataRow(Icons.credit_card, 'No. KTP', user.noKtp),
                            const Divider(),
                            _biodataRow(Icons.person, 'Nama Lengkap', user.namaLengkap),
                            const Divider(),
                            _biodataRow(Icons.location_city, 'Tempat Lahir', user.tempatLahir),
                            const Divider(),
                            _biodataRow(Icons.cake, 'Tanggal Lahir', _formatTanggal(user.tanggalLahir)),
                            const Divider(),
                            _biodataRow(Icons.wc, 'Jenis Kelamin', user.jenisKelamin),
                            const Divider(),
                            _biodataRow(Icons.home, 'Alamat', user.alamat),
                            const Divider(),
                            _biodataRow(Icons.email, 'Email', user.email ?? '-'),
                            const Divider(),
                            _biodataRow(Icons.phone, 'No. Handphone', user.noHandphone),
                            const Divider(),
                            _biodataRow(Icons.account_circle, 'Username', user.username),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          context.read<AuthProvider>().logout();
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _biodataRow(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A237E)),
      title: Text(label),
      subtitle: Text(value),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      dense: true,
    );
  }

  String _formatTanggal(DateTime tgl) {
    return "${tgl.day.toString().padLeft(2, '0')}-${tgl.month.toString().padLeft(2, '0')}-${tgl.year}";
  }
}
