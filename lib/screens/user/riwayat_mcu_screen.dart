import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pendaftaran_provider.dart';
import '../../models/pendaftaran_mcu.dart';

class RiwayatMCUScreen extends StatefulWidget {
  const RiwayatMCUScreen({super.key});

  @override
  State<RiwayatMCUScreen> createState() => _RiwayatMCUScreenState();
}

class _RiwayatMCUScreenState extends State<RiwayatMCUScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PendaftaranProvider>().loadPendaftaranList();
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
            Text(
              'Riwayat MCU',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<PendaftaranProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(child: Text(provider.error!));
                  }

                  if (provider.pendaftaranList.isEmpty) {
                    return const Center(
                      child: Text('Belum ada riwayat MCU'),
                    );
                  }

                  return ListView.builder(
                    itemCount: provider.pendaftaranList.length,
                    itemBuilder: (context, index) {
                      final pendaftaran = provider.pendaftaranList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: const Text('Pendaftaran MCU'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Tanggal: ${pendaftaran.tanggalPendaftaran}'),
                              Text('Jam: ${pendaftaran.jamPendaftaran}'),
                              Text(
                                  'Total Biaya: Rp${pendaftaran.totalBiaya.toStringAsFixed(2)}'),
                              Text('Status: ${pendaftaran.status}'),
                              if (pendaftaran.keterangan != null)
                                Text('Keterangan: ${pendaftaran.keterangan}'),
                            ],
                          ),
                          trailing: _getStatusIcon(pendaftaran.status),
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

  Widget _getStatusIcon(String status) {
    IconData iconData;
    Color color;

    switch (status.toLowerCase()) {
      case 'selesai':
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case 'pending':
        iconData = Icons.pending;
        color = Colors.orange;
        break;
      case 'batal':
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      default:
        iconData = Icons.help;
        color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }
}
