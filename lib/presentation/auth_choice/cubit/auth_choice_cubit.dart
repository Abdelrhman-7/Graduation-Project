import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_choice_state.dart';

class AuthChoiceCubit extends Cubit<AuthChoiceState> {
  AuthChoiceCubit() : super(AuthChoiceInitial());
}
