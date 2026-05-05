import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class PatientHomeHeader extends StatelessWidget {
  final String userName;
  const PatientHomeHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24, vertical: AppPadding.p20),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSize.s28,
            backgroundColor: ColorManager.primaryOpacity10,
            child: const Icon(Icons.person, color: ColorManager.primary, size: AppSize.s32),
          ),
          const SizedBox(width: AppSize.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorManager.subtitleText,
                  ),
                ),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppPadding.p8),
            decoration: BoxDecoration(
              color: ColorManager.white,
              shape: BoxShape.circle,
              border: Border.all(color: ColorManager.borderColor),
            ),
            child: const Badge(
              backgroundColor: Colors.red,
              child: Icon(Icons.notifications_none_rounded, color: ColorManager.headlineText),
            ),
          ),
        ],
      ),
    );
  }
}
