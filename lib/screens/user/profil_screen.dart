import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(
                    title: 'Informasi Pribadi',
                    children: [
                      _buildInfoRow('Nama Lengkap', user.namaLengkap),
                      _buildInfoRow('Username', user.username),
                      _buildInfoRow('No. KTP', user.noKtp),
                      _buildInfoRow('Jenis Kelamin', user.jenisKelamin),
                      _buildInfoRow('Tempat Lahir', user.tempatLahir),
                      _buildInfoRow(
                        'Tanggal Lahir',
                        user.tanggalLahir.toString().split(' ')[0],
                      ),
                      _buildInfoRow('Alamat', user.alamat),
                      _buildInfoRow('No. Handphone', user.noHandphone),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(
                    title: 'Informasi Akun',
                    children: [
                      if (user.email != null)
                        _buildInfoRow('Email', user.email!),
                      _buildInfoRow(
                        'Tanggal Daftar',
                        user.createdAt.toString().split(' ')[0],
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
