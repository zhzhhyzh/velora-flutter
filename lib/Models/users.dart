class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String position;
  final String? userImage; // base64 encoded image

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.position,
    this.userImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'position': position,
      'userImage': userImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      position: map['position'],
      userImage: map['userImage'],
    );
  }
}
