class SchoolClass {
  final int id;
  final int academicId;
  final int? supervisorId;
  final int year;
  final int number;
  final String createdAt;
  final String updatedAt;

  SchoolClass({
    required this.id,
    required this.academicId,
    this.supervisorId,
    required this.year,
    required this.number,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id'] ?? 0,
      academicId: json['academic_id'] ?? 0,
      supervisorId: json['supervisor_id'],
      year: json['year'] ?? 0,
      number: json['number'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academic_id': academicId,
      'supervisor_id': supervisorId,
      'year': year,
      'number': number,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get displayName => 'Grade $year - Section $number';

  String get shortName => '$year-$number';
}

class AddClassRequest {
  final int? supervisorId;
  final int year;
  final int number;

  AddClassRequest({
    this.supervisorId,
    required this.year,
    required this.number,
  });

  Map<String, dynamic> toJson() {
    return {
      'supervisor_id': supervisorId,
      'year': year,
      'number': number,
    };
  }
}
