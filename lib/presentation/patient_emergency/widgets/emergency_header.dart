import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/core/resources/color_manager.dart';

class EmergencyHeader extends StatelessWidget {
  const EmergencyHeader({super.key, required this.s});

  final double Function(double) s;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(s(16), s(16), s(16), s(0)),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: ColorManager.headlineText, size: s(24)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Emergency',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: s(18),
                fontWeight: FontWeight.w700,
                color: ColorManager.headlineText,
              ),
            ),
          ),
          SizedBox(width: s(48)), // To balance the back button
        ],
      ),
    );
  }
}
