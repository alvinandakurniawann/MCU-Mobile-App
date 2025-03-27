import 'package:flutter/material.dart';

class PencarianPasienScreen extends StatefulWidget {
  const PencarianPasienScreen({Key? key}) : super(key: key);

  @override
  _PencarianPasienScreenState createState() => _PencarianPasienScreenState();
}

class _PencarianPasienScreenState extends State<PencarianPasienScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _pasienList = [
    {
      'nama': 'John Doe',
      'tanggal_lahir': '1990-01-01',
      'jenis_kelamin': 'Laki-laki',
      'alamat': 'Jakarta',
      'no_telp': '081234567890',
      'status': 'Aktif',
    },
    // Tambahkan data dummy lainnya di sini
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pencarian Pasien',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pasien...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              onChanged: (value) {
                // Implementasi pencarian
              },
            ),
          ),
          const SizedBox(height: 20),
          // Tabel Data Pasien
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('Tanggal Lahir')),
                  DataColumn(label: Text('Jenis Kelamin')),
                  DataColumn(label: Text('Alamat')),
                  DataColumn(label: Text('No. Telp')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: _pasienList.map((pasien) {
                  return DataRow(
                    cells: [
                      DataCell(Text(pasien['nama'])),
                      DataCell(Text(pasien['tanggal_lahir'])),
                      DataCell(Text(pasien['jenis_kelamin'])),
                      DataCell(Text(pasien['alamat'])),
                      DataCell(Text(pasien['no_telp'])),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: pasien['status'] == 'Aktif'
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pasien['status'],
                            style: TextStyle(
                              color: pasien['status'] == 'Aktif'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Implementasi edit
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Implementasi delete
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          // Tombol Tambah Pasien
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF40E0D0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Implementasi tambah pasien
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Tambah Pasien',
                    style: TextStyle(
                      color: Colors.white,
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
