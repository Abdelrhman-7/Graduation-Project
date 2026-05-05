import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class NextAppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const NextAppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
      padding: const EdgeInsets.all(AppPadding.p20),
      decoration: BoxDecoration(
        color: ColorManager.primary,
        borderRadius: BorderRadius.circular(AppSize.s24),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppPadding.p12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSize.s16),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: Colors.white),
              ),
              const SizedBox(width: AppSize.s16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Appointment',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    appointment['dateTime'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSize.s20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: AppSize.s20),
          Row(
            children: [
              CircleAvatar(
                radius: AppSize.s20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white, size: AppSize.s20),
              ),
              const SizedBox(width: AppSize.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['doctorName'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      appointment['specialty'],
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.s12)),
                ),
                child: const Text('Reschedule', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
