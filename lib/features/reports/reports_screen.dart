import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.reports)),
      body: const Center(child: Text('Reports Content')),
    );
  }
}
