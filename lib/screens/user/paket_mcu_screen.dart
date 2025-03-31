import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/paket_mcu_provider.dart';

class PaketMCUScreen extends StatefulWidget {
  const PaketMCUScreen({super.key});

  @override
  State<PaketMCUScreen> createState() => _PaketMCUScreenState();
}

class _PaketMCUScreenState extends State<PaketMCUScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PaketMCUProvider>().loadPaketList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paket MCU'),
      ),
      body: Consumer<PaketMCUProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text('Error: ${provider.error}'),
            );
          }

          if (provider.paketList.isEmpty) {
            return const Center(
              child: Text('Belum ada paket MCU tersedia'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.paketList.length,
            itemBuilder: (context, index) {
              final paket = provider.paketList[index];
              return Card(
                child: ListTile(
                  title: Text(paket.namaPaket),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(paket.deskripsi),
                      const SizedBox(height: 8),
                      Text('Harga: Rp ${paket.harga.toStringAsFixed(0)}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/pendaftaran',
                        arguments: paket,
                      );
                    },
                    child: const Text('Daftar'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
