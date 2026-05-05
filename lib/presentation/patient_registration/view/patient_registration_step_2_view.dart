import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../widgets/patient_registration_step_2_view_body.dart';

class PatientRegistrationStep2View extends StatelessWidget {
  const PatientRegistrationStep2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: const SafeArea(
        child: PatientRegistrationStep2ViewBody(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
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
    );
  }
}
