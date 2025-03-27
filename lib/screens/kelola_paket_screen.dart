import 'package:flutter/material.dart';

class KelolaPaketScreen extends StatefulWidget {
  const KelolaPaketScreen({Key? key}) : super(key: key);

  @override
  _KelolaPaketScreenState createState() => _KelolaPaketScreenState();
}

class _KelolaPaketScreenState extends State<KelolaPaketScreen> {
  final List<Map<String, dynamic>> _paketList = [
    {
      'nama': 'Paket A',
      'deskripsi': 'Pemeriksaan dasar kesehatan',
      'harga': 'Rp 1.500.000',
      'status': 'Aktif',
    },
    {
      'nama': 'Paket B',
      'deskripsi': 'Pemeriksaan kesehatan lengkap',
      'harga': 'Rp 2.500.000',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kelola Paket MCU',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40E0D0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Implementasi tambah paket
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Tambah Paket',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tabel Data Paket
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nama Paket')),
                    DataColumn(label: Text('Deskripsi')),
                    DataColumn(label: Text('Harga')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: _paketList.map((paket) {
                    return DataRow(
                      cells: [
                        DataCell(Text(paket['nama'])),
                        DataCell(Text(paket['deskripsi'])),
                        DataCell(Text(paket['harga'])),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: paket['status'] == 'Aktif'
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              paket['status'],
                              style: TextStyle(
                                color: paket['status'] == 'Aktif'
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
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // Implementasi edit
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
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
          ),
        ],
      ),
    );
  }
}
