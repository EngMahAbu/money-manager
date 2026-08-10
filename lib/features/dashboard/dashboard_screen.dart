import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboard),
      ),
      body: const Center(
        child: Text('Dashboard Content will go here'),
      ),
    );
  }
}
