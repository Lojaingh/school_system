import 'package:flutter/material.dart';

class DashboardStats {
  final int studentsCount;
  final int teachersCount;
  final int classesCount;
  final int sectionsCount;
  final String studentsChange;
  final String teachersChange;
  final String classesChange;
  final String sectionsChange;
  final double attendancePercentage;
  final double attendanceChange;
  final List<RecentActivity> recentActivities;

  DashboardStats({
    required this.studentsCount,
    required this.teachersCount,
    required this.classesCount,
    required this.sectionsCount,
    required this.studentsChange,
    required this.teachersChange,
    required this.classesChange,
    required this.sectionsChange,
    required this.attendancePercentage,
    required this.attendanceChange,
    required this.recentActivities,
  });

  static DashboardStats getMockData() {
    return DashboardStats(
      studentsCount: 512,
      teachersCount: 32,
      classesCount: 18,
      sectionsCount: 42,
      studentsChange: '+12 This Month',
      teachersChange: 'Total Teachers',
      classesChange: 'Total Classes',
      sectionsChange: 'Total Sections',
      attendancePercentage: 92.0,
      attendanceChange: 5.0,
      recentActivities: RecentActivity.getMockData(),
    );
  }

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      studentsCount: json['studentsCount'] ?? 0,
      teachersCount: json['teachersCount'] ?? 0,
      classesCount: json['classesCount'] ?? 0,
      sectionsCount: json['sectionsCount'] ?? 0,
      studentsChange: json['studentsChange'] ?? '',
      teachersChange: json['teachersChange'] ?? '',
      classesChange: json['classesChange'] ?? '',
      sectionsChange: json['sectionsChange'] ?? '',
      attendancePercentage: (json['attendancePercentage'] ?? 0).toDouble(),
      attendanceChange: (json['attendanceChange'] ?? 0).toDouble(),
      recentActivities: (json['recentActivities'] as List?)
              ?.map((e) => RecentActivity.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentsCount': studentsCount,
      'teachersCount': teachersCount,
      'classesCount': classesCount,
      'sectionsCount': sectionsCount,
      'studentsChange': studentsChange,
      'teachersChange': teachersChange,
      'classesChange': classesChange,
      'sectionsChange': sectionsChange,
      'attendancePercentage': attendancePercentage,
      'attendanceChange': attendanceChange,
      'recentActivities': recentActivities.map((e) => e.toJson()).toList(),
    };
  }
}

class RecentActivity {
  final String title;
  final String iconName;
  final String colorHex;

  RecentActivity({
    required this.title,
    required this.iconName,
    required this.colorHex,
  });

  static List<RecentActivity> getMockData() {
    return [
      RecentActivity(
          title: 'New Student Registration',
          iconName: 'person_add',
          colorHex: '#3B5BDB'),
      RecentActivity(
          title: 'New Teacher Registration',
          iconName: 'person_add',
          colorHex: '#3B5BDB'),
      RecentActivity(
          title: 'Class Schedule Edit', iconName: 'edit', colorHex: '#F59E0B'),
      RecentActivity(
          title: 'Weekly Absence Report',
          iconName: 'assignment',
          colorHex: '#22C55E'),
      RecentActivity(
          title: 'Add Book to Library',
          iconName: 'menu_book',
          colorHex: '#8B5CF6'),
    ];
  }

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      title: json['title'] ?? '',
      iconName: json['iconName'] ?? '',
      colorHex: json['colorHex'] ?? '#3B5BDB',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'iconName': iconName,
      'colorHex': colorHex,
    };
  }

  IconData get icon {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add_rounded;
      case 'edit':
        return Icons.edit_rounded;
      case 'assignment':
        return Icons.assignment_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}

class StaffStats {
  final int total;
  final int teachers;
  final int staffWithoutTeachers;

  StaffStats({
    required this.total,
    required this.teachers,
    required this.staffWithoutTeachers,
  });

  factory StaffStats.fromJson(Map<String, dynamic> json) {
    return StaffStats(
      total: json['total'],
      teachers: json['teachers'],
      staffWithoutTeachers: json['staff without teachers'],
    );
  }
}

class StudentStats {
  final int total;

  StudentStats({required this.total});

  factory StudentStats.fromJson(Map<String, dynamic> json) {
    return StudentStats(
      total: json['total number of students'] ?? 0,
    );
  }
}

// إحصائيات الداشبورد المجمعة
class DashboardApiStats {
  final int students;
  final int teachers;
  final int employees;
  final int books; // مؤقتاً 0 حتى يتوفر API

  DashboardApiStats({
    required this.students,
    required this.teachers,
    required this.employees,
    this.books = 0,
  });
}
