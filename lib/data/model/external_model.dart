class ExternalModel {
  final int id;

  final String path;
  final String? downloadUrl;
  final String extension;
  final String? notes;
  final int academicId;
  final int schoolClassId;
  final int teacherId;
  final String? academicStartDate;
  final String? academicEndDate;
  final String? academicStatus;
  final String? classLabel;
  final int? classYear;
  final int? classNumber;
  final String? teacherName;
  final String? createdAt;
  final String? updatedAt;

  ExternalModel({
    required this.id,
    required this.path,
    this.downloadUrl,
    required this.extension,
    this.notes,
    required this.academicId,
    required this.schoolClassId,
    required this.teacherId,
    this.academicStartDate,
    this.academicEndDate,
    this.academicStatus,
    this.classLabel,
    this.classYear,
    this.classNumber,
    this.teacherName,
    this.createdAt,
    this.updatedAt,
  });

  factory ExternalModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final academic = json['academic'] is Map
        ? Map<String, dynamic>.from(
            json['academic'],
          )
        : <String, dynamic>{};

    final academicYear = json['academicYear'] is Map
        ? Map<String, dynamic>.from(
            json['academicYear'],
          )
        : <String, dynamic>{};

    final schoolClass = json['schoolClass'] is Map
        ? Map<String, dynamic>.from(
            json['schoolClass'],
          )
        : <String, dynamic>{};

    final teacher = json['teacher'] is Map
        ? Map<String, dynamic>.from(
            json['teacher'],
          )
        : <String, dynamic>{};

    return ExternalModel(
      id: int.tryParse(
            json['id']?.toString() ?? '',
          ) ??
          0,
      path: json['path']?.toString() ?? '',
      downloadUrl: json['download_url']?.toString(),
      extension: json['extension']?.toString() ?? '',
      notes: json['notes']?.toString(),
      academicId: int.tryParse(
            json['academic_id']?.toString() ?? '',
          ) ??
          0,
      schoolClassId: int.tryParse(
            json['school_class_id']?.toString() ?? '',
          ) ??
          0,
      teacherId: int.tryParse(
            json['teacher_id']?.toString() ?? '',
          ) ??
          0,
      academicStartDate: academic['start_date']?.toString() ??
          academicYear['start_date']?.toString(),
      academicEndDate: academic['end_date']?.toString() ??
          academicYear['end_date']?.toString(),
      academicStatus:
          academic['status']?.toString() ?? academicYear['status']?.toString(),
      classLabel: schoolClass['label']?.toString(),
      classYear: int.tryParse(
        schoolClass['year']?.toString() ?? '',
      ),
      classNumber: int.tryParse(
        schoolClass['number']?.toString() ?? '',
      ),
      teacherName: teacher['name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
