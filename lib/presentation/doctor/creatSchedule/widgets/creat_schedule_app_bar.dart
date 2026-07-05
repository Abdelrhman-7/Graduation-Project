import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateScheduleAppBar extends StatelessWidget {
  const CreateScheduleAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          if (Navigator.canPop(context)) ...[
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            'Create Schedule',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
