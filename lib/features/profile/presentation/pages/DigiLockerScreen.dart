import 'package:flutter/material.dart';
import 'package:flutter_digilocker_aadhar_pan/flutter_digilocker_aadhar_pan.dart';

class Digilockerscreen extends StatefulWidget {
  @override
  _DigilockerscreenState createState() => _DigilockerscreenState();
}

class _DigilockerscreenState extends State<Digilockerscreen> {
  bool _showDigiLocker = false;

  final DigiLockerConfig config = const DigiLockerConfig(
    companyName: "punithOiXa",
    secretToken: "K1tPIbkUX6eZE28sgP5qCIrwmTJnW5F1",
    redirectUrl: "https://digilocker.meon.co.in/digilocker/thank-you-page",
    documents: "aadhaar",
    panName: "",
    panNo: "",
  );

  void _handleSuccess(DigiLockerResponse response) {
    debugPrint("Success : ${response.toJson()}");

    setState(() {
      _showDigiLocker = false;
    });
  }

  void _handleError(String error) {
    debugPrint("Error : $error");

    setState(() {
      _showDigiLocker = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DigiLocker"),
      ),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showDigiLocker = true;
                });
              },
              child: const Text("Verify with DigiLocker"),
            ),
          ),

          if (_showDigiLocker)
            Positioned.fill(
              child: DigiLockerWidget(
                config: config,
                onSuccess: _handleSuccess,
                onError: _handleError,
                onClose: () {
                  setState(() {
                    _showDigiLocker = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}