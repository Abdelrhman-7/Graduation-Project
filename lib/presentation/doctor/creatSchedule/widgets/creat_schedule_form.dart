import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../data/models/schudule/cliniceSchedual.dart';

class CreateScheduleForm extends StatelessWidget {
  final List<ClinicModel> clinics;
  final bool isLoading;
  final String selectedDay;
  final int? selectedClinicId;
  final List<String> days;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final Function(String?) onDayChanged;
  final Function(int?) onClinicChanged;
  final VoidCallback onSubmit;
  final VoidCallback onTapStartTime;
  final VoidCallback onTapEndTime;

  const CreateScheduleForm({
    super.key,
    required this.clinics,
    required this.isLoading,
    required this.selectedDay,
    required this.selectedClinicId,
    required this.days,
    required this.startTimeController,
    required this.endTimeController,
    required this.onDayChanged,
    required this.onClinicChanged,
    required this.onSubmit,
    required this.onTapStartTime,
    required this.onTapEndTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel(text: "Select Clinic"),
          const SizedBox(height: 10),
          clinics.isEmpty
              ? const _NoClinicsWarning()
              : DropdownButtonFormField<int>(
                  value: selectedClinicId,
                  decoration: _inputDecoration(Icons.local_hospital_rounded),
                  items: clinics
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: isLoading ? null : onClinicChanged,
                ),
          const SizedBox(height: 24),
          const _FieldLabel(text: "Work Day"),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedDay,
            decoration: _inputDecoration(Icons.calendar_today_rounded),
            items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: isLoading ? null : onDayChanged,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(text: "Start Time"),
                    const SizedBox(height: 10),
                    TextField(
                      controller: startTimeController,
                      readOnly: true,
                      onTap: isLoading ? null : onTapStartTime,
                      decoration: _inputDecoration(Icons.access_time_rounded, hint: "09:00"),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(text: "End Time"),
                    const SizedBox(height: 10),
                    TextField(
                      controller: endTimeController,
                      readOnly: true,
                      onTap: isLoading ? null : onTapEndTime,
                      decoration: _inputDecoration(Icons.access_time_filled_rounded, hint: "17:00"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _SubmitButton(
            isLoading: isLoading,
            isEnabled: !isLoading && selectedClinicId != null,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorManager.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF334155),
      ),
    );
  }
}

class _NoClinicsWarning extends StatelessWidget {
  const _NoClinicsWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 20),
          const SizedBox(width: 10),
          const Expanded(child: Text("Please add a clinic from your profile first.")),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ColorManager.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                "Confirm Schedule",
                style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
