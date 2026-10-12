import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    @Default('') String avatarUrl,
    @Default(false) bool hasUnreadNotifications,
  }) = _UserModel;
}
