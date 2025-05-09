import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pendaftaran_provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:async';

class RiwayatMCUScreen extends StatefulWidget {
  const RiwayatMCUScreen({super.key});

  @override
  State<RiwayatMCUScreen> createState() => _RiwayatMCUScreenState();
}

class _RiwayatMCUScreenState extends State<RiwayatMCUScreen> {
  late final Timer _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<PendaftaranProvider>().loadUserPendaftaranList(user.id);
        _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          if (mounted) {
            context.read<PendaftaranProvider>().loadUserPendaftaranList(user.id);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF5B86E5), Color(0xFF36D1C4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.history, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Riwayat MCU',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Consumer<PendaftaranProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(child: Text('Error: ${provider.error}'));
                }
                final pendaftaranList = provider.pendaftaranList;
                if (pendaftaranList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('Belum ada riwayat MCU', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendaftaranList.length,
                  itemBuilder: (context, index) {
                    final pendaftaran = pendaftaranList[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _getStatusColor(pendaftaran.status).withOpacity(0.15),
                                  child: Icon(_getStatusIcon(pendaftaran.status), color: _getStatusColor(pendaftaran.status)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pendaftaran.paketMcu.namaPaket,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
                                const SizedBox(width: 6),
                                Text(
                                  'Tanggal: ${pendaftaran.tanggalPendaftaran.toString().split(' ')[0]}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Rp',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Total Biaya: Rp ${NumberFormat('#,##0.00', 'id_ID').format(pendaftaran.totalHarga)}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check;
      case 'completed':
        return Icons.done;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
