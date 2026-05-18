import '../../domain/entities/user.dart';

/// Data model for [User] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class UserModel extends User {
  const UserModel({required super.id, required super.email});

  /// Creates a [UserModel] from a JSON map.
  ///
  /// Supports both 'id_uzytkownika' (backend format) and 'id' field names.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id_uzytkownika'] ?? json['id']) as String,
      email: json['email'] as String,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }
}
