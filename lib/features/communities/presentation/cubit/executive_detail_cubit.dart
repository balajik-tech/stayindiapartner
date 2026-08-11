import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_executive_structure_usecase.dart';
import 'executive_detail_state.dart';

class ExecutiveDetailCubit extends Cubit<ExecutiveDetailState> {
  final GetExecutiveStructureUseCase getExecutiveStructure;

  ExecutiveDetailCubit({required this.getExecutiveStructure}) : super(ExecutiveDetailInitial());

  Future<void> loadStructure(String execId) async {
    emit(ExecutiveDetailLoading());
    try {
      final leaders = await getExecutiveStructure(execId);
      emit(ExecutiveDetailLoaded(leaders));
    } catch (e) {
      emit(ExecutiveDetailError(e.toString()));
    }
  }
}
