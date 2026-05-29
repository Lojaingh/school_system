// lib/presentation/widgets/library_content.dart

import 'package:flutter/material.dart';
import 'package:school_management/constants/app_colors.dart';
import 'package:school_management/constants/app_colors.dart' as app;

class LibraryContent extends StatefulWidget {
  const LibraryContent({super.key});

  @override
  State<LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<LibraryContent> {
  int selectedTab = 0;
  String selectedCategory = 'All';
  String selectedStatus = 'All';
  String searchQuery = '';

  final List<String> categories = [
    'All',
    'Programming',
    'Mathematics',
    'Science',
    'Languages',
    'History'
  ];
  final List<String> statusList = ['All', 'Available', 'Borrowed', 'Late'];

  List<Map<String, dynamic>> books = [
    {
      'id': '1',
      'title': 'Flutter Basics',
      'author': 'Ahmed Ali',
      'isbn': '978-3-16-148410-0',
      'summary':
          'A comprehensive guide to Flutter development covering widgets, state management, and deployment.',
      'status': 'borrowed',
      'borrower': 'Mohamed Ahmed',
      'student_id': 'ST001',
      'borrowDate': '2024-06-01',
      'dueDate': '2024-06-15',
      'category': 'Programming',
    },
    {
      'id': '2',
      'title': 'Dart Advanced',
      'author': 'Sara Khaled',
      'isbn': '978-3-16-148410-1',
      'summary':
          'Deep dive into Dart language features including async, streams, and advanced OOP concepts.',
      'status': 'available',
      'borrower': null,
      'student_id': null,
      'borrowDate': null,
      'dueDate': null,
      'category': 'Programming',
    },
    {
      'id': '3',
      'title': 'Math Grade 7',
      'author': 'Nour Hasan',
      'isbn': '978-3-16-148410-2',
      'summary':
          'Grade 7 mathematics curriculum covering algebra, geometry, and statistics.',
      'status': 'late',
      'borrower': 'Lili Omar',
      'student_id': 'ST005',
      'borrowDate': '2024-05-15',
      'dueDate': '2024-05-30',
      'category': 'Mathematics',
    },
    {
      'id': '4',
      'title': 'Science Vol 1',
      'author': 'Khaled Waleed',
      'isbn': '978-3-16-148410-3',
      'summary':
          'Introduction to natural sciences including biology, chemistry, and physics fundamentals.',
      'status': 'borrowed',
      'borrower': 'Ali Mahmoud',
      'student_id': 'ST003',
      'borrowDate': '2024-05-25',
      'dueDate': '2024-06-10',
      'category': 'Science',
    },
    {
      'id': '5',
      'title': 'English Grammar',
      'author': 'Samira Noor',
      'isbn': '978-3-16-148410-4',
      'summary':
          'Complete English grammar reference with exercises and examples for intermediate learners.',
      'status': 'available',
      'borrower': null,
      'student_id': null,
      'borrowDate': null,
      'dueDate': null,
      'category': 'Languages',
    },
    {
      'id': '6',
      'title': 'History of Egypt',
      'author': 'Tamer Said',
      'isbn': '978-3-16-148410-5',
      'summary':
          'A journey through Egyptian history from ancient civilizations to modern times.',
      'status': 'available',
      'borrower': null,
      'student_id': null,
      'borrowDate': null,
      'dueDate': null,
      'category': 'History',
    },
  ];

  List<Map<String, dynamic>> members = [
    {
      'id': 'ST001',
      'name': 'Mohamed Ahmed',
      'class': 'Grade 7-A',
      'borrowedCount': 1
    },
    {
      'id': 'ST002',
      'name': 'Sara Khaled',
      'class': 'Grade 7-A',
      'borrowedCount': 0
    },
    {
      'id': 'ST003',
      'name': 'Ali Mahmoud',
      'class': 'Grade 8-B',
      'borrowedCount': 1
    },
    {
      'id': 'ST004',
      'name': 'Nour Hasan',
      'class': 'Grade 8-A',
      'borrowedCount': 0
    },
    {
      'id': 'ST005',
      'name': 'Lili Omar',
      'class': 'Grade 9-C',
      'borrowedCount': 1
    },
  ];

  List<Map<String, dynamic>> borrowingHistory = [
    {
      'id': 'H1',
      'bookTitle': 'Flutter Basics',
      'studentName': 'Mohamed Ahmed',
      'student_id': 'ST001',
      'borrowDate': '2024-06-01',
      'returnDate': null,
      'status': 'active',
      'dueDate': '2024-06-15'
    },
    {
      'id': 'H2',
      'bookTitle': 'Math Grade 7',
      'studentName': 'Lili Omar',
      'student_id': 'ST005',
      'borrowDate': '2024-05-15',
      'returnDate': null,
      'status': 'late',
      'dueDate': '2024-05-30'
    },
    {
      'id': 'H3',
      'bookTitle': 'Science Vol 1',
      'studentName': 'Ali Mahmoud',
      'student_id': 'ST003',
      'borrowDate': '2024-05-25',
      'returnDate': null,
      'status': 'active',
      'dueDate': '2024-06-10'
    },
    {
      'id': 'H4',
      'bookTitle': 'Dart Advanced',
      'studentName': 'Sara Khaled',
      'student_id': 'ST002',
      'borrowDate': '2024-05-20',
      'returnDate': '2024-06-01',
      'status': 'returned',
      'dueDate': '2024-06-03'
    },
  ];

  int get totalBooks => books.length;
  int get borrowedBooks => books.where((b) => b['status'] == 'borrowed').length;
  int get lateBooks => books.where((b) => b['status'] == 'late').length;
  int get availableBooks => totalBooks - borrowedBooks - lateBooks;

  List<Map<String, dynamic>> get filteredBooks {
    return books.where((book) {
      bool matchesSearch = searchQuery.isEmpty ||
          book['title'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          book['author'].toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesCategory =
          selectedCategory == 'All' || book['category'] == selectedCategory;
      bool matchesStatus = selectedStatus == 'All' ||
          (selectedStatus == 'Available' && book['status'] == 'available') ||
          (selectedStatus == 'Borrowed' && book['status'] == 'borrowed') ||
          (selectedStatus == 'Late' && book['status'] == 'late');
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  void _showAddBookDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Book'),
        content: const Text('Add book dialog will be implemented here.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Add')),
        ],
      ),
    );
  }

  void _showBorrowDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Borrow feature coming soon')),
    );
  }

  void _showReturnDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Return feature coming soon')),
    );
  }

  void _showAddMemberDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add member feature coming soon')),
    );
  }

  void _showBookDetails(Map<String, dynamic> book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: app.AppGradients.cardGradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(book['title'],
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text('By: ${book['author']}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            if (book['summary'] != null)
              Text(book['summary'],
                  style: const TextStyle(color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Library Management',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Manage books, borrowing, and members',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          _StatsRow(
              totalBooks: totalBooks,
              borrowedBooks: borrowedBooks,
              availableBooks: availableBooks,
              lateBooks: lateBooks),
          const SizedBox(height: 24),
          _SearchAndAddRow(
            searchQuery: searchQuery,
            onSearchChanged: (value) => setState(() => searchQuery = value),
            onAddBook: _showAddBookDialog,
            onAddMember: _showAddMemberDialog,
          ),
          const SizedBox(height: 16),
          _TabBar(
              selectedTab: selectedTab,
              onTabChanged: (index) => setState(() => selectedTab = index)),
          const SizedBox(height: 16),
          if (selectedTab == 0 || selectedTab == 1)
            _FilterRow(
              selectedCategory: selectedCategory,
              selectedStatus: selectedStatus,
              categories: categories,
              statusList: statusList,
              onCategoryChanged: (value) =>
                  setState(() => selectedCategory = value),
              onStatusChanged: (value) =>
                  setState(() => selectedStatus = value),
            ),
          const SizedBox(height: 16),
          _buildTabContent(),
          const SizedBox(height: 16),
          _QuickActionsBar(
            onBorrow: _showBorrowDialog,
            onReturn: _showReturnDialog,
            onAddMember: _showAddMemberDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 0:
        return _BooksTable(books: filteredBooks, onTap: _showBookDetails);
      case 1:
        return _BorrowedTable(
            borrowed: borrowingHistory
                .where((h) => h['status'] == 'active' || h['status'] == 'late')
                .toList());
      case 2:
        return _ReturnsTable(
            returns: borrowingHistory
                .where((h) => h['status'] == 'returned')
                .toList());
      case 3:
        return _MembersTable(members: members);
      case 4:
        return _ReportsTab(
          totalBooks: totalBooks,
          borrowedBooks: borrowedBooks,
          availableBooks: availableBooks,
          lateBooks: lateBooks,
          membersCount: members.length,
          activeBorrowings:
              borrowingHistory.where((h) => h['status'] == 'active').length,
        );
      default:
        return const SizedBox();
    }
  }
}

// ==================== STATS ROW ====================
class _StatsRow extends StatelessWidget {
  final int totalBooks, borrowedBooks, availableBooks, lateBooks;
  const _StatsRow(
      {required this.totalBooks,
      required this.borrowedBooks,
      required this.availableBooks,
      required this.lateBooks});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StatCard(
          title: 'Total Books',
          value: '$totalBooks',
          icon: Icons.menu_book_rounded,
          color: AppColors.cardBlue,
          change: 'In Library'),
      const SizedBox(width: 12),
      _StatCard(
          title: 'Borrowed',
          value: '$borrowedBooks',
          icon: Icons.book_rounded,
          color: AppColors.cardOrange,
          change: 'Currently Out'),
      const SizedBox(width: 12),
      _StatCard(
          title: 'Available',
          value: '$availableBooks',
          icon: Icons.check_circle_rounded,
          color: AppColors.cardGreen,
          change: 'Ready to Borrow'),
      const SizedBox(width: 12),
      _StatCard(
          title: 'Late',
          value: '$lateBooks',
          icon: Icons.warning_rounded,
          color: AppColors.error,
          change: 'Overdue'),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, change;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color,
      required this.change});

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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 14, color: color)),
            ]),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(change,
                style: const TextStyle(
                    fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ==================== SEARCH AND ADD ROW ====================
class _SearchAndAddRow extends StatelessWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onAddBook, onAddMember;
  const _SearchAndAddRow(
      {required this.searchQuery,
      required this.onSearchChanged,
      required this.onAddBook,
      required this.onAddMember});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            gradient: app.AppGradients.cardGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder.withOpacity(0.3)),
          ),
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Search by title, author...',
              hintStyle:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13),
              prefixIcon:
                  Icon(Icons.search, size: 20, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      _ActionIconButton(
          icon: Icons.add_rounded,
          label: 'Book',
          color: AppColors.cardBlue,
          onTap: onAddBook),
      const SizedBox(width: 8),
      _ActionIconButton(
          icon: Icons.people_rounded,
          label: 'Member',
          color: AppColors.cardGreen,
          onTap: onAddMember),
    ]);
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionIconButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: app.AppGradients.cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ]),
      ),
    );
  }
}

// ==================== TAB BAR ====================
class _TabBar extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;
  const _TabBar({required this.selectedTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      '📚 Books',
      '📖 Borrowed',
      '🔄 Returns',
      '👥 Members',
      '📊 Reports'
    ];
    return Container(
      decoration: BoxDecoration(
          color: AppColors.cardBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key,
              label = entry.value,
              isSelected = selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    gradient:
                        isSelected ? app.AppGradients.primaryGradient : null,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==================== FILTER ROW ====================
class _FilterRow extends StatelessWidget {
  final String selectedCategory, selectedStatus;
  final List<String> categories, statusList;
  final Function(String) onCategoryChanged, onStatusChanged;
  const _FilterRow(
      {required this.selectedCategory,
      required this.selectedStatus,
      required this.categories,
      required this.statusList,
      required this.onCategoryChanged,
      required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        const Text('Category:',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        ...categories.map((cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat,
                    style: TextStyle(
                        fontSize: 11,
                        color: selectedCategory == cat
                            ? Colors.white
                            : AppColors.textSecondary)),
                selected: selectedCategory == cat,
                onSelected: (_) => onCategoryChanged(cat),
                backgroundColor: Colors.transparent,
                selectedColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: AppColors.cardBorder.withOpacity(0.5))),
              ),
            )),
        const SizedBox(width: 16),
        const Text('Status:',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        ...statusList.map((status) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(status,
                    style: TextStyle(
                        fontSize: 11,
                        color: selectedStatus == status
                            ? Colors.white
                            : AppColors.textSecondary)),
                selected: selectedStatus == status,
                onSelected: (_) => onStatusChanged(status),
                backgroundColor: Colors.transparent,
                selectedColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: AppColors.cardBorder.withOpacity(0.5))),
              ),
            )),
      ]),
    );
  }
}

// ==================== BOOKS TABLE ====================
class _BooksTable extends StatelessWidget {
  final List<Map<String, dynamic>> books;
  final Function(Map<String, dynamic>) onTap;
  const _BooksTable({required this.books, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const Center(
          child: Text('No books found',
              style: TextStyle(color: AppColors.textSecondary)));
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
          gradient: app.AppGradients.cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.cardShadow),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: AppColors.cardBorder.withOpacity(0.3)))),
          child: const Row(children: [
            SizedBox(width: 48),
            Expanded(
                flex: 2,
                child: Text('Title',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Author',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Status',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Borrower',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Due Date',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Actions',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          ]),
        ),
        ...books.map((book) => _BookRow(book: book, onTap: onTap)),
      ]),
    );
  }
}

class _BookRow extends StatelessWidget {
  final Map<String, dynamic> book;
  final Function(Map<String, dynamic>) onTap;
  const _BookRow({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    switch (book['status']) {
      case 'available':
        statusColor = AppColors.cardGreen;
        statusText = 'Available';
        break;
      case 'borrowed':
        statusColor = AppColors.cardOrange;
        statusText = 'Borrowed';
        break;
      case 'late':
        statusColor = AppColors.error;
        statusText = 'Late';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = book['status'];
    }
    return InkWell(
      onTap: () => onTap(book),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border(
                bottom:
                    BorderSide(color: AppColors.cardBorder.withOpacity(0.1)))),
        child: Row(children: [
          SizedBox(
              width: 48,
              child: Icon(Icons.menu_book_rounded, color: AppColors.cardBlue)),
          Expanded(
              flex: 2,
              child: Text(book['title'],
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary))),
          Expanded(
              flex: 1,
              child: Text(book['author'],
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(statusText,
                    style: TextStyle(fontSize: 11, color: statusColor),
                    textAlign: TextAlign.center),
              )),
          Expanded(
              flex: 1,
              child: Text(book['borrower'] ?? '-',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
              flex: 1,
              child: Text(book['dueDate'] ?? '-',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
              flex: 1,
              child: Row(children: [
                IconButton(
                    icon: const Icon(Icons.info_outline_rounded, size: 18),
                    color: AppColors.cardBlue,
                    onPressed: () => onTap(book)),
                IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    color: AppColors.textSecondary,
                    onPressed: () {}),
              ])),
        ]),
      ),
    );
  }
}

// ==================== BORROWED TABLE ====================
class _BorrowedTable extends StatelessWidget {
  final List<Map<String, dynamic>> borrowed;
  const _BorrowedTable({required this.borrowed});

  @override
  Widget build(BuildContext context) {
    if (borrowed.isEmpty) {
      return const Center(
          child: Text('No active borrowings',
              style: TextStyle(color: AppColors.textSecondary)));
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
          gradient: app.AppGradients.cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.cardShadow),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: AppColors.cardBorder.withOpacity(0.3)))),
          child: const Row(children: [
            Expanded(
                flex: 2,
                child: Text('Book',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Student',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Borrow Date',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Due Date',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Status',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          ]),
        ),
        ...borrowed.map((item) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppColors.cardBorder.withOpacity(0.1)))),
              child: Row(children: [
                Expanded(
                    flex: 2,
                    child: Text(item['bookTitle'],
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textPrimary))),
                Expanded(
                    flex: 1,
                    child: Text(item['studentName'],
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary))),
                Expanded(
                    flex: 1,
                    child: Text(item['borrowDate'],
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary))),
                Expanded(
                    flex: 1,
                    child: Text(item['dueDate'] ?? '-',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary))),
                Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                          color: (item['status'] == 'late'
                                  ? AppColors.error
                                  : AppColors.cardOrange)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(item['status'] == 'late' ? 'Late' : 'Active',
                          style: TextStyle(
                              fontSize: 11,
                              color: item['status'] == 'late'
                                  ? AppColors.error
                                  : AppColors.cardOrange),
                          textAlign: TextAlign.center),
                    )),
              ]),
            )),
      ]),
    );
  }
}

// ==================== RETURNS TABLE ====================
class _ReturnsTable extends StatelessWidget {
  final List<Map<String, dynamic>> returns;
  const _ReturnsTable({required this.returns});

  @override
  Widget build(BuildContext context) {
    if (returns.isEmpty) {
      return const Center(
          child: Text('No return history',
              style: TextStyle(color: AppColors.textSecondary)));
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
          gradient: app.AppGradients.cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.cardShadow),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: AppColors.cardBorder.withOpacity(0.3)))),
          child: const Row(children: [
            Expanded(
                flex: 2,
                child: Text('Book',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Student',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Borrow Date',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Return Date',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          ]),
        ),
        ...returns.map((item) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppColors.cardBorder.withOpacity(0.1)))),
              child: Row(children: [
                Expanded(
                    flex: 2,
                    child: Text(item['bookTitle'],
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textPrimary))),
                Expanded(
                    flex: 1,
                    child: Text(item['studentName'],
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary))),
                Expanded(
                    flex: 1,
                    child: Text(item['borrowDate'],
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary))),
                Expanded(
                    flex: 1,
                    child: Text(item['returnDate'] ?? '-',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.cardGreen))),
              ]),
            )),
      ]),
    );
  }
}

// ==================== MEMBERS TABLE ====================
class _MembersTable extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  const _MembersTable({required this.members});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Center(
          child: Text('No members found',
              style: TextStyle(color: AppColors.textSecondary)));
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
          gradient: app.AppGradients.cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.cardShadow),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: AppColors.cardBorder.withOpacity(0.3)))),
          child: const Row(children: [
            Expanded(
                flex: 2,
                child: Text('Name',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Student ID',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Class',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Expanded(
                flex: 1,
                child: Text('Borrowed',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          ]),
        ),
        ...members.map((member) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppColors.cardBorder.withOpacity(0.1)))),
              child: Row(children: [
                Expanded(
                    flex: 2,
                    child: Text(member['name'],
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textPrimary))),
                Expanded(
                    flex: 1,
                    child: Text(member['id'],
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.cardBlue))),
                Expanded(
                    flex: 1,
                    child: Text(member['class'],
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary))),
                Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: (member['borrowedCount'] > 0
                                  ? AppColors.cardOrange
                                  : AppColors.cardGreen)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                          '${member['borrowedCount']} book${member['borrowedCount'] != 1 ? 's' : ''}',
                          style: TextStyle(
                              fontSize: 11,
                              color: member['borrowedCount'] > 0
                                  ? AppColors.cardOrange
                                  : AppColors.cardGreen)),
                    )),
              ]),
            )),
      ]),
    );
  }
}

// ==================== REPORTS TAB ====================
class _ReportsTab extends StatelessWidget {
  final int totalBooks,
      borrowedBooks,
      availableBooks,
      lateBooks,
      membersCount,
      activeBorrowings;
  const _ReportsTab({
    required this.totalBooks,
    required this.borrowedBooks,
    required this.availableBooks,
    required this.lateBooks,
    required this.membersCount,
    required this.activeBorrowings,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Row(children: [
          _ReportCard(
              title: 'Total Books',
              value: '$totalBooks',
              icon: Icons.menu_book_rounded,
              color: AppColors.cardBlue),
          const SizedBox(width: 12),
          _ReportCard(
              title: 'Members',
              value: '$membersCount',
              icon: Icons.people_rounded,
              color: AppColors.cardGreen),
          const SizedBox(width: 12),
          _ReportCard(
              title: 'Active Loans',
              value: '$activeBorrowings',
              icon: Icons.book_rounded,
              color: AppColors.cardOrange),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: app.AppGradients.cardGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.cardShadow),
          child: Column(children: [
            const Text('Books Status Distribution',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Row(children: [
              _StatusBar(
                  label: 'Available',
                  value: availableBooks,
                  total: totalBooks,
                  color: AppColors.cardGreen),
              const SizedBox(width: 8),
              _StatusBar(
                  label: 'Borrowed',
                  value: borrowedBooks,
                  total: totalBooks,
                  color: AppColors.cardOrange),
              const SizedBox(width: 8),
              _StatusBar(
                  label: 'Late',
                  value: lateBooks,
                  total: totalBooks,
                  color: AppColors.error),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
        Center(
            child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_rounded),
          label: const Text('Export Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        )),
      ]),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _ReportCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: app.AppGradients.cardGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.cardShadow),
        child: Column(children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String label;
  final int value, total;
  final Color color;
  const _StatusBar(
      {required this.label,
      required this.value,
      required this.total,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (value / total) : 0.0;
    return Expanded(
      child: Column(children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
            height: 8,
            decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4))))),
        const SizedBox(height: 4),
        Text('$value / $total', style: TextStyle(fontSize: 11, color: color)),
      ]),
    );
  }
}

// ==================== QUICK ACTIONS BAR ====================
class _QuickActionsBar extends StatelessWidget {
  final VoidCallback onBorrow, onReturn, onAddMember;
  const _QuickActionsBar(
      {required this.onBorrow,
      required this.onReturn,
      required this.onAddMember});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(children: [
        _QuickActionButton(
            label: 'Borrow Book',
            icon: Icons.book_rounded,
            color: AppColors.cardOrange,
            onTap: onBorrow),
        const SizedBox(width: 12),
        _QuickActionButton(
            label: 'Return Book',
            icon: Icons.replay_rounded,
            color: AppColors.cardGreen,
            onTap: onReturn),
        const SizedBox(width: 12),
        _QuickActionButton(
            label: 'Add Member',
            icon: Icons.person_add_rounded,
            color: AppColors.cardBlue,
            onTap: onAddMember),
        const SizedBox(width: 12),
        _QuickActionButton(
            label: 'Generate Report',
            icon: Icons.bar_chart_rounded,
            color: AppColors.cardPurple,
            onTap: () {}),
      ]),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: app.AppGradients.cardGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ]),
        ),
      ),
    );
  }
}

// ==================== SHADOWS ====================
class AppShadows {
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
        color: Color(0x336C4CF1),
        blurRadius: 20,
        spreadRadius: 0,
        offset: Offset(0, 8)),
  ];
}
