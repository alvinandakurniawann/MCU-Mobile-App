import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import 'dart:async';

class PasienAdminScreen extends StatefulWidget {
  const PasienAdminScreen({Key? key}) : super(key: key);

  @override
  State<PasienAdminScreen> createState() => _PasienAdminScreenState();
}

class _PasienAdminScreenState extends State<PasienAdminScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

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
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  List<User> _filterUsers(List<User> users) {
    if (_searchQuery.isEmpty) return users;
    final searchLower = _searchQuery.toLowerCase();
    return users.where((user) {
      return user.namaLengkap?.toLowerCase()?.contains(searchLower) ?? false;
    }).toList();
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
                hintText: 'Cari pasien berdasarkan nama, No. KTP, atau email',
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
              onChanged: _onSearchChanged,
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

                final filteredUsers = _filterUsers(provider.userList);

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Tidak ada data pasien'
                              : 'Tidak ada pasien yang ditemukan untuk pencarian "$_searchQuery"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: Text(
                            (user.namaLengkap != null && user.namaLengkap!.isNotEmpty)
                                ? user.namaLengkap![0].toUpperCase()
                                : '-',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user.namaLengkap ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('No. KTP: ${user.noKtp ?? '-'}'),
                            Text('Jenis Kelamin: ${user.jenisKelamin ?? '-'}'),
                            Text(
                                'TTL: ${user.tempatLahir ?? '-'}, ${user.tanggalLahir?.toString().split(' ')[0] ?? '-'}'),
                            Text('No. HP: ${user.noHandphone ?? '-'}'),
                            if (user.email != null && user.email!.isNotEmpty)
                              Text('Email: ${user.email ?? '-'}'),
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
              _buildDetailItem('Nama Lengkap', user.namaLengkap ?? '-'),
              _buildDetailItem('No. KTP', user.noKtp ?? '-'),
              _buildDetailItem('Jenis Kelamin', user.jenisKelamin ?? '-'),
              _buildDetailItem('Tempat Lahir', user.tempatLahir ?? '-'),
              _buildDetailItem(
                  'Tanggal Lahir', user.tanggalLahir?.toString().split(' ')[0] ?? '-'),
              _buildDetailItem('Alamat', user.alamat ?? '-'),
              _buildDetailItem('No. Handphone', user.noHandphone ?? '-'),
              if (user.email != null && user.email!.isNotEmpty)
                _buildDetailItem('Email', user.email ?? '-'),
              _buildDetailItem(
                  'Terdaftar Sejak', user.createdAt?.toString().split(' ')[0] ?? '-'),
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
