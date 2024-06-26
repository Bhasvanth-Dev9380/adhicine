import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../profile/profile.dart';
import '../report/report.dart';
import '../add_medicine/add.dart';
import '../utils/colors.dart';
import '../firebase/firestoreservice.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomePage(),
    ReportScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            activeIcon: new Icon(Icons.home, color: primary),
            icon: new Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            activeIcon: new Icon(Icons.stacked_bar_chart, color: primary),
            backgroundColor: primary,
            icon: new Icon(Icons.stacked_bar_chart),
            label: 'Report',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMedicineScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _userDetails;
  List<Map<String, dynamic>> _medicines = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchMedicines();
  }

  Future<void> _fetchUserData() async {
    Map<String, dynamic>? userDetails = await _firestoreService.getUserDetails();
    setState(() {
      _userDetails = userDetails;
    });
  }

  Future<void> _fetchMedicines() async {
    List<Map<String, dynamic>> allMedicines = await _firestoreService.getAllMedicines();
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    List<Map<String, dynamic>> filteredMedicines = allMedicines.where((medicine) {
      DateTime startDate = DateTime.parse(medicine['startDate']);
      DateTime endDate = DateTime.parse(medicine['endDate']);
      return (startDate.isBefore(_selectedDate) && endDate.isAfter(_selectedDate)) ||
          startDate.isAtSameMomentAs(_selectedDate) || endDate.isAtSameMomentAs(_selectedDate);
    }).toList();

    setState(() {
      _medicines = filteredMedicines;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _fetchMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: _buildGreeting(),
        actions: [
          if (_userDetails != null && _userDetails!['profile_image'] != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(_userDetails!['profile_image']),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: _medicines.isEmpty
                ? _buildEmptyState()
                : _buildMedicineList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_userDetails != null && _userDetails!['name'] != null)
          Text(
            'Hi ${_userDetails!['name']}!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        Text(
          '${_medicines.length} Medicines Left',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<DateTime> weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: weekDays.map((date) {
            bool isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month && date.year == _selectedDate.year;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () {
                  _onDateSelected(date);
                },
                child: Text(
                  DateFormat('E, MMM d').format(date),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: isSelected ? Colors.grey.shade200 : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/empty_box.png', height: 150, width: 150),
          SizedBox(height: 20),
          Text(
            'Nothing Is Here, Add a Medicine',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineList() {
    final morningMeds = _medicines.where((med) => (med['doseTimes'] as List).any((dose) => (dose as Timestamp).toDate().hour < 12)).toList();
    final afternoonMeds = _medicines.where((med) => (med['doseTimes'] as List).any((dose) => (dose as Timestamp).toDate().hour >= 12 && (dose as Timestamp).toDate().hour < 18)).toList();
    final nightMeds = _medicines.where((med) => (med['doseTimes'] as List).any((dose) => (dose as Timestamp).toDate().hour >= 18)).toList();

    return ListView(
      children: [
        if (morningMeds.isNotEmpty) _buildTimeSection('Morning', morningMeds),
        if (afternoonMeds.isNotEmpty) _buildTimeSection('Afternoon', afternoonMeds),
        if (nightMeds.isNotEmpty) _buildTimeSection('Night', nightMeds),
      ],
    );
  }

  Widget _buildTimeSection(String timeOfDay, List<Map<String, dynamic>> meds) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$timeOfDay',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 10),
          ...meds.map((medicine) => _buildMedicineCard(medicine)).toList(),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    IconData icon;
    switch (medicine['type']) {
      case 'Tablet':
        icon = Icons.tablet;
        break;
      case 'Capsule':
        icon = Icons.medication;
        break;
      case 'Cream':
        icon = Icons.opacity;
        break;
      case 'Liquid':
        icon = Icons.liquor;
        break;
      default:
        icon = Icons.medical_services;
    }

    return Card(
      color: tertiary,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(medicine['color']),
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine['name'] ?? 'No Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Day ${_getDayNumber(medicine['startDate'])}',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    (medicine['foodTimings'] as List<dynamic>).join(', '),
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.alarm, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  int _getDayNumber(String startDate) {
    DateTime start = DateTime.parse(startDate);
    return _selectedDate.difference(start).inDays + 1;
  }
}
