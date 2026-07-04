class Assignment {
  final int id;
  final String title;
  final String body;
  final String dueDate;
  final String subjectName;

  Assignment({
    required this.id,
    required this.title,
    required this.body,
    required this.dueDate,
    required this.subjectName,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      dueDate: json['due_date'] ?? '',
      subjectName: json['subject']?['name'] ?? '',
    );
  }
}
