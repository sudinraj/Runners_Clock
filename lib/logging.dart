//this page is for the database model

// ignore: camel_case_types
class logging{
  //id is the date and time when the run was stopped
  final String id;
  final String runD;
  final String walkD;
  final double runTime;
  final double walkTime;
  final String runSpeed;
  final String walkSpeed;
  final int totalMinute;
  final int totalSecond;

  const logging({required this.id, required this.runD, required this.walkD, required this.runTime, required this.walkTime, required this.runSpeed, required this.walkSpeed, required this.totalMinute, required this.totalSecond});

  factory logging.fromJson(Map<String, dynamic> json) => logging(
    id: json['id'],
    runD: (json['runD']).toString(),
    walkD: json['walkD'].toString(),
    runTime: json['runTime'],
    walkTime: json['walkTime'],
    runSpeed: json['runSpeed'].toString(),
    walkSpeed: json['walkSpeed'].toString(),
    totalMinute: json['totalMinute'],
    totalSecond: json['totalSecond'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'runD': runD,
    'walkD': walkD,
    'runTime': runTime,
    'walkTime': walkTime,
    'runSpeed': runSpeed,
    'walkSpeed': walkSpeed,
    'totalMinute': totalMinute,
    'totalSecond': totalSecond,
  };
}