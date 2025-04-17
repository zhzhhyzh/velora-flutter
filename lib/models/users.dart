class Users {
  late String? username;
  late String? hp;
  late String? email;
  late String? password;
  late String? imageUrl;

  Users({
    required this.username,
    required this.hp,
    required this.password,
    required this.email,
    this.imageUrl,
  });

  String? get getHp => hp;

  String? get getUsername => username;

  String? get getPassword => password;

  String? get getEmail => email;

  String? get getImageUrl => imageUrl;


  set setUsername(String username) {
    this.username = username;
  }

  set setHp(String hp) {
    this.hp = hp;
  }

  set setPassword(String password) {
    this.password = password;
  }




  set setEmail(String email) {
    this.email = email;
  }

  set setImageUrl(String? url) {
    imageUrl = url;
  }
}