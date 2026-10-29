import '../../../core/utils/json_utils.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;

  /// "Laki-laki" / "Perempuan" / kosong.
  final String gender;

  /// Format YYYY-MM-DD, kosong bila belum diisi.
  final String birthDate;

  /// Email baru yang menunggu verifikasi kode (kosong bila tidak ada).
  final String pendingEmail;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'customer',
    this.gender = '',
    this.birthDate = '',
    this.pendingEmail = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: JsonUtils.asString(JsonUtils.pick(json, ['id', 'user_id'])),
      name: JsonUtils.asString(
        JsonUtils.pick(json, ['name', 'full_name', 'fullName', 'nama']),
      ),
      email: JsonUtils.asString(json['email']),
      phone: JsonUtils.asString(
        JsonUtils.pick(json, ['phone', 'phone_number', 'no_hp', 'telepon']),
      ),
      role: JsonUtils.asString(json['role'], fallback: 'customer'),
      gender: JsonUtils.asString(json['gender']),
      birthDate: JsonUtils.asString(
        JsonUtils.pick(json, ['birthDate', 'birth_date']),
      ),
      pendingEmail: JsonUtils.asString(
        JsonUtils.pick(json, ['pendingEmail', 'pending_email']),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'gender': gender,
        'birthDate': birthDate,
      };
}

class AuthResult {
  final String token;
  final UserModel user;

  const AuthResult({required this.token, required this.user});
}
