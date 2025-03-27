import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/paket_mcu_provider.dart';
import '../../providers/pendaftaran_provider.dart';
import '../../models/paket_mcu.dart';

class DaftarMCUScreen extends StatefulWidget {
  const DaftarMCUScreen({super.key});

  @override
  State<DaftarMCUScreen> createState() => _DaftarMCUScreenState();
}

class _DaftarMCUScreenState extends State<DaftarMCUScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  PaketMCU? _selectedPaket;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaketMCUProvider>().loadPaketList();
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
              'Pendaftaran MCU',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Consumer<PaketMCUProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }

                return DropdownButtonFormField<PaketMCU>(
                  decoration: const InputDecoration(
                    labelText: 'Pilih Paket MCU',
                  ),
                  value: _selectedPaket,
                  items: provider.paketList
                      .map((paket) => DropdownMenuItem(
                            value: paket,
                            child: Text('${paket.nama} - Rp${paket.harga}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaket = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Pilih Tanggal'),
              subtitle: Text(_selectedDate == null
                  ? 'Belum dipilih'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Pilih Jam'),
              subtitle: Text(_selectedTime == null
                  ? 'Belum dipilih'
                  : '${_selectedTime!.hour}:${_selectedTime!.minute}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedPaket == null ||
                      _selectedDate == null ||
                      _selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mohon lengkapi semua data'),
                      ),
                    );
                    return;
                  }

                  final pendaftaranData = {
                    'id_paket': _selectedPaket!.id,
                    'tanggal_pendaftaran':
                        '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}',
                    'jam_pendaftaran':
                        '${_selectedTime!.hour}:${_selectedTime!.minute}:00',
                    'total_biaya': _selectedPaket!.harga,
                  };

                  final success = await context
                      .read<PendaftaranProvider>()
                      .createPendaftaran(pendaftaranData);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pendaftaran berhasil'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Reset form
                    setState(() {
                      _selectedPaket = null;
                      _selectedDate = null;
                      _selectedTime = null;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pendaftaran gagal'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Daftar MCU'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
