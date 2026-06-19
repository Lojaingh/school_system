class StudentModel {
  final String username;
  final String password;
  final String fName;
  final String lName;
  final String mName;
  final String gender;
  final String dob;
  final String address;
  final int classId;
  final String healthStatus;
  final int roleId;

  StudentModel({
    required this.username,
    required this.password,
    required this.fName,
    required this.lName,
    required this.mName,
    required this.gender,
    required this.dob,
    required this.address,
    required this.classId,
    required this.healthStatus,
    required this.roleId,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "role_id": roleId,
      "f_name": fName,
      "l_name": lName,
      "m_name": mName,
      "gender": gender,
      "dob": dob,
      "address": address,
      "class_id": classId,
      "health_status": healthStatus,
    };
  }
}
