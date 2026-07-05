import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../cubit/lab_results_cubit.dart';
import '../cubit/lab_results_state.dart';
import '../widgets/top_bar.dart';
import '../widgets/health_metrics_history_sheet.dart';
import '../../patient_home_dashboard/widgets/patient_bottom_nav.dart';

class LabResultsViewBody extends StatefulWidget {
  const LabResultsViewBody({super.key});

  @override
  State<LabResultsViewBody> createState() => _LabResultsViewBodyState();
}

class _LabResultsViewBodyState extends State<LabResultsViewBody> {
  final _formKey = GlobalKey<FormState>();
  
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _showHrWarning = false;

  @override
  void initState() {
    super.initState();
    _heartRateController.addListener(_checkWarnings);
  }

  void _checkWarnings() {
    final hrStr = _heartRateController.text;
    final hr = int.tryParse(hrStr);
    if (hr != null && (hr < 60 || hr > 100)) {
      if (!_showHrWarning) setState(() => _showHrWarning = true);
    } else {
      if (_showHrWarning) setState(() => _showHrWarning = false);
    }
  }

  @override
  void dispose() {
    _heartRateController.removeListener(_checkWarnings);
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _bloodSugarController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LabResultsCubit>().submitHealthMetrics(
            systolic: _systolicController.text,
            diastolic: _diastolicController.text,
            heartRate: _heartRateController.text,
            bloodSugar: _bloodSugarController.text,
            weight: _weightController.text,
            notes: _notesController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.88, 1.15);
        double s(double v) => v * scale;
        
        return BlocConsumer<LabResultsCubit, LabResultsState>(
          listener: (context, state) {
            if (state is LabResultsSubmitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Health metrics saved successfully!'),
                  backgroundColor: ColorManager.primary,
                ),
              );
              Navigator.pop(context); // Or clear form
            } else if (state is LabResultsSubmitError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is LabResultsSubmitLoading;
            
            return Column(
              children: [
                Expanded(
                  child: Container(
                    color: ColorManager.whiteLilac,
                    child: Column(
                      children: [
                        LabResultsTopBar(
                    scale: scale,
                    onHistoryTap: () {
                      showHealthMetricsHistorySheet(context);
                    },
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: EdgeInsets.all(s(24)),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          Text(
                            'Enter Health Metrics',
                            style: GoogleFonts.cairo(
                              fontSize: s(22),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: s(8)),
                          Text(
                            'Keep track of your vitals for better monitoring.',
                            style: GoogleFonts.cairo(
                              fontSize: s(14),
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: s(24)),
                          
                          // Blood Pressure
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Systolic (mmHg)',
                                  hintText: 'e.g. 120',
                                  controller: _systolicController,
                                  keyboardType: TextInputType.number,
                                  icon: Icons.monitor_heart_outlined,
                                ),
                              ),
                              SizedBox(width: s(16)),
                              Expanded(
                                child: _buildTextField(
                                  label: 'Diastolic (mmHg)',
                                  hintText: 'e.g. 80',
                                  controller: _diastolicController,
                                  keyboardType: TextInputType.number,
                                  icon: Icons.monitor_heart,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: s(16)),
                          
                          // Heart Rate
                          _buildTextField(
                            label: 'Heart Rate (bpm)',
                            hintText: 'e.g. 72',
                            controller: _heartRateController,
                            keyboardType: TextInputType.number,
                            icon: Icons.favorite_border_rounded,
                          ),
                          if (_showHrWarning)
                            Padding(
                              padding: EdgeInsets.only(top: s(4), left: s(4)),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: s(16)),
                                  SizedBox(width: s(4)),
                                  Text(
                                    'Heart rate is outside the normal range (60-100)',
                                    style: GoogleFonts.cairo(fontSize: s(11), color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: s(16)),

                          // Blood Sugar
                          _buildTextField(
                            label: 'Blood Sugar (mg/dL)',
                            hintText: 'e.g. 95',
                            controller: _bloodSugarController,
                            keyboardType: TextInputType.number,
                            icon: Icons.water_drop_outlined,
                          ),
                          SizedBox(height: s(16)),

                          // Weight
                          _buildTextField(
                            label: 'Weight (kg)',
                            hintText: 'e.g. 70.5',
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            icon: Icons.monitor_weight_outlined,
                          ),
                          SizedBox(height: s(16)),

                          // Notes
                          _buildTextField(
                            label: 'Notes (Optional)',
                            hintText: 'e.g. Fasting, After meal',
                            controller: _notesController,
                            keyboardType: TextInputType.text,
                            icon: Icons.notes_rounded,
                            isRequired: false,
                          ),
                          SizedBox(height: s(32)),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: s(56),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(s(16)),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'Save Metrics',
                                      style: GoogleFonts.cairo(
                                        fontSize: s(16),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: s(32)),
                        ],
                      ),
                    ),
                  ),
                        ],
                    ),
                  ),
                ),
                const PatientBottomNav(currentIndex: 2),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    String? hintText,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required IconData icon,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (val) {
        if (isRequired && (val == null || val.isEmpty)) return 'Required';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: GoogleFonts.cairo(
          color: const Color(0xFF94A3B8),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white,
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
      ),
    );
  }
}
