class DesignerModel {
  final String id;
  final String name;
  final double rate;
  final String category;
  final String location;
  final String? profileImg;
  final List<String>? workImgs;
  final String? about;
  final String? slogan;
  final String contact;
  final String email;

  DesignerModel({
    required this.id,
    required this.name,
    required this.rate,
    required this.category,
    required this.location,
    this.profileImg,
    this.workImgs,
    this.about,
    this.slogan,
    required this.contact,
    required this.email
  });

  Map<String, dynamic> toMap() {
    return {
      'DesignerId': id,
      'name': name,
      'rate': rate,
      'category': category,
      'location': location,
      'profileImg': profileImg,
      'workImgs': workImgs ?? [],
      'about': about,
      'slogan': slogan,
      'contact' : contact,
      'email' : email
    };
  }

  factory DesignerModel.fromMap(Map<String, dynamic> data) {
    return DesignerModel(
      id: data['DesignerId'],
      name: data['name'],
      rate: data['rate'],
      category: data['category'],
      location: data['location'],
      profileImg: data['profileImg'],
        workImgs: data['portfolioImg'] != null
            ? List<String>.from(data['portfolioImg'])
            : [],
      about: data['about'] ?? 'No information provided.',
      slogan: data['slogan'] ?? '',
      contact: data['contact'],
      email: data['email']
    );
  }
}
