class DesignerModel {
  final String id;
  final String name;
  final String category;
  final String contact;
  final String country;
  final String desc;
  final String designerId;
  final String email;
  final String profileImg;
  final String rate;
  final String slogan;
  final String state;

  DesignerModel({
    required this.id,
    required this.name,
    required this.category,
    required this.contact,
    required this.country,
    required this.desc,
    required this.designerId,
    required this.email,
    required this.profileImg,
    required this.rate,
    required this.slogan,
    required this.state,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'contact': contact,
      'country': country,
      'desc': desc,
      'designerId': designerId,
      'email': email,
      'profileImg': profileImg,
      'rate': rate,
      'slogan': slogan,
      'state': state,
    };
  }

  factory DesignerModel.fromMap(Map<String, dynamic> map) {
    return DesignerModel(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      contact: map['contact'],
      country: map['country'],
      desc: map['desc'],
      designerId: map['designerId'],
      email: map['email'],
      profileImg: map['profileImg'],
      rate: map['rate'],
      slogan: map['slogan'],
      state: map['state'],
    );
  }
}
