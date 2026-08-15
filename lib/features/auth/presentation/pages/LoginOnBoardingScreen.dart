import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stayindia_owner/features/auth/presentation/pages/login_page.dart';

class LoginOnBoardingScreen extends StatelessWidget {
  const LoginOnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Stack(
            children: [
              // Background Decorations
              Positioned(
                top: -200,
                right: -200,
                child: Container(
                  width: 420,
                  height: 480,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffF8F9FF),
                  ),
                ),
              ),

              Positioned(
                top: -200,
                right: -200,
                child: Container(
                  width: 520,
                  height: 520,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xffF8F9FF),
                      width: 3,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: -120,
                bottom: -30,
                child: Container(
                  width: 220,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: const Color(0xffF1F4FF),
                      width: 2,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: -120,
                bottom: -10,
                child: Transform.rotate(
                  angle: math.pi / 4, // 45 degrees
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xffF1F4FF),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  /// Illustration
                  Expanded(
                    flex: 5,
                    child: Image.asset(
                      "assets/images/welcome_image.png",
                      fit: BoxFit.contain,
                    ),
                  ),

                  /// Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Discover The Partner App Here",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        color: Color(0xffF58220),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(
                                      isStaffLogin: false,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffF58220),
                                elevation: 8,
                                shadowColor:
                                    const Color(0xffB8C4FF).withOpacity(.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                "Owner Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Expanded(child: SizedBox(
                        //   height: 60,
                        //   child:  TextButton(
                        //     onPressed: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => const LoginPage(
                        //             isStaffLogin: true,
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //     child: const Text(
                        //       "Staff Login",
                        //       style: TextStyle(
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.w600,
                        //         color: Color(0xFF0A0A0A),
                        //       ),
                        //     ),
                        //   ),
                        // ))

                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}