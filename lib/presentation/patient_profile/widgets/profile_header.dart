import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../cubit/patient_profile_cubit.dart';
import '../view/patient_edit_profile_view.dart';

class ProfileHeader extends StatelessWidget {
  final double scale;
  final String name;
  final String patientId;
  final String? imageUrl;

  const ProfileHeader({
    super.key,
    required this.scale,
    required this.name,
    required this.patientId,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(16)),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: s(80),
                height: s(80),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorManager.primary, width: s(2)),
                  color: const Color(0xFFE2E8F0),
                  image: imageUrl != null && imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null || imageUrl!.isEmpty
                    ? Icon(
                        Icons.person_rounded,
                        size: s(40),
                        color: const Color(0xFF64748B),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    if (imageUrl != null && imageUrl!.isNotEmpty) {
                      context.read<PatientProfileCubit>().deleteImage();
                    } else {
                      final cubit = context.read<PatientProfileCubit>();
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => PatientEditProfileView(
                        cubit: cubit,
                        currentName: name,
                      )));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(s(4)),
                    decoration: BoxDecoration(
                      color: (imageUrl != null && imageUrl!.isNotEmpty) ? Colors.red : ColorManager.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      (imageUrl != null && imageUrl!.isNotEmpty) ? Icons.delete_outline : Icons.camera_alt,
                      size: s(14),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: s(20)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.cairo(
                    fontSize: s(24),
                    fontWeight: FontWeight.w700,
                    color: ColorManager.headlineText,
                  ),
                ),

                SizedBox(height: s(4)),

                Text(
                  '${AppStrings.patientId} $patientId',
                  style: GoogleFonts.cairo(
                    fontSize: s(14),
                    fontWeight: FontWeight.w500,
                    color: ColorManager.subtitleText,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              final cubit = context.read<PatientProfileCubit>();
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => PatientEditProfileView(
                cubit: cubit,
                currentName: name,
              )));
            },
            child: Container(
              padding: EdgeInsets.all(s(10)),
              decoration: BoxDecoration(
                color: ColorManager.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(s(12)),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: ColorManager.primary,
                size: s(22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
