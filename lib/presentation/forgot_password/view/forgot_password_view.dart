import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../../data/api/api_manager.dart';
import '../cubit/forgot_password_cubit.dart';
import '../widgets/forgot_password_view_body.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(context.read<ApiManager>()),
      child: Scaffold(
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
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: const ForgotPasswordViewBody(),
      ),
    );
  }
}
