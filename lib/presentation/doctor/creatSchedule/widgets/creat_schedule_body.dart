import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/resources/color_manager.dart';
import '../cubit/creat_schedule_cubit.dart';
import '../cubit/creat_schedule_state.dart';
import 'creat_schedule_app_bar.dart';
import 'creat_schedule_form.dart';
import 'creat_schedule_header.dart';

class CreateScheduleBody extends StatefulWidget {
  const CreateScheduleBody({super.key});

  @override
  State<CreateScheduleBody> createState() => _CreateScheduleBodyState();
}

class _CreateScheduleBodyState extends State<CreateScheduleBody> {
  final List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  String _selectedDay = 'Sunday';
  int? _selectedClinicId;
  final TextEditingController _startTimeController = TextEditingController(
    text: '09:00',
  );
  final TextEditingController _endTimeController = TextEditingController(
    text: '17:00',
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CreateScheduleAppBar(),
        Expanded(
          child: BlocConsumer<CreateScheduleCubit, CreateScheduleState>(
            listener: (context, state) {
              if (state is CreateScheduleAddSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Schedule added successfully!"),
                    backgroundColor: Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is CreateScheduleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              final clinics = context.read<CreateScheduleCubit>().clinics;

              if (state is CreateScheduleLoading && clinics.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: ColorManager.primary),
                );
              }

              if (_selectedClinicId == null && clinics.isNotEmpty) {
                _selectedClinicId = clinics.first.id;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CreateScheduleHeader(),
                    const SizedBox(height: 32),
                    CreateScheduleForm(
                      clinics: clinics,
                      isLoading: state is CreateScheduleLoading,
                      selectedDay: _selectedDay,
                      selectedClinicId: _selectedClinicId,
                      days: _days,
                      startTimeController: _startTimeController,
                      endTimeController: _endTimeController,
                      onDayChanged: (v) => setState(() => _selectedDay = v!),
                      onClinicChanged: (v) =>
                          setState(() => _selectedClinicId = v),
                      onSubmit: _submitForm,
                      onTapStartTime: () => _selectTime(_startTimeController),
                      onTapEndTime: () => _selectTime(_endTimeController),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      final String hour = picked.hour.toString().padLeft(2, '0');
      final String minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$hour:$minute';
      });
    }
  }

  void _submitForm() {
    final startParts = _startTimeController.text.split(':');
    final endParts = _endTimeController.text.split(':');
    if (startParts.length == 2 && endParts.length == 2) {
      final startHour = int.tryParse(startParts[0]) ?? 0;
      final startMinute = int.tryParse(startParts[1]) ?? 0;
      final endHour = int.tryParse(endParts[0]) ?? 0;
      final endMinute = int.tryParse(endParts[1]) ?? 0;
      
      final startTotal = startHour * 60 + startMinute;
      final endTotal = endHour * 60 + endMinute;
      
      if (startTotal >= endTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Start time must be before end time!"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    context.read<CreateScheduleCubit>().addSchedule(
      day: _selectedDay,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      clinicId: _selectedClinicId!,
    );
  }
}
