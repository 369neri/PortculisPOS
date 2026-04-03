import 'package:cashier_app/core/layout/responsive_layout.dart';
import 'package:flutter/material.dart';

/// Destinations shown in the navigation shell.
enum NavDestination {
  register(icon: Icons.point_of_sale, label: 'Register'),
  items(icon: Icons.inventory_2_outlined, label: 'Items'),
  reports(icon: Icons.bar_chart, label: 'Reports'),
  settings(icon: Icons.settings_outlined, label: 'Settings');

  const NavDestination({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Adaptive navigation shell.
///
/// Uses [NavigationBar] (bottom) on phones and [NavigationRail] (side) on
/// tablets / desktop / web.
class AdaptiveNavShell extends StatefulWidget {
  const AdaptiveNavShell({required this.pages, super.key});

  /// One page widget per [NavDestination], in the same order.
  final List<Widget> pages;

  @override
  State<AdaptiveNavShell> createState() => _AdaptiveNavShellState();
}

class _AdaptiveNavShellState extends State<AdaptiveNavShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);

    return Scaffold(
      body: wide ? _buildRailLayout() : _buildBody(),
      bottomNavigationBar: wide ? null : _buildBottomBar(),
    );
  }

  Widget _buildBody() => widget.pages[_selectedIndex];

  Widget _buildBottomBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      destinations: [
        for (final dest in NavDestination.values)
          NavigationDestination(
            icon: Icon(dest.icon),
            label: dest.label,
          ),
      ],
    );
  }

  Widget _buildRailLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          labelType: NavigationRailLabelType.all,
          destinations: [
            for (final dest in NavDestination.values)
              NavigationRailDestination(
                icon: Icon(dest.icon),
                label: Text(dest.label),
              ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _buildBody()),
      ],
    );
  }

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }
}
