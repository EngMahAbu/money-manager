import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'metric_card.dart';
import 'list_row.dart';
import 'transaction_row.dart';
import 'bottom_nav_bar.dart';
import 'toggle_switch.dart';
import 'filter_chip.dart';
import 'section_header.dart';
import '../theme/app_colors.dart';

class ComponentGalleryScreen extends StatefulWidget {
  const ComponentGalleryScreen({super.key});

  @override
  State<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends State<ComponentGalleryScreen> {
  bool _toggleValue = false;
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Component Gallery')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Metric Cards'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'Income',
                    value: '\$2,450.00',
                    icon: TablerIcons.trending_up,
                    isSuccess: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    label: 'Expense',
                    value: '\$1,200.00',
                    icon: TablerIcons.trending_down,
                    isSuccess: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Accounts',
              actionLabel: 'See all',
              onActionPressed: () {},
            ),
            const SizedBox(height: 12),
            ListRow(
              leading: const Icon(TablerIcons.building_bank, size: 20),
              label: 'Main Bank',
              subtitle: 'Bank account',
              value: '\$12,450.00',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            ListRow(
              leading: const Icon(TablerIcons.credit_card, size: 20, color: AppColors.danger),
              label: 'Credit Card',
              subtitle: 'Debt',
              value: '-\$450.00',
              valueColor: AppColors.dangerText,
              onTap: () {},
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Recent Transactions'),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  TransactionRow(
                    icon: TablerIcons.shopping_cart,
                    name: 'Groceries',
                    timestamp: 'Today, 2:30 PM',
                    amount: '85.20',
                    isIncome: false,
                  ),
                  TransactionRow(
                    icon: TablerIcons.briefcase,
                    name: 'Salary',
                    timestamp: 'Yesterday',
                    amount: '3,500.00',
                    isIncome: true,
                  ),
                  TransactionRow(
                    icon: TablerIcons.building_bank,
                    name: 'Transfer to Savings',
                    timestamp: 'Aug 5',
                    amount: '500.00',
                    isTransfer: true,
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Interactive Components'),
            const SizedBox(height: 12),
            Row(
              children: [
                AppFilterChip(
                  label: 'This Month',
                  isActive: true,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                AppFilterChip(
                  label: 'All Accounts',
                  isActive: false,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('App Lock'),
                AppToggleSwitch(
                  value: _toggleValue,
                  onChanged: (v) => setState(() => _toggleValue = v),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        onQuickAdd: () {},
      ),
      floatingActionButton: QuickAddFab(onPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
