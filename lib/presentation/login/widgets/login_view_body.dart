import 'package:flutter/material.dart';
import '../../../core/resources/values_manager.dart';
import '../../role_selection/cubit/role_selection_state.dart';
import 'login_form.dart';
import 'login_header.dart';

class LoginViewBody extends StatelessWidget {
  final UserRole role;

  const LoginViewBody({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LoginHeader(role: role),
            const LoginForm(),
          ],
        ),
      ),
    );
  }
}
