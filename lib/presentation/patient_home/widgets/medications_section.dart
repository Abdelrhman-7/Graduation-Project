import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class MedicationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> medications;

  const MedicationsSection({super.key, required this.medications});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Medications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(color: ColorManager.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSize.s8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: medications.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSize.s12),
          itemBuilder: (context, index) {
            final med = medications[index];
            return _buildMedicationItem(
              context,
              med['name'],
              med['dosage'],
              med['time'],
              med['type'] == 'pill'
                  ? Icons.medication_rounded
                  : Icons.medication_liquid_rounded,
              med['type'] == 'pill' ? Colors.blue : Colors.orange,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMedicationItem(
    BuildContext context,
    String name,
    String dosage,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppSize.s20),
        border: Border.all(color: ColorManager.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppPadding.p12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.s12),
            ),
            child: Icon(icon, color: color, size: AppSize.s24),
          ),
          const SizedBox(width: AppSize.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  dosage,
                  style: const TextStyle(
                    color: ColorManager.subtitleText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12,
              vertical: AppPadding.p8,
            ),
            decoration: BoxDecoration(
              color: ColorManager.background,
              borderRadius: BorderRadius.circular(AppSize.s0),
            ),
            child: Text(
              time,
              style: const TextStyle(
                color: ColorManager.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
