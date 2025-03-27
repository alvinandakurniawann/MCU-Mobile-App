import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pasien_provider.dart';
import '../../models/pasien.dart';
import 'tambah_pasien_screen.dart';

class PencarianPasienScreen extends StatefulWidget {
  const PencarianPasienScreen({super.key});

  @override
  State<PencarianPasienScreen> createState() => _PencarianPasienScreenState();
}

class _PencarianPasienScreenState extends State<PencarianPasienScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PasienProvider>().loadPasienList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Pasien> _filterPasien(List<Pasien> pasienList) {
    if (_searchQuery.isEmpty) return pasienList;
    return pasienList.where((pasien) {
      return pasien.namaLengkap
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          pasien.noKtp.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pencarian Pasien',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TambahPasienScreen(),
                      ),
                    ).then((_) {
                      // Refresh list after adding new patient
                      context.read<PasienProvider>().loadPasienList();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Pasien'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama atau no. KTP',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<PasienProvider>(
                builder: (context, pasienProvider, child) {
                  if (pasienProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (pasienProvider.error != null) {
                    return Center(
                      child: Text('Error: ${pasienProvider.error}'),
                    );
                  }

                  final filteredPasien =
                      _filterPasien(pasienProvider.pasienList);

                  if (filteredPasien.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada pasien yang ditemukan'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredPasien.length,
                    itemBuilder: (context, index) {
                      final pasien = filteredPasien[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(pasien.namaLengkap[0]),
                          ),
                          title: Text(pasien.namaLengkap),
                          subtitle: Text('No. KTP: ${pasien.noKtp}'),
                          trailing: Text(pasien.status),
                          onTap: () {
                            // TODO: Implement view patient details
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
