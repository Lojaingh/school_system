class SubjectModel {
  final String name;
  final String partition;
  SubjectModel({
    required this.name,
    required this.partition,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "partition": partition,
    };
  }
}
