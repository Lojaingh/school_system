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
    int parseInt(dynamic value) {
      if (value == null) return 0;

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(value.toString()) ?? 0;
    }

    int? parseNullableInt(dynamic value) {
      if (value == null) return null;

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(value.toString());
    }

    final id = parseInt(json['id']);
    final academicId = parseInt(json['academic_id']);
    final supervisorId = parseNullableInt(json['supervisor_id']);
    final year = parseInt(json['year']);
    final number = parseInt(json['number']);

    return SchoolClassModel(
      id: id,
      academicId: academicId,
      supervisorId: supervisorId,
      year: year,
      number: number,
      label: json['label']?.toString() ?? 'Grade $year - $number',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
