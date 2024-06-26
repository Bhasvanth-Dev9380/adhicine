import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/user_details.dart';
import '../utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    UserDetails userDetails = UserDetails();
    Map<String, dynamic> user = await userDetails.getUserDetails();
    setState(() {
      userName = user['name'] ?? 'No Name';
      profileImageUrl = user['profile_image'] ?? 'assets/profile_image.png';
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: profileImageUrl.startsWith('assets')
                          ? AssetImage(profileImageUrl) as ImageProvider
                          : NetworkImage(profileImageUrl),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Take Care!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildListTile(
                icon: Icons.notifications,
                title: 'Notification',
                subtitle: 'Check your medicine notification',
              ),
              _buildListTile(
                icon: Icons.volume_up,
                title: 'Sound',
                subtitle: 'Ring, Silent, Vibrate',
              ),
              _buildListTile(
                icon: Icons.account_circle,
                title: 'Manage Your Account',
                subtitle: 'Password, Email ID, Phone Number',
              ),
              SizedBox(height: 20),
              Text(
                'Device',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              _buildDeviceCard(),
              SizedBox(height: 20),
              Text(
                'Caretakers: 03',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              _buildCaretakers(),
              SizedBox(height: 20),
              Text(
                'Doctor',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              _buildDoctorCard(),
              SizedBox(height: 20),
              _buildTextButton('Privacy Policy'),
              _buildTextButton('Terms of Use'),
              _buildTextButton('Rate Us'),
              _buildTextButton('Share'),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _logout,
                  child: Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), backgroundColor: Colors.blue,
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

  Widget _buildListTile({required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        // Handle the tap
      },
    );
  }

  Widget _buildDeviceCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      color: Colors.blue.shade50,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.bluetooth, color: Colors.blue),
            title: Text('Connect'),
            subtitle: Text('Bluetooth, Wi-Fi'),
          ),
          ListTile(
            leading: Icon(Icons.volume_up, color: Colors.blue),
            title: Text('Sound Option'),
            subtitle: Text('Ring, Silent, Vibrate'),
          ),
        ],
      ),
    );
  }

  Widget _buildCaretakers() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCaretakerAvatar('assets/caretaker1.png', 'Dipa Luna'),
            _buildCaretakerAvatar('assets/caretaker2.png', 'Roz Sodd..'),
            _buildCaretakerAvatar('assets/caretaker3.png', 'Sunny Tu..'),
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.add, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaretakerAvatar(String imagePath, String name) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(imagePath),
        ),
        SizedBox(height: 5),
        Text(name, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDoctorCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      color: Colors.blue.shade50,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.add, color: Colors.blue),
        ),
        title: Text('Add Your Doctor'),
        subtitle: Text('Or use invite link', style: TextStyle(color: Colors.orange)),
        onTap: () {
          // Handle the tap
        },
      ),
    );
  }

  Widget _buildTextButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextButton(
        onPressed: () {
          // Handle the tap
        },
        child: Text(text, style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
