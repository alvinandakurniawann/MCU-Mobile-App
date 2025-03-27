import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Consumer<AuthProvider>(
              builder: (context, provider, child) {
                final user = provider.currentAdmin;
                if (user == null) {
                  return const Center(
                    child: Text('Data tidak tersedia'),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Nama'),
                          subtitle: Text(user.nama),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.account_circle),
                          title: const Text('Username'),
                          subtitle: Text(user.username),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('No. Handphone'),
                          subtitle: Text(user.noHandphone),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Alamat'),
                          subtitle: Text(user.alamat),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
