import 'package:flutter_bloc/flutter_bloc.dart';

class AdminHomeCubit extends Cubit<int> {
  AdminHomeCubit() : super(0);

  void changeTab(int index) => emit(index);
}
