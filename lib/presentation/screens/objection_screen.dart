import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/cubit/objection/objection_cubit.dart';
import 'package:school_management/cubit/objection/objection_state.dart';
import 'package:school_management/data/model/objection_model.dart';
import 'package:school_management/presentation/screen/widgets/objection_card.dart';

class ObjectionsScreen extends StatefulWidget {
  const ObjectionsScreen({
    super.key,
  });

  @override
  State<ObjectionsScreen> createState() => _ObjectionsScreenState();
}

class _ObjectionsScreenState extends State<ObjectionsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ObjectionCubit>().getObjections();
      }
    });
  }
  void _updateStatus({
    required ObjectionModel objection,
    required String status,
  }) {
    context.read<ObjectionCubit>().updateObjectionStatus(
          id: objection.id,
          status: status,
        );
  }
  List<ObjectionModel> _filterObjections(
    List<ObjectionModel> objections,
  ) {
    if (_selectedFilter == 'all') {
      return objections;
    }

    return objections
        .where(
          (item) => item.status.toLowerCase() == _selectedFilter,
        )
        .toList();
  }

  Widget _filterButton({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final bool selected = _selectedFilter == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(.12)
              : AppColors.cardElement,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(.35)
                : AppColors.cardBorder.withOpacity(.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<ObjectionCubit, ObjectionState>(
          listener: (context, state) {
            if (state is ObjectionUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }

            if (state is ObjectionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
          
            if (state is ObjectionLoading || state is ObjectionInitial) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is ObjectionError) {
              return Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<ObjectionCubit>().getObjections();
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text(
                    'Try Again',
                  ),
                ),
              );
            }
            List<ObjectionModel> objections = [];

            if (state is ObjectionLoaded) {
              objections = state.objections;
            }

            final filtered = _filterObjections(objections);

            final bool updating = state is ObjectionUpdateLoading;

            final pendingCount = objections
                .where(
                  (item) => item.status.toLowerCase() == 'pending',
                )
                .length;

            final reviewedCount = objections
                .where(
                  (item) => item.status.toLowerCase() == 'reviewed',
                )
                .length;

            final deletedCount = objections
                .where(
                  (item) => item.status.toLowerCase() == 'deleted',
                )
                .length;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: AppGradients.cardGradient,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(.12),
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            child: const Icon(
                              Icons.rate_review_outlined,
                              color: AppColors.primary,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Objections',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Review and manage student objections',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Refresh',
                            onPressed: updating
                                ? null
                                : () {
                                    context
                                        .read<ObjectionCubit>()
                                        .getObjections();
                                  },
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              title: 'Total',
                              value: objections.length.toString(),
                              icon: Icons.format_list_bulleted_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatItem(
                              title: 'Pending',
                              value: pendingCount.toString(),
                              icon: Icons.access_time_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatItem(
                              title: 'Reviewed',
                              value: reviewedCount.toString(),
                              icon: Icons.check_circle_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatItem(
                              title: 'Deleted',
                              value: deletedCount.toString(),
                              icon: Icons.delete_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    18,
                    24,
                    6,
                  ),
                  child: Row(
                    children: [
                      _filterButton(
                        value: 'all',
                        label: 'All',
                        icon: Icons.format_list_bulleted_rounded,
                      ),
                      const SizedBox(width: 8),
                      _filterButton(
                        value: 'pending',
                        label: 'Pending',
                        icon: Icons.access_time_rounded,
                      ),
                      const SizedBox(width: 8),
                      _filterButton(
                        value: 'reviewed',
                        label: 'Reviewed',
                        icon: Icons.check_circle_outline_rounded,
                      ),
                      const SizedBox(width: 8),
                      _filterButton(
                        value: 'deleted',
                        label: 'Deleted',
                        icon: Icons.delete_outline_rounded,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No objections found',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            await context
                                .read<ObjectionCubit>()
                                .getObjections();
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.all(
                              24,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 440,
                              mainAxisExtent: 365,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final objection = filtered[index];

                              return ObjectionCard(
                                objection: objection,
                                loading: updating,
                                onReviewed: () {
                                  _updateStatus(
                                    objection: objection,
                                    status: 'reviewed',
                                  );
                                },
                                onDeleted: () {
                                  _showDeleteDialog(
                                    objection,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  void _showDeleteDialog(
    ObjectionModel objection,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text(
            'Delete Objection',
            style: TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Are you sure you want to mark this objection as deleted?',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _updateStatus(
                  objection: objection,
                  status: 'deleted',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardElement,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textHelper,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
