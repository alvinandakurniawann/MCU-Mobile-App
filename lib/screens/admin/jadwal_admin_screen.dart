import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pendaftaran_provider.dart';
import '../../models/pendaftaran_mcu.dart';

class JadwalAdminScreen extends StatefulWidget {
  const JadwalAdminScreen({super.key});

  @override
  State<JadwalAdminScreen> createState() => _JadwalAdminScreenState();
}

class _JadwalAdminScreenState extends State<JadwalAdminScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PendaftaranProvider>().loadPendaftaranList();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await context.read<PendaftaranProvider>().updatePendaftaran(
        id,
        {'status': status},
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<PendaftaranProvider>().error ??
                  'Gagal memperbarui status',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Pemeriksaan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Pilih Tanggal'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PendaftaranProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Text('Error: ${provider.error}'),
                  );
                }

                final filteredPendaftaran = provider.pendaftaranList.where((p) {
                  return p.tanggalPendaftaran.year == _selectedDate.year &&
                      p.tanggalPendaftaran.month == _selectedDate.month &&
                      p.tanggalPendaftaran.day == _selectedDate.day;
                }).toList();

                if (filteredPendaftaran.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada jadwal pemeriksaan'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredPendaftaran.length,
                  itemBuilder: (context, index) {
                    final pendaftaran = filteredPendaftaran[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(pendaftaran.user.namaLengkap),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Paket: ${pendaftaran.paketMcu.namaPaket}'),
                            Text(
                              'Jam: ${pendaftaran.tanggalPendaftaran.hour}:${pendaftaran.tanggalPendaftaran.minute.toString().padLeft(2, '0')}',
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(pendaftaran.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                pendaftaran.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (pendaftaran.status == 'pending') ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.check_circle),
                                color: Colors.green,
                                onPressed: _isLoading
                                    ? null
                                    : () => _updateStatus(
                                          pendaftaran.id,
                                          'completed',
                                        ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel),
                                color: Colors.red,
                                onPressed: _isLoading
                                    ? null
                                    : () => _updateStatus(
                                          pendaftaran.id,
                                          'cancelled',
                                        ),
                              ),
                            ],
                          ],
                        ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
