import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/models/parent/guardian_profile.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/guardian_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_scoped_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';

part 'parent_profile_cubit.freezed.dart';

@freezed
sealed class ParentProfileState with _$ParentProfileState {
  const factory ParentProfileState.initial() = ParentProfileInitial;
  const factory ParentProfileState.loading() = ParentProfileLoading;
  const factory ParentProfileState.error(String message) = ParentProfileError;
  const factory ParentProfileState.loaded(GuardianProfile profile) =
      ParentProfileLoaded;
}

class ParentProfileCubit extends ChildScopedCubit<ParentProfileState> {
  ParentProfileCubit({
    required ChildrenCubit children,
    required GuardianRepository repository,
  }) : _repository = repository,
       super(const ParentProfileState.initial(), children);

  final GuardianRepository _repository;

  @override
  Future<void> load({bool refresh = false}) async {
    final ticket = beginLoad();
    emit(const ParentProfileState.loading());
    try {
      final profile = await _repository.getProfile(childId: child?.id);
      if (isCurrent(ticket)) emit(ParentProfileState.loaded(profile));
    } on Object catch (e, st) {
      if (isCurrent(ticket))
        emit(ParentProfileState.error(errorMessage(e, st)));
    }
  }
}
