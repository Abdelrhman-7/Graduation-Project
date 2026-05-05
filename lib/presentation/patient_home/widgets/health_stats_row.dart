/*import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class HealthStatsRow extends StatelessWidget {
  final String heartRate;
  final String bloodType;

  const HealthStatsRow({
    super.key,
    required this.heartRate,
    required this.bloodType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              'Heart Rate',
              heartRate,
              Icons.favorite_rounded,
              Colors.red[50]!,
              Colors.red,
            ),
          ),
          const SizedBox(width: AppSize.s16),
          Expanded(
            child: _buildStatCard(
              context,
              'Blood Type',
              bloodType,
              Icons.bloodtype_rounded,
              Colors.blue[50]!,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppSize.s20),
        border: Border.all(color: ColorManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppPadding.p8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: AppSize.s20),
          ),
          const SizedBox(height: AppSize.s12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ColorManager.subtitleText),
          ),
          const SizedBox(height: AppSize.s4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
*/