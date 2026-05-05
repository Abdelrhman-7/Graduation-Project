import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_choice_cubit.dart';
import '../widgets/auth_choice_view_body.dart';

class AuthChoiceView extends StatelessWidget {
  const AuthChoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthChoiceCubit(),
      child: const Scaffold(
        body: AuthChoiceViewBody(),
      ),
    );
  }
}
