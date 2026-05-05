import 'package:flutter/material.dart';
import '../../../core/resources/values_manager.dart';
import 'forgot_password_form.dart';
import 'forgot_password_header.dart';

class ForgotPasswordViewBody extends StatelessWidget {
  const ForgotPasswordViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ForgotPasswordHeader(),
            ForgotPasswordForm(),
          ],
        ),
      ),
    );
  }
}
