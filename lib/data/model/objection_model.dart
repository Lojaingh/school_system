class ObjectionModel {
  final int id;
  final String message;
  final String status;
  final int? supervisorId;
  final String? supervisorName;
  final int? studentId;
  final String? studentName;
  final int? academicId;
  final String? createdAt;

  ObjectionModel({
    required this.id,
    required this.message,
    required this.status,
    this.supervisorId,
    this.supervisorName,
    this.studentId,
    this.studentName,
    this.academicId,
    this.createdAt,
  });

  factory ObjectionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final supervisor = json['supervisor'] is Map
        ? Map<String, dynamic>.from(
            json['supervisor'],
          )
        : <String, dynamic>{};

    final student = json['student'] is Map
        ? Map<String, dynamic>.from(
            json['student'],
          )
        : <String, dynamic>{};

    return ObjectionModel(
      id: int.tryParse(
            json['id']?.toString() ?? '',
          ) ??
          0,
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      supervisorId: int.tryParse(
        supervisor['id']?.toString() ?? '',
      ),
      supervisorName: supervisor['name']?.toString(),
      studentId: int.tryParse(
        student['id']?.toString() ?? '',
      ),
      studentName: student['name']?.toString(),
      academicId: int.tryParse(
        json['academic_id']?.toString() ?? '',
      ),
      createdAt: json['created_at']?.toString(),
    );
  }
}
