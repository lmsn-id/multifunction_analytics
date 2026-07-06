import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section - Tanpa efek shadow berat
                const Icon(
                  Icons.analytics_outlined,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),

                Text(
                  'SPK Analyzer',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Sistem Pendukung Keputusan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 30),

                // Method Chips - Tetap seperti tampilan awal
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildMethodChip('TOPSIS', const Color(0xFF00E676)),
                      _buildMethodChip('AHP', const Color(0xFFFFAB00)),
                      _buildMethodChip('ANP', const Color(0xFFD500F9)),
                      _buildMethodChip('ELECTRE', const Color(0xFFFF1744)),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Tombol Pilihan Metode - Mengganti "Mulai Sekarang"
                _buildMethodButton(
                  context: context,
                  label: 'TOPSIS',
                  color: const Color(0xFF00E676),
                  route: '/topsis',
                ),
                const SizedBox(height: 10),

                _buildMethodButton(
                  context: context,
                  label: 'AHP',
                  color: const Color(0xFFFFAB00),
                  route: '/ahp',
                ),
                const SizedBox(height: 10),

                _buildMethodButton(
                  context: context,
                  label: 'ANP',
                  color: const Color(0xFFD500F9),
                  route: '/anp',
                ),
                const SizedBox(height: 10),

                _buildMethodButton(
                  context: context,
                  label: 'ELECTRE',
                  color: const Color(0xFFFF1744),
                  route: '/electre',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMethodButton({
    required BuildContext context,
    required String label,
    required Color color,
    required String route,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.go(route);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A237E),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3, // Dikurangi dari 8 ke 3
          shadowColor: Colors.black.withValues(
            alpha: 0.15,
          ), // Dikurangi opacity
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              'Mulai $label',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A237E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
