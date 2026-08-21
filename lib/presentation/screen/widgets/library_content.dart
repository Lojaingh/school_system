import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/constants/app_colors.dart' as app;
import 'package:school_management/cubit/library/book_cubit.dart';
import 'package:school_management/data/model/book_model.dart';
import 'package:school_management/data/model/lending_model.dart';

class LibraryContent extends StatefulWidget {
  const LibraryContent({super.key});

  @override
  State<LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<LibraryContent> {
  int selectedTab = 0;

  String selectedStatus = 'All';
  String searchQuery = '';

  late Future<List<Lending>> _lendingsFuture;
  List<Lending> _cachedLendings = [];

  final List<String> statusList = [
    'All',
    'Available',
    'Borrowed',
    'Late',
  ];

  @override
  void initState() {
    super.initState();

    context.read<BookCubit>().refreshBooks();

    _loadLendings();
  }

  void _loadLendings() {
    final future = context.read<BookCubit>().getLendings();

    setState(() {
      _lendingsFuture = future;
    });

    future.then((data) {
      if (mounted) {
        setState(() {
          _cachedLendings = data;
        });
      }
    }).catchError((_) {});
  }

  void _refreshLendings() {
    _loadLendings();
  }

  void _showAddBookDialog() {
    final titleController = TextEditingController();
    final summaryController = TextEditingController();
    final categoryController = TextEditingController();
    final pagesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Add Book',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                titleController,
                'Title',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                summaryController,
                'Summary',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                categoryController,
                'Category',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                pagesController,
                'Pages',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final summary = summaryController.text.trim();
              final category = categoryController.text.trim();
              final pages = int.tryParse(
                pagesController.text.trim(),
              );

              if (title.isEmpty ||
                  summary.isEmpty ||
                  category.isEmpty ||
                  pages == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields correctly'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              context.read<BookCubit>().addBook(
                    title: title,
                    summary: summary,
                    category: category,
                    pages: pages,
                  );

              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  //

  void _showBorrowDialog(Book book) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Borrow Book',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to borrow "${book.title}"?',
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await context.read<BookCubit>().lendBook(book.id);

                // تحديث الكتب والاستعارات
                context.read<BookCubit>().refreshBooks();

                if (mounted) {
                  _refreshLendings();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Book borrowed successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: $e',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cardOrange,
            ),
            child: const Text('Borrow'),
          ),
        ],
      ),
    );
  }

  void _showReturnDialog(Lending lending) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Return Book',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to return "${lending.book.title}"?',
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await context.read<BookCubit>().returnBook(
                      lending.id,
                    );

                context.read<BookCubit>().refreshBooks();

                if (mounted) {
                  _refreshLendings();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Book returned successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: $e',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cardGreen,
            ),
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }

  void _showBookDetails(Book book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: app.AppGradients.cardGradient,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${book.category}',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pages: ${book.pages}',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              book.summary,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: book.isAvailable
                        ? AppColors.cardGreen.withOpacity(0.15)
                        : AppColors.cardOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    book.isAvailable ? 'Available' : 'Borrowed',
                    style: TextStyle(
                      color: book.isAvailable
                          ? AppColors.cardGreen
                          : AppColors.cardOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (!book.isAvailable)
                  FutureBuilder<List<Lending>>(
                    future: _lendingsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }

                      Lending? lending;

                      for (final item in snapshot.data!) {
                        if (item.book.id == book.id && !item.isReturned) {
                          lending = item;
                          break;
                        }
                      }

                      if (lending == null) {
                        return const SizedBox();
                      }

                      return TextButton.icon(
                        onPressed: () {
                          Navigator.pop(bottomSheetContext);
                          _showReturnDialog(lending!);
                        },
                        icon: const Icon(
                          Icons.replay_rounded,
                        ),
                        label: const Text('Return'),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                  bottomSheetContext,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Build ====================

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookCubit, BookState>(
      listener: (context, state) {
        if (state is BookError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${state.message}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Library Management',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage books, borrowing, and returns',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<BookCubit, BookState>(
              builder: (context, state) {
                if (state is! BooksLoaded) {
                  return const _StatsRow(
                    totalBooks: 0,
                    borrowedBooks: 0,
                    availableBooks: 0,
                    lateBooks: 0,
                  );
                }

                final books = state.books;

                final totalBooks = books.length;

                final availableBooks =
                    books.where((book) => book.isAvailable).length;

                final borrowedBooks =
                    books.where((book) => !book.isAvailable).length;

                return FutureBuilder<List<Lending>>(
                  future: _lendingsFuture,
                  builder: (context, snapshot) {
                    int lateBooks = 0;

                    if (snapshot.hasData) {
                      lateBooks = snapshot.data!
                          .where(
                            (lending) => !lending.isReturned && lending.isLate,
                          )
                          .length;
                    }

                    return _StatsRow(
                      totalBooks: totalBooks,
                      borrowedBooks: borrowedBooks,
                      availableBooks: availableBooks,
                      lateBooks: lateBooks,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            _SearchAndAddRow(
              searchQuery: searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              onAddBook: _showAddBookDialog,
            ),
            const SizedBox(height: 16),
            _TabBar(
              selectedTab: selectedTab,
              onTabChanged: (index) {
                setState(() {
                  selectedTab = index;
                });
              },
            ),
            const SizedBox(height: 16),
            if (selectedTab == 0)
              _FilterRow(
                selectedStatus: selectedStatus,
                statusList: statusList,
                onStatusChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),
            const SizedBox(height: 16),
            _buildTabContent(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return BlocBuilder<BookCubit, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is BookError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookCubit>().refreshBooks();

                      _refreshLendings();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! BooksLoaded) {
          return const SizedBox();
        }

        final books = state.books;

        switch (selectedTab) {
          case 0:
            return _buildBooksTab(books);

          case 1:
            return _buildBorrowedTab();

          case 2:
            return _buildReturnedTab();

          default:
            return const SizedBox();
        }
      },
    );
  }

  Widget _buildBooksTab(List<Book> books) {
    final filteredBooks = books.where((book) {
      final matchesSearch = searchQuery.isEmpty ||
          book.title.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus = selectedStatus == 'All' ||
          (selectedStatus == 'Available' && book.isAvailable) ||
          (selectedStatus == 'Borrowed' && !book.isAvailable) ||
          (selectedStatus == 'Late' && _isBookLate(book));

      return matchesSearch && matchesStatus;
    }).toList();

    if (filteredBooks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No books found',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return _BooksTable(
      books: filteredBooks,
      onTap: _showBookDetails,
      onBorrow: (book) {
        if (book.isAvailable) {
          _showBorrowDialog(book);
        }
      },
      isLate: _isBookLate,
    );
  }

  Widget _buildBorrowedTab() {
    return FutureBuilder<List<Lending>>(
      future: _lendingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          );
        }

        final lendings = snapshot.data ?? [];

        final activeLendings =
            lendings.where((lending) => !lending.isReturned).toList();

        if (activeLendings.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No active borrowings',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return _LendingsTable(
          lendings: activeLendings,
          onReturn: _showReturnDialog,
        );
      },
    );
  }

  Widget _buildReturnedTab() {
    return FutureBuilder<List<Lending>>(
      future: _lendingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          );
        }

        final lendings = snapshot.data ?? [];

        final returnedLendings =
            lendings.where((lending) => lending.isReturned).toList();

        if (returnedLendings.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No return history',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return _LendingsTable(
          lendings: returnedLendings,
          onReturn: null,
        );
      },
    );
  }

  bool _isBookLate(Book book) {
    if (book.isAvailable) {
      return false;
    }

    return _cachedLendings.any(
      (lending) =>
          lending.book.id == book.id && !lending.isReturned && lending.isLate,
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalBooks;
  final int borrowedBooks;
  final int availableBooks;
  final int lateBooks;

  const _StatsRow({
    required this.totalBooks,
    required this.borrowedBooks,
    required this.availableBooks,
    required this.lateBooks,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          title: 'Total Books',
          value: '$totalBooks',
          icon: Icons.menu_book_rounded,
          color: AppColors.cardBlue,
          change: 'In Library',
        ),
        const SizedBox(width: 12),
        _StatCard(
          title: 'Borrowed',
          value: '$borrowedBooks',
          icon: Icons.book_rounded,
          color: AppColors.cardOrange,
          change: 'Currently Out',
        ),
        const SizedBox(width: 12),
        _StatCard(
          title: 'Available',
          value: '$availableBooks',
          icon: Icons.check_circle_rounded,
          color: AppColors.cardGreen,
          change: 'Ready to Borrow',
        ),
        const SizedBox(width: 12),
        _StatCard(
          title: 'Late',
          value: '$lateBooks',
          icon: Icons.warning_rounded,
          color: AppColors.error,
          change: 'Overdue',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: app.AppGradients.cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              change,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAndAddRow extends StatelessWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onAddBook;

  const _SearchAndAddRow({
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onAddBook,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              gradient: app.AppGradients.cardGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.cardBorder.withOpacity(0.3),
              ),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Search by title...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _ActionIconButton(
          icon: Icons.add_rounded,
          label: 'Book',
          color: AppColors.cardBlue,
          onTap: onAddBook,
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: app.AppGradients.cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;

  const _TabBar({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      '📚 Books',
      '📖 Borrowed',
      '🔄 Returns',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;

          final isSelected = selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient:
                      isSelected ? app.AppGradients.primaryGradient : null,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String selectedStatus;
  final List<String> statusList;
  final Function(String) onStatusChanged;

  const _FilterRow({
    required this.selectedStatus,
    required this.statusList,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Text(
            'Status:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          ...statusList.map(
            (status) => Padding(
              padding: const EdgeInsets.only(
                right: 8,
              ),
              child: FilterChip(
                label: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: selectedStatus == status
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
                selected: selectedStatus == status,
                onSelected: (_) => onStatusChanged(
                  status,
                ),
                backgroundColor: Colors.transparent,
                selectedColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                  side: BorderSide(
                    color: AppColors.cardBorder.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BooksTable extends StatelessWidget {
  final List<Book> books;
  final Function(Book) onTap;
  final Function(Book) onBorrow;
  final bool Function(Book) isLate;

  const _BooksTable({
    required this.books,
    required this.onTap,
    required this.onBorrow,
    required this.isLate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.cardBorder.withOpacity(0.3),
                ),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 48),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Title',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...books.map(
            (book) => _BookRow(
              book: book,
              onTap: onTap,
              onBorrow: onBorrow,
              isLate: isLate(book),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  final Book book;
  final Function(Book) onTap;
  final Function(Book) onBorrow;
  final bool isLate;

  const _BookRow({
    required this.book,
    required this.onTap,
    required this.onBorrow,
    required this.isLate,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (book.isAvailable) {
      statusColor = AppColors.cardGreen;
      statusText = 'Available';
    } else if (isLate) {
      statusColor = AppColors.error;
      statusText = 'Late';
    } else {
      statusColor = AppColors.cardOrange;
      statusText = 'Borrowed';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.cardBorder.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.cardBlue,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              book.title,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              book.category,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                  ),
                  color: AppColors.cardBlue,
                  onPressed: () => onTap(book),
                ),
                if (book.isAvailable)
                  IconButton(
                    icon: const Icon(
                      Icons.book_rounded,
                      size: 18,
                    ),
                    color: AppColors.cardOrange,
                    onPressed: () => onBorrow(book),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LendingsTable extends StatelessWidget {
  final List<Lending> lendings;
  final void Function(Lending)? onReturn;

  const _LendingsTable({
    required this.lendings,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        gradient: app.AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.cardBorder.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Book',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Borrow Date',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Due Date',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (onReturn != null)
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'Action',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ...lendings.map(
            (lending) => _LendingRow(
              lending: lending,
              onReturn: onReturn,
            ),
          ),
        ],
      ),
    );
  }
}

class _LendingRow extends StatelessWidget {
  final Lending lending;
  final void Function(Lending)? onReturn;

  const _LendingRow({
    required this.lending,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLate = lending.isLate && !lending.isReturned;

    final Color statusColor;
    final String statusText;

    if (lending.isReturned) {
      statusColor = AppColors.cardGreen;
      statusText = 'Returned';
    } else if (isLate) {
      statusColor = AppColors.error;
      statusText = 'Late';
    } else {
      statusColor = AppColors.cardOrange;
      statusText = 'Active';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.cardBorder.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              lending.book.title,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              lending.borrowDate,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lending.book.dueDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLate ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
                if (_computeDueStatus(lending) != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _computeDueStatus(lending)!.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _computeDueStatus(lending)!.color,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (onReturn != null)
            Expanded(
              flex: 1,
              child: IconButton(
                icon: const Icon(
                  Icons.replay_rounded,
                  size: 18,
                ),
                color: AppColors.cardGreen,
                onPressed: () => onReturn!(lending),
              ),
            ),
        ],
      ),
    );
  }
}

class _DueStatus {
  final String label;
  final Color color;

  const _DueStatus(this.label, this.color);
}

_DueStatus? _computeDueStatus(Lending lending) {
  if (lending.isReturned) return null;

  final dueDate = DateTime.tryParse(lending.book.dueDate);
  if (dueDate == null) return null;

  final today = DateTime.now();
  final todayDateOnly = DateTime(today.year, today.month, today.day);
  final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

  final diffDays = dueDateOnly.difference(todayDateOnly).inDays;

  if (diffDays < 0) {
    final overdueBy = -diffDays;
    return _DueStatus(
      'Overdue by $overdueBy day${overdueBy == 1 ? '' : 's'}',
      AppColors.error,
    );
  } else if (diffDays == 0) {
    return const _DueStatus('Due today', AppColors.warning);
  } else {
    return _DueStatus(
      '$diffDays day${diffDays == 1 ? '' : 's'} left',
      diffDays <= 2 ? AppColors.warning : AppColors.cardGreen,
    );
  }
}

class AppShadows {
  static final List<BoxShadow> cardShadow = [
    const BoxShadow(
      color: Color(0x336C4CF1),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];
}
