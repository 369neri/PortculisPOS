import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';

import '../../../pricing/presentation/pages/price_entry.dart';

class HiddenMenu extends StatefulWidget {
  const HiddenMenu({super.key});

  @override
  State<HiddenMenu> createState() => _HiddenMenuState();
}

class _HiddenMenuState extends State<HiddenMenu> {
  List<ScreenHiddenDrawer> _pages = [];

  @override
  void initState() {
    super.initState();

    _pages = [
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Sales Register',
          baseStyle: const TextStyle(
            color: Colors.white,
          ),
          selectedStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
        const PriceEntryPage()
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Cashier',
          baseStyle: const TextStyle(
            color: Colors.white,
          ),
          selectedStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
        const PriceEntryPage()
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      screens: _pages,
      initPositionSelected: 0,
      slidePercent: 50.0,
      backgroundColorMenu: Colors.black87,
    );
  }
}