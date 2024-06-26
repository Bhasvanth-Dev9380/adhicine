import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  bool isAlertSet = false;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) async {
    if (connectivityResult == ConnectivityResult.none && !isAlertSet) {
      showNoInternetDialog();
      isAlertSet = true;
    } else if (connectivityResult != ConnectivityResult.none && isAlertSet) {
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Close the dialog if the device is reconnected
        isAlertSet = false;
      }
    }
  }

  void showNoInternetDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/no-wifi.png', height: 150, width: 150),
            SizedBox(height: 20),
            Text(
              'Your Device is not connected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Connect your device with',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle Bluetooth connection
                  },
                  child: Icon(Icons.bluetooth, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Handle WiFi connection
                    Get.back(); // Close the dialog
                    isAlertSet = false;
                    bool isDeviceConnected = await InternetConnectionChecker().hasConnection;
                    if (!isDeviceConnected && !isAlertSet) {
                      showNoInternetDialog();
                      isAlertSet = true;
                    }
                  },
                  child: Icon(Icons.wifi, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
