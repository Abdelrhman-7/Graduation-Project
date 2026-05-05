import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/resources/theme_manager.dart';
import 'presentation/auth_choice/view/auth_choice_view.dart';
import 'data/api/api_manager.dart';
import 'presentation/login/cubit/login_cubit.dart';
import 'presentation/patient_registration/cubit/patient_registration_cubit.dart';
import 'data/repository/shared_pref_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefController = SharedPrefController();
  final bool isLoggedIn = await prefController.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ApiManager(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LoginCubit(context.read<ApiManager>()),
          ),
          BlocProvider(
            create: (context) =>
                PatientRegistrationCubit(context.read<ApiManager>()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Graduation Project',
          theme: ThemeManager.getApplicationTheme(),
          home: isLoggedIn
              ? const AuthChoiceView()
              : const AuthChoiceView(), // Update logic as needed
        ),
      ),
    );
  }
}
