import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pendaftaran_provider.dart';
import '../../models/pendaftaran_mcu.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PendaftaranProvider>().loadPendaftaranList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemeriksaan'),
      ),
      body: Consumer<PendaftaranProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text('Error: ${provider.error}'),
            );
          }

          if (provider.pendaftaranList.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat pemeriksaan'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.pendaftaranList.length,
            itemBuilder: (context, index) {
              final pendaftaran = provider.pendaftaranList[index];
              return Card(
                child: ListTile(
                  title: Text(pendaftaran.paketMcu.namaPaket),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal: ${pendaftaran.tanggalPendaftaran.day}/${pendaftaran.tanggalPendaftaran.month}/${pendaftaran.tanggalPendaftaran.year}',
                      ),
                      Text(
                        'Jam: ${pendaftaran.tanggalPendaftaran.hour}:${pendaftaran.tanggalPendaftaran.minute.toString().padLeft(2, '0')}',
                      ),
                      Text(
                          'Total: Rp ${pendaftaran.totalHarga.toStringAsFixed(0)}'),
                    ],
                  ),
                  trailing: Container(
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
                ),
              );
            },
          );
        },
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
