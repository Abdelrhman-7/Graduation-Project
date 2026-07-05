import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/api/api_manager.dart';
import 'doctor_reviews_state.dart';

class DoctorReviewsCubit extends Cubit<DoctorReviewsState> {
  DoctorReviewsCubit() : super(DoctorReviewsInitial());

  Future<void> getDoctorReviews() async {
    emit(DoctorReviewsLoading());
    try {
      final api = await ApiManager.create();
      final response = await api.getDoctorAllReviews();
      
      final reviewsList = response.map((e) => Map<String, dynamic>.from(e)).toList();
      emit(DoctorReviewsSuccess(reviewsList));
    } catch (e) {
      emit(DoctorReviewsError(e.toString()));
    }
  }
}
