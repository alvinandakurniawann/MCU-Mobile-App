import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';

class PasienAdminScreen extends StatefulWidget {
  const PasienAdminScreen({Key? key}) : super(key: key);

  @override
  State<PasienAdminScreen> createState() => _PasienAdminScreenState();
}

class _PasienAdminScreenState extends State<PasienAdminScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<UserProvider>().loadUserList(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pasien'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pasien berdasarkan nama atau No. KTP',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Text(provider.error!),
                  );
                }

                final filteredUsers = provider.userList.where((user) {
                  final searchLower = _searchQuery.toLowerCase();
                  return user.namaLengkap.toLowerCase().contains(searchLower) ||
                      user.noKtp.toLowerCase().contains(searchLower);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data pasien'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      child: ListTile(
                        title: Text(user.namaLengkap),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('No. KTP: ${user.noKtp}'),
                            Text('Jenis Kelamin: ${user.jenisKelamin}'),
                            Text(
                                'TTL: ${user.tempatLahir}, ${user.tanggalLahir.toString().split(' ')[0]}'),
                            Text('No. HP: ${user.noHandphone}'),
                            if (user.email != null && user.email!.isNotEmpty)
                              Text('Email: ${user.email}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () => _showDetailDialog(user),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Pasien'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Nama Lengkap', user.namaLengkap),
              _buildDetailItem('No. KTP', user.noKtp),
              _buildDetailItem('Jenis Kelamin', user.jenisKelamin),
              _buildDetailItem('Tempat Lahir', user.tempatLahir),
              _buildDetailItem(
                  'Tanggal Lahir', user.tanggalLahir.toString().split(' ')[0]),
              _buildDetailItem('Alamat', user.alamat),
              _buildDetailItem('No. Handphone', user.noHandphone),
              if (user.email != null && user.email!.isNotEmpty)
                _buildDetailItem('Email', user.email!),
              _buildDetailItem(
                  'Terdaftar Sejak', user.createdAt.toString().split(' ')[0]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
