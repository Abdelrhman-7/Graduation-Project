import 'package:flutter_bloc/flutter_bloc.dart';
import 'lab_results_state.dart';

class LabResultsCubit extends Cubit<LabResultsState> {
  LabResultsCubit() : super(LabResultsInitial());

  void getLabResults() async {
    emit(LabResultsLoading());
    try {
      // Mocking API call
      await Future.delayed(const Duration(milliseconds: 300));
      emit(LabResultsSuccess(reports: [], detailedResults: []));
    } catch (e) {
      emit(LabResultsError(e.toString()));
    }
  }
}
