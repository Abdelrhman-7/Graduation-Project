import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/resources/theme_manager.dart';
import 'presentation/auth_choice/view/auth_choice_view.dart';
import 'presentation/patient_home_dashboard/view/patient_home_dashboard_view.dart';
import 'presentation/doctor/home/view/doctor_home_view.dart';
import 'presentation/admin/admin_home_view.dart';
import 'data/api/api_manager.dart';
import 'data/repository/repository.dart';
import 'presentation/login/cubit/login_cubit.dart';
import 'presentation/patient_registration/cubit/patient_registration_cubit.dart';
import 'data/repository/shared_pref_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress image resource service errors globally (e.g., 404s for network images)
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.library == 'image resource service' || details.exception.toString().contains('404')) {
      return; // Silently ignore image loading errors
    }
    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  final prefController = SharedPrefController();
  final bool isLoggedIn = await prefController.isLoggedIn();
  final String? role = await prefController.getRole();
  final apiManager = await ApiManager.create();

  runApp(
    MyApp(
      isLoggedIn: isLoggedIn,
      role: role,
      prefController: prefController,
      apiManager:    apiManager,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;
  final SharedPrefController prefController;
  final ApiManager apiManager;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.role,
    required this.prefController,
    required this.apiManager,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiManager>(create: (context) => apiManager),
        RepositoryProvider(create: (context) => prefController),
        RepositoryProvider(
          create: (context) => Repository(context.read<ApiManager>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LoginCubit(
              context.read<ApiManager>(),
              context.read<SharedPrefController>(),
            ),
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
              ? (role == 'Admin'
                    ? const AdminHomeView()
                    : (role == 'Doctor'
                          ? const DoctorHomeView()
                          : const PatientHomeDashboardView()))
              : const AuthChoiceView(),
        ),
      ),
    );
  }
}
