class UserModel {
  final String profileImage;
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final DateTime dateOfBirth;
  final String gender;

  UserModel({
    required this.profileImage,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'profileImage': profileImage,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
    };
  }
}
