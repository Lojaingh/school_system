class SchoolClassModel {
  final int id;
  final int academicId;
  final int? supervisorId;
  final int year;
  final int number;
  final String? label;
  final String? createdAt;
  final String? updatedAt;

  SchoolClassModel({
    required this.id,
    required this.academicId,
    this.supervisorId,
    required this.year,
    required this.number,
    this.label,
    this.createdAt,
    this.updatedAt,
  });

  factory SchoolClassModel.fromJson(Map<String, dynamic> json) {
    return SchoolClassModel(
      id: json["id"] ?? 0,
      academicId: json["academic_id"] ?? 0,
      supervisorId: json["supervisor_id"],
      year: json["year"] ?? 0,
      number: json["number"] ?? 0,
      label: json["label"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
    );
  }
}
