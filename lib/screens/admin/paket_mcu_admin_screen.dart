import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/paket_mcu_provider.dart';
import '../../models/paket_mcu.dart';

class PaketMCUAdminScreen extends StatefulWidget {
  const PaketMCUAdminScreen({super.key});

  @override
  State<PaketMCUAdminScreen> createState() => _PaketMCUAdminScreenState();
}

class _PaketMCUAdminScreenState extends State<PaketMCUAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaPaketController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();
  bool _isLoading = false;
  PaketMCU? _selectedPaket;

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
  void dispose() {
    _namaPaketController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  void _editPaket(PaketMCU paket) {
    setState(() {
      _selectedPaket = paket;
      _namaPaketController.text = paket.namaPaket;
      _deskripsiController.text = paket.deskripsi;
      _hargaController.text = NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 0,
      ).format(paket.harga);
    });
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    // Hapus semua karakter non-angka
    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericValue.isEmpty) return '';
    // Format angka dengan titik sebagai pemisah ribuan
    return NumberFormat('#,###', 'id_ID').format(int.parse(numericValue)).replaceAll(',', '.');
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Hapus titik sebelum parsing ke double
        final hargaString = _hargaController.text.replaceAll('.', '');
        final paketData = {
          'nama_paket': _namaPaketController.text,
          'harga': double.parse(hargaString),
          'deskripsi': _deskripsiController.text,
        };
        
        bool success;
        if (_selectedPaket == null) {
          success = await context.read<PaketMCUProvider>().createPaket(paketData);
        } else {
          success = await context.read<PaketMCUProvider>()
              .updatePaket(_selectedPaket!.id, paketData);
        }
        
        if (!mounted) return;
        
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedPaket == null ? 'Paket berhasil ditambahkan' : 'Paket berhasil diperbarui',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _resetForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<PaketMCUProvider>().error ?? 'Gagal menyimpan paket',
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
  }

  void _resetForm() {
    setState(() {
      _selectedPaket = null;
      _namaPaketController.clear();
      _deskripsiController.clear();
      _hargaController.clear();
    });
  }

  Future<void> _deletePaket(String id) async {
    try {
      final success = await context.read<PaketMCUProvider>().deletePaketMCU(id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paket MCU berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<PaketMCUProvider>().error ?? 'Gagal menghapus paket',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Paket MCU'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _namaPaketController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Paket',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama paket tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deskripsiController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hargaController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (numericValue.isEmpty) {
                        _hargaController.text = '';
                        return;
                      }
                      String formatted = NumberFormat('#,###', 'id_ID').format(int.parse(numericValue)).replaceAll(',', '.');
                      if (formatted != value) {
                        final newSelection = TextSelection.collapsed(offset: formatted.length);
                        _hargaController.value = TextEditingValue(
                          text: formatted,
                          selection: newSelection,
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (numericValue.isEmpty) {
                        return 'Harga harus berupa angka';
                      }
                      if (int.tryParse(numericValue) == null) {
                        return 'Harga harus berupa angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                  _selectedPaket == null ? 'Simpan' : 'Update'),
                        ),
                      ),
                      if (_selectedPaket != null) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _resetForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Daftar Paket MCU',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<PaketMCUProvider>(
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
                    child: Text('Belum ada paket MCU'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.paketList.length,
                  itemBuilder: (context, index) {
                    final paket = provider.paketList[index];
                    return Card(
                      child: ListTile(
                        title: Text(paket.namaPaket),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(paket.harga),
                            ),
                            Text(
                              paket.deskripsi,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editPaket(paket),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus paket ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deletePaket(paket.id);
                                      },
                                      child: const Text('Hapus'),
                                    ),
                                  ],
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
          ],
        ),
      ),
    );
  }
}
