import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Report', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodayReport(),
              SizedBox(height: 20),
              _buildDashboardCheck(),
              SizedBox(height: 20),
              _buildCheckHistory(),
              SizedBox(height: 20),
              _buildMedicineReport('Morning 08:00 am', [
                _buildMedicineTile('Calpol 500mg Tablet', 'Before Breakfast', 'Day 01', 'Taken', Colors.green),
                _buildMedicineTile('Calpol 500mg Tablet', 'Before Breakfast', 'Day 27', 'Missed', Colors.red),
              ]),
              SizedBox(height: 20),
              _buildMedicineReport('Afternoon 02:00 pm', [
                _buildMedicineTile('Calpol 500mg Tablet', 'After Food', 'Day 01', 'Snoozed', Colors.orange),
              ]),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildTodayReport() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Today\'s Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildReportColumn('5', 'Total'),
                _buildReportColumn('3', 'Taken'),
                _buildReportColumn('1', 'Missed'),
                _buildReportColumn('1', 'Snoozed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCheck() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.dashboard, color: Colors.blue),
        title: Text('Check Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Here you will find everything related to your active and past medicines.'),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () {
          // Navigate to dashboard
        },
      ),
    );
  }

  Widget _buildCheckHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Check History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildHistoryDayButton('1', true),
              _buildHistoryDayButton('2', false),
              _buildHistoryDayButton('3', false),
              _buildHistoryDayButton('4', false),
              _buildHistoryDayButton('5', false),
              _buildHistoryDayButton('6', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryDayButton(String day, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () {
          // Handle date selection logic
        },
        child: Text(
          day,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
          shape: CircleBorder(),
          padding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildMedicineReport(String time, List<Widget> medicines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ...medicines,
      ],
    );
  }

  Widget _buildMedicineTile(String name, String beforeAfter, String day, String status, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.local_hospital, color: Colors.purple),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$beforeAfter\n$day', style: TextStyle(height: 1.5)),
        trailing: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildReportColumn(String count, String label) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}
