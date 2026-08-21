import 'package:flutter/material.dart';
import 'package:school_management/data/model/dashboard_model.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_colors.dart' as app;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_management/cubit/assignment/assignment_cubit.dart';
import 'package:school_management/cubit/assignment/assignment_state.dart';
import 'package:school_management/cubit/dashboard/dashboard_cubit.dart';
import 'package:school_management/cubit/schedule/schedule_cubit.dart';
import 'package:school_management/data/model/schedule_model.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';

class DashboardContent extends StatefulWidget {
  final VoidCallback? onOpenSchedule;
  const DashboardContent({super.key, this.onOpenSchedule});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await SharedPrefsHelper.getRole();
    setState(() {
      userRole = role;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final isManager = userRole?.toLowerCase() == 'manager';
    final isSupervisor = userRole?.toLowerCase() == 'supervisor';
    final isTeacher = userRole?.toLowerCase() == 'teacher';
    final isLibrarian = userRole?.toLowerCase() == 'librarian';
    final isStudent = userRole?.toLowerCase() == 'student';

    String welcomeText = 'Welcome back, Admin !';
    if (isSupervisor)
      welcomeText = 'Welcome, Supervisor !';
    else if (isTeacher)
      welcomeText = 'Welcome, Teacher !';
    else if (isLibrarian)
      welcomeText = 'Welcome, Librarian !';
    else if (isStudent) welcomeText = 'Welcome, Student !';

    return SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(
          gradient: app.AppGradients.backgroundGradient,
        ),
        child: RefreshIndicator(
          onRefresh: () {
            return context.read<DashboardCubit>().loadStats();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Welcome Row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isManager ? 'Dashboard' : 'My Dashboard',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          welcomeText,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: app.AppGradients.cardGradient,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.cardBorder.withOpacity(0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMM dd, yyyy').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Stat Cards Row ──
                if (isManager)
                  _buildManagerStats()
                else if (isSupervisor)
                  _buildSupervisorStats()
                else if (isTeacher)
                  _buildTeacherStats()
                else if (isLibrarian)
                  _buildLibrarianStats()
                else if (isStudent)
                  _buildStudentStats()
                else
                  _buildDefaultStats(),

                const SizedBox(height: 20),

                // ── Row 2 ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _AttendanceCard(),
                    ),
                    const SizedBox(width: 16),
                    if (isManager)
                      Expanded(
                        flex: 4,
                        child: _RecentActivitiesCard(),
                      )
                    else if (isSupervisor || isTeacher)
                      Expanded(
                        flex: 4,
                        child: _ClassOverviewCard(),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Row 3 ──
                if (isManager)
                  Row(
                    children: [
                      Expanded(
                        child: _FeesCollectionCard(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _UpcomingExamsCard(),
                      ),
                    ],
                  )
                else if (isSupervisor || isTeacher)
                  Row(
                    children: [
                      Expanded(
                        child: _ClassAttendanceCard(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _UpcomingExamsCard(),
                      ),
                    ],
                  )
                else if (isLibrarian)
                  Row(
                    children: [
                      Expanded(
                        child: _LibraryStatsCard(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _RecentBooksCard(),
                      ),
                    ],
                  )
                else if (isStudent)
                  Row(
                    children: [
                      Expanded(
                        child: _MyBooksCard(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MyExamsCard(),
                      ),
                    ],
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 16),

                // ── Row 4: Weekly Schedule (برنامج الأسبوع) ──
                if (isManager)
                  _WeeklyScheduleCard(onOpenSchedule: widget.onOpenSchedule),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManagerStats() {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return _buildSkeletonCards();
        } else if (state is DashboardLoaded) {
          return Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Students',
                  value: state.stats.students.toString(),
                  icon: Icons.people_rounded,
                  color: AppColors.cardBlue,
                  change: 'Total Students',
                  changePositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Teachers',
                  value: state.stats.teachers.toString(),
                  icon: Icons.school_rounded,
                  color: AppColors.cardGreen,
                  change: 'Total Teachers',
                  changePositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Employees',
                  value: state.stats.employees.toString(),
                  icon: Icons.badge_rounded,
                  color: AppColors.cardOrange,
                  change: 'Total Employees',
                  changePositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Books',
                  value: state.stats.books.toString(),
                  icon: Icons.library_books_rounded,
                  color: AppColors.cardPurple,
                  change: 'Coming Soon',
                  changePositive: true,
                ),
              ),
            ],
          );
        } else if (state is DashboardError) {
          return buildErrorCard(context, state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSupervisorStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'My Students',
            value: '0',
            icon: Icons.people_rounded,
            color: AppColors.cardBlue,
            change: 'Class',
            changePositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Present Today',
            value: '0',
            icon: Icons.check_circle_rounded,
            color: AppColors.cardGreen,
            change: '0%',
            changePositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Absent',
            value: '0',
            icon: Icons.warning_rounded,
            color: AppColors.error,
            change: '0%',
            changePositive: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Objections',
            value: '0',
            icon: Icons.feedback_rounded,
            color: AppColors.cardOrange,
            change: 'Pending',
            changePositive: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'My Students',
            value: '0',
            icon: Icons.people_rounded,
            color: AppColors.cardBlue,
            change: 'Total',
            changePositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Present Today',
            value: '0',
            icon: Icons.check_circle_rounded,
            color: AppColors.cardGreen,
            change: '0%',
            changePositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Absent',
            value: '0',
            icon: Icons.warning_rounded,
            color: AppColors.error,
            change: '0%',
            changePositive: false,
          ),
        ),
      ],
    );
  }

  Widget _buildLibrarianStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Books',
            value: '0',
            icon: Icons.library_books_rounded,
            color: AppColors.cardBlue,
            change: 'In Library',
            changePositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Borrowed',
            value: '0',
            icon: Icons.book_rounded,
            color: AppColors.cardOrange,
            change: 'Currently Out',
            changePositive: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Available',
            value: '0',
            icon: Icons.check_circle_rounded,
            color: AppColors.cardGreen,
            change: 'Ready to Borrow',
            changePositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Late Returns',
            value: '0',
            icon: Icons.warning_rounded,
            color: AppColors.error,
            change: 'Overdue',
            changePositive: false,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'My Books',
            value: '0',
            icon: Icons.menu_book_rounded,
            color: AppColors.cardBlue,
            change: 'Borrowed',
            changePositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Upcoming Exams',
            value: '0',
            icon: Icons.assignment_rounded,
            color: AppColors.cardOrange,
            change: 'This Week',
            changePositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Objections',
            value: '0',
            icon: Icons.feedback_rounded,
            color: AppColors.cardPurple,
            change: 'Pending',
            changePositive: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Attendance',
            value: '0%',
            icon: Icons.how_to_reg_rounded,
            color: AppColors.cardGreen,
            change: 'This Month',
            changePositive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Welcome',
            value: '👋',
            icon: Icons.waving_hand_rounded,
            color: AppColors.cardBlue,
            change: 'You are logged in',
            changePositive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCards() {
    return Row(
      children: [
        Expanded(child: _StatCardSkeleton()),
        const SizedBox(width: 12),
        Expanded(child: _StatCardSkeleton()),
        const SizedBox(width: 12),
        Expanded(child: _StatCardSkeleton()),
        const SizedBox(width: 12),
        Expanded(child: _StatCardSkeleton()),
      ],
    );
  }

  Widget buildErrorCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error loading stats: $message',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<DashboardCubit>().refreshStats();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: 13,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 11,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;
  final bool changePositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
    required this.changePositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          ...app.AppShadows.cardShadow,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                changePositive
                    ? Icons.arrow_upward_rounded
                    : Icons.remove_rounded,
                size: 12,
                color: changePositive
                    ? AppColors.cardGreen
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 11,
                  color: changePositive
                      ? AppColors.cardGreen
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClassOverviewCard extends StatelessWidget {
  const _ClassOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'My Class Overview',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.people_rounded),
            title: Text('Total Students'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.check_circle_rounded),
            title: Text('Present Today'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.warning_rounded),
            title: Text('Absent'),
            trailing: Text('0'),
          ),
        ],
      ),
    );
  }
}

class _ClassAttendanceCard extends StatelessWidget {
  const _ClassAttendanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Today\'s Attendance',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.people_rounded, color: AppColors.cardBlue),
            title: Text('Total'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.check_circle_rounded, color: AppColors.cardGreen),
            title: Text('Present'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.warning_rounded, color: AppColors.error),
            title: Text('Absent'),
            trailing: Text('0'),
          ),
        ],
      ),
    );
  }
}

class _LibraryStatsCard extends StatelessWidget {
  const _LibraryStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Library Stats',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.library_books_rounded, color: AppColors.cardBlue),
            title: Text('Total Books'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.bookmark_added_rounded, color: AppColors.cardOrange),
            title: Text('Borrowed'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.check_circle_rounded, color: AppColors.cardGreen),
            title: Text('Available'),
            trailing: Text('0'),
          ),
        ],
      ),
    );
  }
}

class _RecentBooksCard extends StatelessWidget {
  const _RecentBooksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.book_rounded, color: AppColors.cardOrange),
            title: Text('Recently Borrowed'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.replay_rounded, color: AppColors.cardGreen),
            title: Text('Returned Today'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.warning_rounded, color: AppColors.error),
            title: Text('Overdue'),
            trailing: Text('0'),
          ),
        ],
      ),
    );
  }
}

class _MyBooksCard extends StatelessWidget {
  const _MyBooksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'My Books',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.menu_book_rounded, color: AppColors.cardBlue),
            title: Text('Currently Borrowed'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.calendar_today_rounded, color: AppColors.cardOrange),
            title: Text('Due This Week'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.warning_rounded, color: AppColors.error),
            title: Text('Overdue'),
            trailing: Text('0'),
          ),
        ],
      ),
    );
  }
}

class _MyExamsCard extends StatelessWidget {
  const _MyExamsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Upcoming Exams',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.assignment_rounded, color: AppColors.cardOrange),
            title: Text('Mathematics'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.assignment_rounded, color: AppColors.cardOrange),
            title: Text('Physics'),
            trailing: Text('0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.assignment_rounded, color: AppColors.cardBlue),
            title: Text('Chemistry'),
            trailing: Text('0'),
          ),
        ],
      ),
    );
  }
}

class _UpcomingExamsCard extends StatelessWidget {
  const _UpcomingExamsCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssignmentCubit, AssignmentState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: app.AppGradients.cardGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: app.AppShadows.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming Exams',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              if (state is AssignmentLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state is AssignmentLoaded &&
                  state.assignments.isNotEmpty)
                Column(
                  children: state.assignments.take(3).map((assignment) {
                    final dateParts = assignment.dueDate.split('-');
                    final monthName = _getMonthName(int.parse(dateParts[1]));
                    final displayDate = '${dateParts[2]} $monthName';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.assignment_rounded,
                        color: AppColors.cardBlue,
                      ),
                      title: Text(
                        assignment.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        assignment.subjectName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 112, 111, 111),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            displayDate,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else if (state is AssignmentLoaded && state.assignments.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No upcoming exams or quizzes',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else if (state is AssignmentError)
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading exams',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        state.message,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        List<double> data = [];
        List<String> days = [];

        if (state is DashboardLoaded && state.weeklyAttendance != null) {
          final attendanceDays = state.weeklyAttendance!.days;
          data = attendanceDays.map((day) => day.students.percentage).toList();
          days = attendanceDays.map((day) => day.dayName).toList();
        } else if (state is DashboardLoading) {
          return _buildSkeleton();
        } else {
          // بيانات وهمية احتياطية
          data = [85, 72, 90, 88, 95, 80, 98];
          days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        }

        return _buildChartCard(data, days);
      },
    );
  }

  Widget _buildChartCard(List<double> data, List<String> days) {
    final double maxVal = 100;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: app.AppGradients.glowGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('This Week',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: ['100%', '75%', '50%', '25%', '0%']
                      .map((e) => Text(e,
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)))
                      .toList(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomPaint(
                    painter: _LineChartPainter(data: data, maxVal: maxVal),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days
                  .map((d) => Text(d,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxVal;

  _LineChartPainter({required this.data, required this.maxVal});

  @override
  void paint(Canvas canvas, Size size) {
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.3),
          AppColors.primary.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (data.isEmpty) return;

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = size.width * (i / (data.length - 1));
      final y = size.height * (1 - data[i] / maxVal);
      points.add(Offset(x, y));
    }

    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, gradientPaint);

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 =
          Offset((points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    for (final p in points) {
      canvas.drawCircle(p, 5, dotBorderPaint);
      canvas.drawCircle(p, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecentActivitiesCard extends StatelessWidget {
  const _RecentActivitiesCard();

  final List<_ActivityItem> _activities = const [
    _ActivityItem(
      title: 'New student registered',
      subtitle: 'Ali Hassan',
      icon: Icons.person_add_rounded,
      color: AppColors.cardBlue,
      time: '10:30 AM',
    ),
    _ActivityItem(
      title: 'Teacher attendance marked',
      subtitle: 'Mr. Ahmed',
      icon: Icons.how_to_reg_rounded,
      color: AppColors.cardGreen,
      time: '09:15 AM',
    ),
    _ActivityItem(
      title: 'Exam scheduled',
      subtitle: 'Math Exam (Grade 10)',
      icon: Icons.assignment_rounded,
      color: AppColors.cardOrange,
      time: 'Yesterday',
    ),
    _ActivityItem(
      title: 'Book borrowed',
      subtitle: 'Grade 10 Student',
      icon: Icons.library_books_rounded,
      color: AppColors.cardPurple,
      time: 'May 18',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ..._activities.map((item) => _ActivityTile(item: item)),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String time;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.time,
  });
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;
  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.time,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeesCollectionCard extends StatelessWidget {
  const _FeesCollectionCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        int totalStaff = 0;
        int totalPresent = 0;
        int totalAbsent = 0;
        double percentage = 0.0;

        if (state is DashboardLoaded && state.weeklyAttendance != null) {
          final groups = state.weeklyAttendance!.groups;
          final staff = groups.staffWithoutTeachers;
          final teachers = groups.teachers;

          totalStaff = staff.totalPeople + teachers.totalPeople;
          totalPresent = staff.present + teachers.present;
          totalAbsent = staff.absent + teachers.absent;
          percentage = totalStaff > 0 ? (totalPresent / totalStaff) * 100 : 0.0;
        } else {
          // بيانات وهمية احتياطية
          totalStaff = 5;
          totalPresent = 4;
          totalAbsent = 1;
          percentage = 80.0;
        }

        return _buildStaffAttendanceCard(percentage, totalPresent, totalAbsent);
      },
    );
  }

  Widget _buildStaffAttendanceCard(double percentage, int present, int absent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Staff Attendance',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: app.AppGradients.glowGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('This Month',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _DonutChartPainter(
                        collected: percentage / 100,
                        collectedColor: AppColors.primary,
                        pendingColor: AppColors.cardPurple,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Present',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem(
                    color: AppColors.cardGreen,
                    label: 'Present Staff',
                    value: '$present Employees',
                  ),
                  const SizedBox(height: 12),
                  _LegendItem(
                    color: AppColors.cardOrange,
                    label: 'Absent Staff',
                    value: '$absent Employees',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }
}

// Donut Chart Painter
class _DonutChartPainter extends CustomPainter {
  final double collected;
  final Color collectedColor;
  final Color pendingColor;

  _DonutChartPainter({
    required this.collected,
    required this.collectedColor,
    required this.pendingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 14.0;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final collectedPaint = Paint()
      ..color = collectedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final pendingPaint = Paint()
      ..color = pendingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -1.5708;
    final collectedSweep = 2 * 3.14159 * collected;
    final pendingSweep = 2 * 3.14159 * (1 - collected);

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      collectedSweep - 0.05,
      false,
      collectedPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + collectedSweep,
      pendingSweep - 0.05,
      false,
      pendingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopClassesCard extends StatelessWidget {
  const _TopClassesCard();

  @override
  Widget build(BuildContext context) {
    final classes = [
      ('Grade 10 - A', 0.92, '92%'),
      ('Grade 9 - B', 0.87, '87%'),
      ('Grade 8 - A', 0.78, '78%'),
      ('Grade 7 - B', 0.72, '72%'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: app.AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Classes',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: app.AppGradients.glowGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('By Attendance',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...classes.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          c.$1,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          c.$3,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: c.$2,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _WeeklyScheduleCard extends StatelessWidget {
  final VoidCallback? onOpenSchedule;
  const _WeeklyScheduleCard({this.onOpenSchedule});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleCubit()..loadSchedulesOnly(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: app.AppGradients.cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: app.AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Schedule',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: onOpenSchedule,
                  icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                  label: const Text('Edit Schedule'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<ScheduleCubit, ScheduleState>(
              builder: (context, state) {
                if (state is ScheduleLoading || state is ScheduleInitial) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is ScheduleError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Failed to load schedule: ${state.message}',
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12),
                    ),
                  );
                }

                final loaded = state as ScheduleLoaded;

                if (loaded.slots.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No schedule found.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  );
                }

                // أسبوع الدراسة 5 أيام بس: الأحد -> الخميس (0..4)
                final Map<int, List<ScheduleSlot>> byDay = {
                  for (int d = 0; d < 5; d++) d: <ScheduleSlot>[],
                };
                for (final s in loaded.slots) {
                  if (s.dayOfWeek >= 0 && s.dayOfWeek < 5) {
                    byDay[s.dayOfWeek]?.add(s);
                  }
                }

                return SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, day) {
                      final daySlots = byDay[day]!
                        ..sort(
                            (a, b) => a.periodNumber.compareTo(b.periodNumber));
                      return _DayColumn(
                        dayLabel: ScheduleSlot.dayNames[day],
                        slots: daySlots,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  final String dayLabel;
  final List<ScheduleSlot> slots;
  const _DayColumn({required this.dayLabel, required this.slots});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: slots.isEmpty
                ? const Center(
                    child: Text(
                      'No classes',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: slots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, i) =>
                        _ScheduleSlotChip(slot: slots[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleSlotChip extends StatelessWidget {
  final ScheduleSlot slot;
  const _ScheduleSlotChip({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${slot.periodNumber}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.subjectName ?? 'Subject #${slot.subjectId}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  slot.teacherDisplayName,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
