import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'package:graduationproject/presentation/patient_home_dashboard/view/patient_home_dashboard_view_body.dart';
import 'package:graduationproject/presentation/patient_home_dashboard/cubit/patient_home_dashboard_cubit.dart';

class PatientHomeDashboardView extends StatefulWidget {
  const PatientHomeDashboardView({super.key});

  @override
  State<PatientHomeDashboardView> createState() =>
      _PatientHomeDashboardViewState();
}

class _PatientHomeDashboardViewState extends State<PatientHomeDashboardView>
    with RouteAware {
  late PatientHomeDashboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PatientHomeDashboardCubit(context.read<Repository>())
      ..getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: SafeArea(
          child: _HomeRefreshWrapper(cubit: _cubit),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}

/// Wrapper يعمل refresh للـ dashboard لما تفتح الشاشة من جديد
class _HomeRefreshWrapper extends StatefulWidget {
  final PatientHomeDashboardCubit cubit;
  const _HomeRefreshWrapper({required this.cubit});

  @override
  State<_HomeRefreshWrapper> createState() => _HomeRefreshWrapperState();
}

class _HomeRefreshWrapperState extends State<_HomeRefreshWrapper>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// لما التطبيق يرجع للـ foreground، نعيد تحميل البيانات
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.cubit.getDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const PatientHomeDashboardViewBody();
  }
}
