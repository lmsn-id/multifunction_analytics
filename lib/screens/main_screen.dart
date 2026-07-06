import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/theme_toggle_button.dart';

class MainScreen extends StatelessWidget {
  final MenuItem currentItem;
  final Widget child;

  const MainScreen({super.key, required this.currentItem, required this.child});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationWidget(
      currentItem: currentItem,
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentItem.title),
          actions: [
            const ThemeToggleButton(),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _showInfoDialog(context);
              },
            ),
          ],
        ),
        body: child,
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Metode'),
        content: Text(
          _getMethodDescription(context),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String _getMethodDescription(BuildContext context) {
    switch (currentItem) {
      case MenuItem.topsis:
        return 'TOPSIS (Technique for Order Preference by Similarity to Ideal Solution) adalah metode pengambilan keputusan multi-kriteria yang memilih alternatif terbaik berdasarkan jarak terdekat ke solusi ideal positif dan terjauh dari solusi ideal negatif.';
      case MenuItem.ahp:
        return 'AHP (Analytic Hierarchy Process) adalah metode pengambilan keputusan yang dikembangkan oleh Thomas L. Saaty. Metode ini menggunakan perbandingan berpasangan untuk menentukan bobot kriteria dan peringkat alternatif.';
      case MenuItem.anp:
        return 'ANP (Analytic Network Process) adalah pengembangan dari AHP yang memungkinkan adanya ketergantungan dan umpan balik antara kriteria dan alternatif dalam bentuk jaringan.';
      case MenuItem.electre:
        return 'ELECTRE (ELimination Et Choix Traduisant la REalité) adalah metode pengambilan keputusan multi-kriteria yang menggunakan konsep outranking untuk membandingkan alternatif.';
    }
  }
}
