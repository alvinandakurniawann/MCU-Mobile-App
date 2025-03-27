import 'package:flutter/material.dart';

class RiwayatPendaftaranScreen extends StatefulWidget {
  const RiwayatPendaftaranScreen({Key? key}) : super(key: key);

  @override
  _RiwayatPendaftaranScreenState createState() =>
      _RiwayatPendaftaranScreenState();
}

class _RiwayatPendaftaranScreenState extends State<RiwayatPendaftaranScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = 'Semua';
  final List<String> _statusOptions = [
    'Semua',
    'Pending',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Pendaftaran MCU',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Filter Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _startDate?.toString().split(' ')[0] ?? '',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Tanggal Mulai',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _startDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _endDate?.toString().split(' ')[0] ?? '',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Tanggal Akhir',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _endDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: _statusOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedStatus = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF40E0D0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // Implementasi filter
                        },
                        child: const Text(
                          'Filter',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Tabel Data
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Tanggal')),
                    DataColumn(label: Text('Nama Pasien')),
                    DataColumn(label: Text('Paket MCU')),
                    DataColumn(label: Text('Total Biaya')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        const DataCell(Text('2024-03-27')),
                        const DataCell(Text('John Doe')),
                        const DataCell(Text('Paket A')),
                        const DataCell(Text('Rp 1.500.000')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Selesai',
                              style: TextStyle(
                                color: Colors.green,
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
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  // Implementasi detail
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.print,
                                    color: Colors.orange),
                                onPressed: () {
                                  // Implementasi print
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Tambahkan baris data lainnya di sini
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
