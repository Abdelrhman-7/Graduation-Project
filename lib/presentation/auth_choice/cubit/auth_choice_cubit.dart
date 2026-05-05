import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/repository.dart';

part 'auth_choice_state.dart';

class AuthChoiceCubit extends Cubit<AuthChoiceState> {
  final Repository _repository;

  AuthChoiceCubit(this._repository) : super(AuthChoiceInitial());

  Future<void> chooseRole(String role) async {
    emit(AuthChoiceLoading());
    try {
      final success = await _repository.chooseRole(role);
      if (success) {
        emit(AuthChoiceSuccess(role));
      } else {
        emit(AuthChoiceError('Failed to set role. Please try again.'));
      }
    } catch (e) {
      emit(AuthChoiceError(e.toString()));
    }
  }
}
