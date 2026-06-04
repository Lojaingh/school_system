import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_colors.dart' as app;

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(
          gradient: app.AppGradients.backgroundGradient,
        ),
        child: SingleChildScrollView(
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
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Welcome back, Admin !',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Date Picker Button
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                          'May 20, 2025',
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
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Students',
                      value: '320',
                      icon: Icons.people_rounded,
                      color: AppColors.cardBlue,
                      change: '+12 this month',
                      changePositive: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Teachers',
                      value: '28',
                      icon: Icons.school_rounded,
                      color: AppColors.cardGreen,
                      change: '+2 this month',
                      changePositive: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Classes',
                      value: '18',
                      icon: Icons.menu_book_rounded,
                      color: AppColors.cardOrange,
                      change: 'No change',
                      changePositive: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Total Fees',
                      value: '\$24,560',
                      icon: Icons.attach_money_rounded,
                      color: AppColors.cardPurple,
                      change: '+8% this month',
                      changePositive: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Row 2: Attendance Chart + Recent Activities ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attendance Overview
                  Expanded(
                    flex: 6,
                    child: _AttendanceCard(),
                  ),
                  const SizedBox(width: 16),
                  // Recent Activities
                  Expanded(
                    flex: 4,
                    child: _RecentActivitiesCard(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Row 3: Fees Collection + Top Classes ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fees Collection
                  Expanded(
                    flex: 5,
                    child: _FeesCollectionCard(),
                  ),
                  const SizedBox(width: 16),
                  // Top Classes
                  Expanded(
                    flex: 5,
                    child: _TopClassesCard(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// Stat Card
// ══════════════════════════════════════════
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

// ══════════════════════════════════════════
// Attendance Overview Card
// ══════════════════════════════════════════
class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard();

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية للـ chart
    final List<double> data = [85, 72, 90, 88, 95, 80, 98];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
          // Header
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
                    Text(
                      'This Week',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Simple Line Chart using CustomPaint
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
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
                // Chart Area
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

          // X-axis labels
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
}

// Line Chart Painter
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

    // Grid lines
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

    // Fill area under curve
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, gradientPaint);

    // Draw line
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

    // Draw dots
    for (final p in points) {
      canvas.drawCircle(p, 5, dotBorderPaint);
      canvas.drawCircle(p, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════
// Recent Activities Card
// ══════════════════════════════════════════
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
      title: 'Fee payment received',
      subtitle: 'John Doe',
      icon: Icons.attach_money_rounded,
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

// ══════════════════════════════════════════
// Fees Collection Card
// ══════════════════════════════════════════
class _FeesCollectionCard extends StatelessWidget {
  const _FeesCollectionCard();

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fees Collection',
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
              // Donut Chart
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _DonutChartPainter(
                        collected: 0.75,
                        collectedColor: AppColors.primary,
                        pendingColor: AppColors.cardPurple,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '\$24,560',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Total',
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

              // Legend
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem(
                    color: AppColors.primary,
                    label: 'Collected',
                    value: '\$18,450 (75%)',
                  ),
                  const SizedBox(height: 12),
                  _LegendItem(
                    color: AppColors.cardPurple,
                    label: 'Pending',
                    value: '\$6,110 (25%)',
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

    const startAngle = -1.5708; // -90 degrees
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

// ══════════════════════════════════════════
// Top Classes Card
// ══════════════════════════════════════════
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
          // Header
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

          // Progress Bars
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
