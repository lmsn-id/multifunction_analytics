import 'package:flutter/material.dart';

enum MenuItem { topsis, ahp, anp, electre }

extension MenuItemExtension on MenuItem {
  String get title {
    switch (this) {
      case MenuItem.topsis:
        return 'TOPSIS';
      case MenuItem.ahp:
        return 'AHP';
      case MenuItem.anp:
        return 'ANP';
      case MenuItem.electre:
        return 'ELECTRE';
    }
  }

  String get route {
    switch (this) {
      case MenuItem.topsis:
        return '/topsis';
      case MenuItem.ahp:
        return '/ahp';
      case MenuItem.anp:
        return '/anp';
      case MenuItem.electre:
        return '/electre';
    }
  }

  IconData get icon {
    switch (this) {
      case MenuItem.topsis:
        return Icons.bar_chart;
      case MenuItem.ahp:
        return Icons.account_tree;
      case MenuItem.anp:
        return Icons.network_check;
      case MenuItem.electre:
        return Icons.calculate;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case MenuItem.topsis:
        return Icons.bar_chart_rounded;
      case MenuItem.ahp:
        return Icons.account_tree_rounded;
      case MenuItem.anp:
        return Icons.network_check_rounded;
      case MenuItem.electre:
        return Icons.calculate_rounded;
    }
  }
}
