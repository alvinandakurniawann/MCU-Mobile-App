import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser != null) {
        await userProvider.loadCurrentUser(userProvider.currentUser!.username ?? '');
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        setState(() {
          _isUploading = true;
        });

        final file = File(result.files.single.path!);
        final supabase = Supabase.instance.client;
        final userId = supabase.auth.currentUser?.id;

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User belum login!')),
          );
          setState(() {
            _isUploading = false;
          });
          return;
        }

        final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        final bucket = dotenv.env['SUPABASE_BUCKET'] ?? 'profile-pictures';

        final response = await supabase.storage
            .from(bucket)
            .upload(fileName, file);

        if (response == null || response.isEmpty) {
          throw 'Gagal upload file ke storage';
        }

        final imageUrl = supabase.storage
            .from(bucket)
            .getPublicUrl(fileName);
        print('URL foto upload: ' + imageUrl);

        final userProvider = context.read<UserProvider>();
        final success = await userProvider.updateProfilePhoto(imageUrl);

        if (success) {
          await userProvider.loadCurrentUser(userProvider.currentUser?.username ?? '');
          print('User setelah refresh: ' + (userProvider.currentUser?.fotoProfil ?? 'null'));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui foto profil')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
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
                            (user.fotoProfil != null && user.fotoProfil!.isNotEmpty)
                                ? CircleAvatar(
                                    radius: 48,
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(user.fotoProfil!),
                                    onBackgroundImageError: (exception, stackTrace) {
                                      print('Error loading image: ' + exception.toString());
                                    },
                                    child: _isUploading
                                        ? const CircularProgressIndicator()
                                        : null,
                                  )
                                : CircleAvatar(
                                    radius: 48,
                                    backgroundColor: Colors.white,
                                    child: _isUploading
                                        ? const CircularProgressIndicator()
                                        : const Icon(Icons.person, size: 60, color: Color(0xFF1A237E)),
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
                          user.namaLengkap ?? '-',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.username ?? '-',
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
                            _biodataRow(Icons.credit_card, 'No. KTP', user.noKtp ?? '-'),
                            const Divider(),
                            _biodataRow(Icons.person, 'Nama Lengkap', user.namaLengkap ?? '-'),
                            const Divider(),
                            _biodataRow(Icons.location_city, 'Tempat Lahir', user.tempatLahir ?? '-'),
                            const Divider(),
                            _biodataRow(Icons.cake, 'Tanggal Lahir', _formatTanggal(user.tanggalLahir)),
                            const Divider(),
                            _biodataRow(Icons.wc, 'Jenis Kelamin', user.jenisKelamin ?? '-'),
                            const Divider(),
                            _biodataRow(Icons.home, 'Alamat', user.alamat ?? '-'),
                            const Divider(),
                            _biodataRow(Icons.email, 'Email', user.email ?? '-'),
                            const Divider(),
                            _biodataRow(Icons.phone, 'No. Handphone', user.noHandphone ?? '-'),
                            const Divider(),
                            _biodataRow(Icons.account_circle, 'Username', user.username ?? '-'),
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

  String _formatTanggal(DateTime? tgl) {
    if (tgl == null) return '-';
    return "${tgl.day.toString().padLeft(2, '0')}-${tgl.month.toString().padLeft(2, '0')}-${tgl.year}";
  }
}
