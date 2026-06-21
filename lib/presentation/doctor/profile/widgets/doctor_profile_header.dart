import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';

class DoctorProfileHeader extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final VoidCallback? onEditTap;

  const DoctorProfileHeader({
    super.key,
    required this.name,
    this.imageUrl,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: imageUrl == null ? const Color(0xFFF0F0F0) : null,
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: imageUrl == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Color(0xFFBDBDBD),
                    )
                  : null,
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: GoogleFonts.lexend(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorManager.headlineText,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: ColorManager.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Cardiologist • MD, FACC",
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorManager.primary,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem("Experience", "12 years"),
            _buildStatItem("Patients", "4.8k+"),
            _buildStatItem("Rating", "4.9/5"),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: ColorManager.subtitleText,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ColorManager.headlineText,
            ),
          ),
        ],
      ),
    );
  }
}
