class JobModel {
  final String id;
  final String jobTitle;
  final String comName;
  final String jobLocation;
  final String jobCat;
  final String? jobImage; // base64
  final DateTime? deadline;

  JobModel({
    required this.id,
    required this.jobTitle,
    required this.comName,
    required this.jobLocation,
    required this.jobCat,
    this.jobImage,
    this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobTitle': jobTitle,
      'comName': comName,
      'jobLocation': jobLocation,
      'jobCat': jobCat,
      'jobImage': jobImage,
      'deadline': deadline?.toIso8601String(),
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'],
      jobTitle: map['jobTitle'],
      comName: map['comName'],
      jobLocation: map['jobLocation'],
      jobCat: map['jobCat'],
      jobImage: map['jobImage'],
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
    );
  }
}
