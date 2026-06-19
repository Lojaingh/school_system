

class TeacherAttendance {
  final String id;
  final String name;
  final String? subject;
  final String? department; 
  String status;
  final String? time;
  final DateTime date;

  TeacherAttendance({
    required this.id,
    required this.name,
    this.subject,
    this.department,
    required this.status,
    this.time,
    required this.date,
  });

 
  static List<TeacherAttendance> getMockData() {
    final now = DateTime.now();
    return [
      TeacherAttendance(
        id: 'T001',
        name: 'Ahmad Mahmod',
        subject: 'Math',
        department: 'Science',
        status: 'Present',
        time: '07:45',
        date: now,
      ),
      TeacherAttendance(
        id: 'T002',
        name: 'Soad Mohamad',
        subject: 'Science',
        department: 'Science',
        status: 'Present',
        time: '07:50',
        date: now,
      ),
      TeacherAttendance(
        id: 'T003',
        name: 'Khaled Ali',
        subject: 'Arabic',
        department: 'Languages',
        status: 'Late',
        time: '08:20',
        date: now,
      ),
      TeacherAttendance(
        id: 'T004',
        name: 'Nawal Hasan',
        subject: 'English',
        department: 'Languages',
        status: 'Absent',
        time: null,
        date: now,
      ),
    ];
  }

  static Map<String, int> getStats(List<TeacherAttendance> list) {
    return {
      'total': list.length,
      'present': list.where((t) => t.status == 'Present').length,
      'absent': list.where((t) => t.status == 'Absent').length,
      'late': list.where((t) => t.status == 'Late').length,
    };
  }


  factory TeacherAttendance.fromJson(Map<String, dynamic> json) {
    return TeacherAttendance(
      id: json['id'],
      name: json['name'],
      subject: json['subject'],
      department: json['department'],
      status: json['status'],
      time: json['time'],
      date: DateTime.parse(json['date']),
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'department': department,
      'status': status,
      'time': time,
      'date': date.toIso8601String(),
    };
  }
}
