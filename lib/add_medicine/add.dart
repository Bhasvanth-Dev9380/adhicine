import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase/firebase.dart';
import '../notifications.dart'; // Make sure to import your firebase service

class AddMedicineScreen extends StatefulWidget {
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  int _compartment = 1;
  double _quantity = 1;
  int _totalCount = 10;
  String _selectedFrequency = 'Everyday';
  String _selectedTimes = 'Three Times';
  String _selectedType = 'Tablet';
  String _selectedStartDate = 'Select Start Date';
  String _selectedEndDate = 'Select End Date';
  List<String> _foodTimings = ['Before Food', 'After Food', 'Before Sleep'];
  List<String> _selectedFoodTimings = [];
  List<DateTime> _doseTimes = [];
  List<String> _medicineNames = ['Paracetamol', 'Ibuprofen', 'Amoxicillin', 'Metformin', 'Atorvastatin'];
  List<String> _filteredMedicineNames = [];
  String _selectedMedicineName = '';
  Color _selectedColor = Colors.purple;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: 'Take 1 Pill');
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredMedicineNames = List.from(_medicineNames);
  }

  Future<void> sendNotification(String title, String body) async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    final token = await messaging.getToken();
    if (token != null) {
      try {
        await FirebaseFirestore.instance.collection('notifications').add({
          'token': token,
          'title': title,
          'body': body,
        });
        print('Notification sent to token: $token');
      } catch (e) {
        print('Error sending notification: $e');
      }
    } else {
      print('Failed to get FCM token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Add Medicines',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              if (_isSearching) _buildMedicineList(),
              SizedBox(height: 20),
              _buildCompartmentSelector(),
              SizedBox(height: 20),
              _buildColorSelector(),
              SizedBox(height: 20),
              _buildTypeSelector(),
              SizedBox(height: 20),
              _buildQuantitySelector(),
              SizedBox(height: 20),
              _buildTotalCountSlider(),
              SizedBox(height: 20),
              _buildDateSelector(),
              SizedBox(height: 20),
              _buildFrequencySelector(),
              SizedBox(height: 20),
              _buildTimesSelector(),
              SizedBox(height: 20),
              _buildDoseSelector(),
              SizedBox(height: 20),
              _buildFoodTimingSelector(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Save the selected medicine name
                    if (_selectedMedicineName.isNotEmpty) {
                      FirestoreService firestoreService = FirestoreService();
                      await firestoreService.addMedicine(
                        _selectedMedicineName,
                        _compartment,
                        _selectedColor,
                        _selectedType,
                        _quantity,
                        _totalCount,
                        _selectedStartDate,
                        _selectedEndDate,
                        _selectedFrequency,
                        _selectedTimes,
                        _doseTimes.map((dt) => Timestamp.fromDate(dt)).toList(),
                        _selectedFoodTimings,
                      );

                      NotificationService notificationService = NotificationService();
                      notificationService.showNotification(
                        0,
                        'Medicine Added',
                        'You have successfully added $_selectedMedicineName',
                      );

                      // Schedule notifications for dose times
                      for (DateTime doseTime in _doseTimes) {
                        notificationService.scheduleNotification(
                          doseTime.hashCode,
                          'Time to take your medicine',
                          'It\'s time to take $_selectedMedicineName',
                          doseTime,
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Medicine added successfully')),
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a medicine name')),
                      );
                    }
                  },
                  child: Text('Add', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6F8BEF),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search Medicine Name',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _filteredMedicineNames = _medicineNames
              .where((name) => name.toLowerCase().contains(value.toLowerCase()))
              .toList();
        });
      },
      onTap: () {
        setState(() {
          _isSearching = true;
          _filteredMedicineNames = List.from(_medicineNames);
        });
      },
    );
  }

  Widget _buildMedicineList() {
    return Container(
      height: 100,
      child: ListView.builder(
        itemCount: _filteredMedicineNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_filteredMedicineNames[index]),
            onTap: () {
              setState(() {
                _selectedMedicineName = _filteredMedicineNames[index];
                _searchController.text = _selectedMedicineName;
                _isSearching = false;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCompartmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compartment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return _buildCompartmentButton(index + 1);
          }),
        ),
      ],
    );
  }

  Widget _buildCompartmentButton(int compartment) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _compartment = compartment;
        });
      },
      child: CircleAvatar(
        backgroundColor: _compartment == compartment ? Color(0xFF6F8BEF) : Colors.grey.shade200,
        child: Text(
          compartment.toString(),
          style: TextStyle(color: _compartment == compartment ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Colour', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildColorCircle(Colors.purple),
            _buildColorCircle(Colors.purple.shade200),
            _buildColorCircle(Colors.red),
            _buildColorCircle(Colors.green),
            _buildColorCircle(Colors.orange),
            _buildColorCircle(Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 20,
        child: _selectedColor == color ? Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTypeButton('Tablet', Icons.tablet),
            _buildTypeButton('Capsule', Icons.medication),
            _buildTypeButton('Cream', Icons.opacity),
            _buildTypeButton('Liquid', Icons.liquor),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(String type, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: _selectedType == type ? Color(0xFF6F8BEF) : Colors.grey.shade200,
            child: Icon(icon, color: _selectedType == type ? Colors.white : Colors.black),
          ),
          SizedBox(height: 5),
          Text(type, style: TextStyle(color: _selectedType == type ? Color(0xFF6F8BEF) : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  hintText: 'Take 1 Pill',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (_quantity == 2) {
                    _quantity = 1;
                    _quantityController.text = 'Take 1 Pill';
                  } else if (_quantity == 1) {
                    _quantity = 0.5;
                    _quantityController.text = 'Take 1/2 Pill';
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  if (_quantity == 0.5) {
                    _quantity = 1;
                    _quantityController.text = 'Take 1 Pill';
                  } else if (_quantity == 1) {
                    _quantity = 2;
                    _quantityController.text = 'Take 2 Pills';
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalCountSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total Count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Slider(
          value: _totalCount.toDouble(),
          min: 1,
          max: 100,
          divisions: 100,
          label: _totalCount.toString(),
          onChanged: (double value) {
            setState(() {
              _totalCount = value.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDateButton('Start Date', true),
            _buildDateButton('End Date', false),
          ],
        ),
      ],
    );
  }

  Widget _buildDateButton(String label, bool isStartDate) {
    return OutlinedButton(
      onPressed: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          setState(() {
            if (isStartDate) {
              _selectedStartDate = formattedDate;
            } else {
              _selectedEndDate = formattedDate;
            }
          });
        }
      },
      child: Text(isStartDate ? _selectedStartDate : _selectedEndDate),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequency of Days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        DropdownButton<String>(
          value: _selectedFrequency,
          onChanged: (String? newValue) {
            setState(() {
              _selectedFrequency = newValue!;
            });
          },
          items: <String>['Everyday', 'Alternate Days', 'Once a Week']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How many times a Day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        DropdownButton<String>(
          value: _selectedTimes,
          onChanged: (String? newValue) {
            setState(() {
              _selectedTimes = newValue!;
              _updateDoseTimes(newValue);
            });
          },
          items: <String>['One Time', 'Two Times', 'Three Times', 'Four Times']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _updateDoseTimes(String times) {
    setState(() {
      if (times == 'One Time') {
        _doseTimes = [DateTime.now()];
      } else if (times == 'Two Times') {
        _doseTimes = [DateTime.now(), DateTime.now()];
      } else if (times == 'Three Times') {
        _doseTimes = [DateTime.now(), DateTime.now(), DateTime.now()];
      } else if (times == 'Four Times') {
        _doseTimes = [DateTime.now(), DateTime.now(), DateTime.now(), DateTime.now()];
      }
    });
  }

  Widget _buildDoseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _doseTimes.map((dose) {
        return _buildDoseTimeSelector(dose);
      }).toList(),
    );
  }

  Widget _buildDoseTimeSelector(DateTime dose) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Dose', style: TextStyle(fontSize: 16)),
        TextButton(
          onPressed: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(dose),
            );

            if (pickedTime != null) {
              setState(() {
                int index = _doseTimes.indexOf(dose);
                _doseTimes[index] = DateTime(
                  dose.year,
                  dose.month,
                  dose.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
              });
            }
          },
          child: Text(DateFormat('hh:mm a').format(dose)),
        ),
      ],
    );
  }

  Widget _buildFoodTimingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Food Timing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _foodTimings.map((timing) {
            return _buildFoodTimingButton(timing);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFoodTimingButton(String timing) {
    bool isSelected = _selectedFoodTimings.contains(timing);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedFoodTimings.remove(timing);
          } else {
            _selectedFoodTimings.add(timing);
          }
        });
      },
      child: Chip(
        backgroundColor: isSelected ? Color(0xFF6F8BEF) : Colors.grey.shade200,
        label: Text(
          timing,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
