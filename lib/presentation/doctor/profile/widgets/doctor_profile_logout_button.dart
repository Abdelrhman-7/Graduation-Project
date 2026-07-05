import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/repository/shared_pref_controller.dart';
import 'package:graduationproject/presentation/auth_choice/view/auth_choice_view.dart';

class DoctorProfileLogoutButton extends StatelessWidget {
  const DoctorProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final SharedPrefController sharedPrefController = SharedPrefController();

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          await sharedPrefController.logout();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthChoiceView()),
              (route) => false,
            );
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEE),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              "Logout",
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
