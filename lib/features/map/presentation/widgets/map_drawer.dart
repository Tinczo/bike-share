import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Drawer with profile, wallet, settings, and logout options.
class MapDrawer extends StatelessWidget {
  const MapDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Portfel'),
              onTap: () {
                Navigator.pop(context);
                context.push('/wallet');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('Historia wypozyczen'),
              onTap: () {
                Navigator.pop(context);
                context.push('/account/history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Moje zgloszenia'),
              onTap: () {
                Navigator.pop(context);
                context.push('/account/faults');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Ustawienia'),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Wyloguj się'),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }
}
