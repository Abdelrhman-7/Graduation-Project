import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../cubit/role_selection_cubit.dart';
import '../widgets/role_selection_view_body.dart';

class RoleSelectionView extends StatelessWidget {
  final bool isLogin;
  const RoleSelectionView({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoleSelectionCubit(),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: RoleSelectionViewBody(isLogin: isLogin),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
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
        onPressed: () => Navigator.maybePop(context),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // TODO: Navigate to Login or other logic
          },
          child: Text(
            AppStrings.login,
            style: theme.textTheme.labelLarge?.copyWith(
              color: ColorManager.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSize.s8),
      ],
    );
  }
}
