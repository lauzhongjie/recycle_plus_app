import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';

class EditProfileArguments {
  final UserEntity user;
  final List<String> iconUrls;

  EditProfileArguments({required this.user, required this.iconUrls});
}
