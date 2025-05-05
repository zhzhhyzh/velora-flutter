class DesignerModel {
  final String id;
  final String name;
  final double fee;
  final String category;
  final String location;
  final String profileImg;
  final List<String> portfolioImg;

  DesignerModel({
    required this.id,
    required this.name,
    required this.fee,
    required this.category,
    required this.location,
    required this.profileImg,
    required this.portfolioImg,
});

  Map<String,dynamic> toMap() {
    return {
      'id' : id,
      'name' : name,
      'fee' : fee,
      'category' : category,
      'location' : location,
      'profileImg' : profileImg,
      'portfolioImg' : List<String>.from(portfolioImg),
    };
  }

  factory DesignerModel.fromMap(Map<String, dynamic> data) {
    return DesignerModel(
      id: data['id'],
      name: data['name'],
      fee: data['fee'],
      category: data['category'],
      location: data['location'],
      profileImg: data['profileImg'],
      portfolioImg: List<String>.from(data['portfolioImg']),
    );
  }
}