import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/core/resources/color_manager.dart';

class EmergencyContacts extends StatelessWidget {
  const EmergencyContacts({super.key, required this.s});

  final double Function(double) s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Contacts',
          style: GoogleFonts.cairo(
            fontSize: s(18),
            fontWeight: FontWeight.w700,
            color: ColorManager.headlineText,
          ),
        ),
        SizedBox(height: s(16)),
        EmergencyContactCard(
          title: 'National Ambulance',
          number: '123',
          icon: Icons.local_hospital,
          color: Colors.red,
          s: s,
        ),
        SizedBox(height: s(12)),
        EmergencyContactCard(
          title: 'Police Department',
          number: '122',
          icon: Icons.local_police,
          color: Colors.blue,
          s: s,
        ),
        SizedBox(height: s(12)),
        EmergencyContactCard(
          title: 'Fire Department',
          number: '180',
          icon: Icons.local_fire_department,
          color: Colors.orange,
          s: s,
        ),
      ],
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({
    super.key,
    required this.title,
    required this.number,
    required this.icon,
    required this.color,
    required this.s,
  });

  final String title;
  final String number;
  final IconData icon;
  final Color color;
  final double Function(double) s;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(s(12)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: s(24)),
          ),
          SizedBox(width: s(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: s(15),
                    fontWeight: FontWeight.w600,
                    color: ColorManager.headlineText,
                  ),
                ),
                SizedBox(height: s(4)),
                Text(
                  number,
                  style: GoogleFonts.cairo(
                    fontSize: s(14),
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.phone, color: Colors.green, size: s(24)),
            onPressed: () {
              // Action to call the number
            },
          ),
        ],
      ),
    );
  }
}
