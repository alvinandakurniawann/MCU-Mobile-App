import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pendaftaran_provider.dart';

class RiwayatMCUScreen extends StatefulWidget {
  const RiwayatMCUScreen({super.key});

  @override
  State<RiwayatMCUScreen> createState() => _RiwayatMCUScreenState();
}

class _RiwayatMCUScreenState extends State<RiwayatMCUScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PendaftaranProvider>().loadPendaftaranList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat MCU'),
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

          final pendaftaranList = provider.pendaftaranList;

          if (pendaftaranList.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat MCU'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendaftaranList.length,
            itemBuilder: (context, index) {
              final pendaftaran = pendaftaranList[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pendaftaran.user.namaLengkap,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Paket: ${pendaftaran.paketMcu.namaPaket}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tanggal: ${pendaftaran.tanggalPendaftaran.toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Biaya: Rp ${pendaftaran.totalHarga}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(pendaftaran.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pendaftaran.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
