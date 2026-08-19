class StaffModel {
  final String fName;
  final String mName;
  final String lName;
  final String gender;
  final String dob;
  final String address;
  final int roleId;
  final String hireDate;
  final double salary;
  final String contact;

  // Teacher only
  final int? subjectId;
  final String? notes;

  StaffModel({
    required this.fName,
    required this.mName,
    required this.lName,
    required this.gender,
    required this.dob,
    required this.address,
    required this.roleId,
    required this.hireDate,
    required this.salary,
    required this.contact,
    this.subjectId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      "f_name": fName,
      "m_name": mName,
      "l_name": lName,
      "gender": gender,
      "dob": dob,
      "address": address,
      "role_id": roleId,
      "hire_date": hireDate,
      "salary": salary,
      "contact": contact,
    };
  }

  // JSON خاص بالأستاذ
  Map<String, dynamic> toTeacherJson() {
    return {
      "f_name": fName,
      "m_name": mName,
      "l_name": lName,
      "gender": gender,
      "dob": dob,
      "address": address,
      "role_id": roleId,
      "hire_date": hireDate,
      "salary": salary,
      "contact": contact,
      "subject_id": subjectId,
      "notes": notes,
    };
  }
}
