class SubjectModel {
  final int id;
  final String name;
  final String partition;
  final String partitionLabel;

  SubjectModel({
    this.id = 0,
    required this.name,
    required this.partition,
    this.partitionLabel = '',
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      partition: json['partition']?.toString() ?? '',
      partitionLabel: json['partition_label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "partition": partition,
    };
  }
}
