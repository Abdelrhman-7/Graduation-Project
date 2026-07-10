import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../role_selection/cubit/role_selection_state.dart';
import '../../role_selection/view/role_selection_view.dart';
import '../widgets/login_view_body.dart';

class LoginView extends StatelessWidget {
  final UserRole role;
  const LoginView({super.key, required this.role});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(AppPadding.p8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorManager.white,
              boxShadow: [
                BoxShadow(
                  color: ColorManager.blackOpacity05,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: ColorManager.headlineText,
              size: AppSize.s20,
            ),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const RoleSelectionView(isLogin: true),
                ),
              );
            }
          },
        ),
      ),
      body: LoginViewBody(role: role),
    );
  }
}
