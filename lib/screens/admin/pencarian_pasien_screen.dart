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
  final _searchController = TextEditingController();
  List<Pasien> _filteredPasien = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PasienProvider>().loadPasienList();
    });
  }

  void _filterPasien(String query) {
    final provider = Provider.of<PasienProvider>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredPasien = provider.pasienList;
      } else {
        _filteredPasien = provider.pasienList
            .where((pasien) =>
                pasien.nama.toLowerCase().contains(query.toLowerCase()) ||
                pasien.id.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
                hintText: 'Cari pasien berdasarkan nama atau ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterPasien('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterPasien,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<PasienProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(child: Text(provider.error!));
                  }

                  final pasienList = _searchController.text.isEmpty
                      ? provider.pasienList
                      : _filteredPasien;

                  if (pasienList.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada data pasien'),
                    );
                  }

                  return ListView.builder(
                    itemCount: pasienList.length,
                    itemBuilder: (context, index) {
                      final pasien = pasienList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(pasien.nama),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${pasien.id}'),
                              Text('Tanggal Lahir: ${pasien.tanggalLahir}'),
                              Text('Jenis Kelamin: ${pasien.jenisKelamin}'),
                            ],
                          ),
                          trailing: Icon(
                            Icons.circle,
                            color: pasien.status.toLowerCase() == 'aktif'
                                ? Colors.green
                                : Colors.red,
                            size: 12,
                          ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
