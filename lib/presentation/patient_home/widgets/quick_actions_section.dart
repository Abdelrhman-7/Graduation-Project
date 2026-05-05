import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p24),
          child: Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: AppSize.s16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
          child: Row(
            children: [
              _buildActionItem(
                context,
                'Find Doctor',
                Icons.search_rounded,
                Colors.blue,
              ),
              const SizedBox(width: AppSize.s12),
              _buildActionItem(
                context,
                'Pharmacy',
                Icons.local_pharmacy_rounded,
                Colors.green,
              ),
              const SizedBox(width: AppSize.s12),
              _buildActionItem(
                context,
                'Reports',
                Icons.assignment_rounded,
                Colors.orange,
              ),
              const SizedBox(width: AppSize.s12),
              _buildActionItem(
                context,
                'Schedule',
                Icons.event_available_rounded,
                Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppSize.s20),
        border: Border.all(color: ColorManager.borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppPadding.p12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppSize.s24),
          ),
          const SizedBox(height: AppSize.s12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
