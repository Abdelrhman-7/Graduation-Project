import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/repository.dart';
import 'lab_results_state.dart';

class LabResultsCubit extends Cubit<LabResultsState> {
  final Repository repository;
  
  LabResultsCubit(this.repository) : super(LabResultsInitial());

  void submitHealthMetrics({
    required String systolic,
    required String diastolic,
    required String heartRate,
    required String bloodSugar,
    required String weight,
    required String notes,
    String? medTitle,
    String? medSubtitle,
  }) async {
    emit(LabResultsSubmitLoading());
    try {
      // Mocking API call for saving health metrics
      await Future.delayed(const Duration(seconds: 1));
      
      final record = {
        'heartRate': heartRate,
        'bloodPressure': '$systolic/$diastolic',
        'bloodSugar': bloodSugar,
        'weight': weight,
        'notes': notes,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await repository.addPatientHealthMetricRecord(record);
      
      if (medTitle != null && medTitle.isNotEmpty) {
        final newMed = {
          'title': medTitle,
          'subtitle': medSubtitle ?? '',
          'badge': 'Active'
        };
        // Load existing and add new
        final currentMeds = await repository.getPatientMedications();
        currentMeds.insert(0, newMed);
        await repository.savePatientMedications(currentMeds);
      }
      
      if (!isClosed) {
        emit(LabResultsSubmitSuccess());
      }
    } catch (e) {
      if (!isClosed) {
        emit(LabResultsSubmitError(e.toString()));
      }
    }
  }
}
