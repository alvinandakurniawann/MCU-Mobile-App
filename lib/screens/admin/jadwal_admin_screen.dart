import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pendaftaran_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/paket_mcu_provider.dart';
import '../../models/user.dart';
import '../../models/paket_mcu.dart';
import 'package:intl/intl.dart';

class JadwalAdminScreen extends StatefulWidget {
  const JadwalAdminScreen({super.key});

  @override
  State<JadwalAdminScreen> createState() => _JadwalAdminScreenState();
}

class _JadwalAdminScreenState extends State<JadwalAdminScreen> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  bool _isLoading = false;
  User? _selectedUser;
  PaketMCU? _selectedPaket;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PendaftaranProvider>().loadPendaftaranList();
      }
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: _endDate,
    );
    if (picked != null && picked != _startDate && mounted) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate && mounted) {
      setState(() {
        _endDate = picked;
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

  Future<void> _showTambahJadwalDialog(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final paketProvider = Provider.of<PaketMCUProvider>(context, listen: false);
    await userProvider.loadUserList();
    await paketProvider.loadPaketList();
    final _formKey = GlobalKey<FormState>();
    _selectedUser = null;
    _selectedPaket = null;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text('Tambah Jadwal MCU'),
              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) return const CircularProgressIndicator();
                            return DropdownButtonFormField<User>(
                              value: _selectedUser,
                              decoration: InputDecoration(
                                labelText: 'Pilih User',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: provider.userList.map((user) => DropdownMenuItem(
                                value: user,
                                child: Text(user.namaLengkap ?? '-'),
                              )).toList(),
                              onChanged: (val) => setState(() => _selectedUser = val),
                              validator: (val) => val == null ? 'Pilih user' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Consumer<PaketMCUProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) return const CircularProgressIndicator();
                            return DropdownButtonFormField<PaketMCU>(
                              value: _selectedPaket,
                              decoration: InputDecoration(
                                labelText: 'Pilih Paket MCU',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: provider.paketList.map((paket) => DropdownMenuItem(
                                value: paket,
                                child: Text(paket.namaPaket),
                              )).toList(),
                              onChanged: (val) => setState(() => _selectedPaket = val),
                              validator: (val) => val == null ? 'Pilih paket' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today, color: Color(0xFF1A237E)),
                          title: const Text('Tanggal Pemeriksaan'),
                          subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit_calendar),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setState(() => _selectedDate = picked);
                            },
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.access_time, color: Color(0xFF1A237E)),
                          title: const Text('Jam Pemeriksaan'),
                          subtitle: Text('${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _selectedTime,
                              );
                              if (picked != null) setState(() => _selectedTime = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    if (_selectedUser == null || _selectedPaket == null) return;
                    final tanggal = DateTime(
                      _selectedDate.year, _selectedDate.month, _selectedDate.day,
                      _selectedTime.hour, _selectedTime.minute,
                    );
                    final success = await Provider.of<PendaftaranProvider>(context, listen: false).createPendaftaran(
                      userId: _selectedUser!.id,
                      paketMcuId: _selectedPaket!.id,
                      tanggalPendaftaran: tanggal,
                      totalHarga: _selectedPaket!.harga,
                    );
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jadwal berhasil ditambahkan'), backgroundColor: Colors.green),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(Provider.of<PendaftaranProvider>(context, listen: false).error ?? 'Gagal menambah jadwal'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Tambah Jadwal', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditJadwalDialog(BuildContext context, dynamic pendaftaran) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final paketProvider = Provider.of<PaketMCUProvider>(context, listen: false);
    await userProvider.loadUserList();
    await paketProvider.loadPaketList();
    
    final _formKey = GlobalKey<FormState>();
    User? selectedUser;
    PaketMCU? selectedPaket;
    try {
      selectedUser = userProvider.userList.firstWhere((user) => user.id.toString() == pendaftaran.user.id.toString());
    } catch (_) {
      selectedUser = null;
    }
    try {
      selectedPaket = paketProvider.paketList.firstWhere((paket) => paket.id.toString() == pendaftaran.paketMcu.id.toString());
    } catch (_) {
      selectedPaket = null;
    }
    DateTime selectedDate = pendaftaran.tanggalPendaftaran;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(pendaftaran.tanggalPendaftaran);

    if (!context.mounted) return;

    if (selectedUser == null || selectedPaket == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Data Tidak Ditemukan'),
          content: Text('User ID: \\${pendaftaran.user.id}\nPaket MCU ID: \\${pendaftaran.paketMcu.id}\nTidak dapat mengedit jadwal ini.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text('Edit Jadwal MCU'),
              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) return const CircularProgressIndicator();
                            return DropdownButtonFormField<User>(
                              value: selectedUser,
                              decoration: InputDecoration(
                                labelText: 'Pilih User',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: provider.userList.map((user) => DropdownMenuItem(
                                value: user,
                                child: Text(user.namaLengkap ?? '-'),
                              )).toList(),
                              onChanged: (val) => setState(() => selectedUser = val),
                              validator: (val) => val == null ? 'Pilih user' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Consumer<PaketMCUProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) return const CircularProgressIndicator();
                            return DropdownButtonFormField<PaketMCU>(
                              value: selectedPaket,
                              decoration: InputDecoration(
                                labelText: 'Pilih Paket MCU',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: provider.paketList.map((paket) => DropdownMenuItem(
                                value: paket,
                                child: Text(paket.namaPaket),
                              )).toList(),
                              onChanged: (val) => setState(() => selectedPaket = val),
                              validator: (val) => val == null ? 'Pilih paket' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today, color: Color(0xFF1A237E)),
                          title: const Text('Tanggal Pemeriksaan'),
                          subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit_calendar),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setState(() => selectedDate = picked);
                            },
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.access_time, color: Color(0xFF1A237E)),
                          title: const Text('Jam Pemeriksaan'),
                          subtitle: Text('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (picked != null) setState(() => selectedTime = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    
                    if (selectedUser == null || selectedPaket == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pilih user dan paket terlebih dahulu'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    final tanggal = DateTime(
                      selectedDate.year, selectedDate.month, selectedDate.day,
                      selectedTime.hour, selectedTime.minute,
                    );
                    
                    final updateData = {
                      'user_id': selectedUser?.id,
                      'paket_mcu_id': selectedPaket?.id,
                      'tanggal_pendaftaran': tanggal.toIso8601String(),
                      'total_harga': selectedPaket?.harga,
                    };
                    
                    final success = await Provider.of<PendaftaranProvider>(context, listen: false)
                        .updatePendaftaran(pendaftaran.id, updateData);
                        
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Jadwal berhasil diperbarui'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Refresh the list
                      if (mounted) {
                        context.read<PendaftaranProvider>().loadPendaftaranList();
                      }
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            Provider.of<PendaftaranProvider>(context, listen: false).error ?? 'Gagal memperbarui jadwal',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _deleteJadwal(String id) async {
    try {
      final success = await context.read<PendaftaranProvider>().deletePendaftaran(id);
      return success;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jadwal',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Pemeriksaan',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              onPressed: _isLoading ? null : () => _showTambahJadwalDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Jadwal'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dari: \\${_startDate.day}/\\${_startDate.month}/\\${_startDate.year}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Sampai: \\${_endDate.day}/\\${_endDate.month}/\\${_endDate.year}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _selectStartDate(context),
                      icon: const Icon(Icons.date_range, size: 18),
                      label: const Text('Dari', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _selectEndDate(context),
                      icon: const Icon(Icons.date_range, size: 18),
                      label: const Text('Sampai', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                  ],
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
                  return p.tanggalPendaftaran.isAfter(_startDate.subtract(const Duration(days: 1))) &&
                         p.tanggalPendaftaran.isBefore(_endDate.add(const Duration(days: 1)));
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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tanggal
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat('d').format(pendaftaran.tanggalPendaftaran),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      Text(
                                        DateFormat('MMM', 'id_ID').format(pendaftaran.tanggalPendaftaran),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Nama dan detail
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pendaftaran.user.namaLengkap ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${pendaftaran.paketMcu.namaPaket} - '
                                        '${pendaftaran.tanggalPendaftaran.hour.toString().padLeft(2, '0')}:${pendaftaran.tanggalPendaftaran.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Icon Edit & Delete di pojok kanan atas
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF1A237E), size: 20),
                                  tooltip: 'Edit Jadwal',
                                  onPressed: () {
                                    if (mounted) {
                                      _showEditJadwalDialog(context, pendaftaran);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  tooltip: 'Hapus Jadwal',
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      title: const Text('Konfirmasi Hapus'),
                                      content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            final success = await _deleteJadwal(pendaftaran.id);
                                            if (success && context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Jadwal berhasil dihapus'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                              if (mounted) {
                                                context.read<PendaftaranProvider>().loadPendaftaranList();
                                              }
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status di bawah tombol edit/delete
                          Positioned(
                            top: 40,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(pendaftaran.status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pendaftaran.status,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
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
