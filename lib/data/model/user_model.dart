import 'package:hive_flutter/adapters.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String fullname;

  @HiveField(1)
  String? imagePath;

  UserModel({required this.fullname, this.imagePath});
}
