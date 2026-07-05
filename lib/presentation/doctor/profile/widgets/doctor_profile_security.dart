import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../auth_choice/view/auth_choice_view.dart';
import '../cubit/doctor_profile_cubit.dart';
import '../cubit/doctor_profile_state.dart';
import '../../../widgets/custom_change_password_dialog.dart';

class DoctorProfileSecurity extends StatelessWidget {
  const DoctorProfileSecurity({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorProfileCubit, DoctorProfileState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthChoiceView()),
            (route) => false,
          );
        } else if (state is DoctorProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is DoctorProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ACCOUNT SECURITY",
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ColorManager.subtitleText,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                _showChangePasswordDialog(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.lock_reset_rounded, color: ColorManager.headlineText, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Password",
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.headlineText,
                            ),
                          ),
                          Text(
                            "Last changed 4 months ago",
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: ColorManager.subtitleText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: ColorManager.subtitleText),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                _showDeleteAccountDialog(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE3E3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_remove_rounded, color: Color(0xFFE53E3E), size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Delete Account",
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE53E3E),
                            ),
                          ),
                          Text(
                            "Permanently delete your profile",
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: const Color(0xFFE53E3E).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFE53E3E)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final cubit = context.read<DoctorProfileCubit>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return BlocProvider.value(
          value: cubit,
          child: BlocConsumer<DoctorProfileCubit, DoctorProfileState>(
            listener: (context, state) {
              if (state is DoctorProfilePasswordChangeSuccess) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              } else if (state is DoctorProfilePasswordChangeError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              return CustomChangePasswordDialog(
                isLoading: state is DoctorProfilePasswordChangeLoading,
                onCancel: () => Navigator.pop(dialogCtx),
                onSubmit: (current, newPass, confirm) {
                  cubit.changePassword(current, newPass, confirm);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final cubit = context.read<DoctorProfileCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your doctor account? This action cannot be undone and you will be logged out.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                cubit.deleteAccount();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
