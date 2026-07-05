import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../../../core/resources/string_manager.dart';
import '../../clinic/my_clinics/view/doctor_clinics_view.dart';
import '../../wallet/view/doctor_wallet_view.dart';
import '../../reviews/view/doctor_reviews_view.dart';

class QuickActionsGrid extends StatelessWidget {
  final double scale;

  const QuickActionsGrid({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(16)),
      child: Column(
        children: [
          Row(
            children: [
              _buildAction(
                s,
                AppStrings.writeNote,
                Icons.edit_note_rounded,
                ColorManager.tealHighlight,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Write Note coming soon')),
                  );
                },
              ),
              SizedBox(width: s(12)),
              _buildAction(
                s,
                'My Clinic',
                Icons.local_hospital_rounded,
                ColorManager.amberHighlight,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorClinicsView(),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: s(12)),
          Row(
            children: [
              _buildAction(
                s,
                AppStrings.wallet,
                Icons.account_balance_wallet_rounded,
                ColorManager.blueHighlight,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorWalletView(),
                    ),
                  );
                },
              ),
              SizedBox(width: s(12)),
              _buildAction(
                s,
                'Patient Reviews',
                Icons.star_rate_rounded,
                const Color(0xFFEAB308),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorReviewsView(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    double Function(double) s,
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(s(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(s(20)),
            border: Border.all(color: ColorManager.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: s(10),
                offset: Offset(0, s(4)),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(s(10)),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: s(24)),
              ),
              SizedBox(height: s(12)),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: s(15),
                  fontWeight: FontWeight.w600,
                  color: ColorManager.headlineText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
