import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pasien_provider.dart';

class TambahPasienScreen extends StatefulWidget {
  const TambahPasienScreen({super.key});

  @override
  State<TambahPasienScreen> createState() => _TambahPasienScreenState();
}

class _TambahPasienScreenState extends State<TambahPasienScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  String _jenisKelamin = 'Laki-laki';
  final _alamatController = TextEditingController();
  final _noTelpController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    _noTelpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pasien'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tanggalLahirController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Lahir',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _tanggalLahirController.text =
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal lahir tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin',
                  prefixIcon: Icon(Icons.people),
                ),
                value: _jenisKelamin,
                items: ['Laki-laki', 'Perempuan']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _jenisKelamin = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noTelpController,
                decoration: const InputDecoration(
                  labelText: 'No. Telepon',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'No. Telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Consumer<PasienProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final pasienData = {
                            'nama': _namaController.text,
                            'tanggal_lahir': _tanggalLahirController.text,
                            'jenis_kelamin': _jenisKelamin,
                            'alamat': _alamatController.text,
                            'no_telp': _noTelpController.text,
                            'status': 'aktif',
                          };

                          final success =
                              await provider.createPasien(pasienData);

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pasien berhasil ditambahkan'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.error ??
                                    'Gagal menambahkan pasien'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Simpan'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
