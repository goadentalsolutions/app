import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goa_dental_clinic/classes/pref.dart';
import 'package:goa_dental_clinic/constants.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/doctor_message_screen.dart';
import 'package:goa_dental_clinic/screens/doctor_screens/home_screen.dart';
import 'package:goa_dental_clinic/screens/login_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/patient_calendar_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/patient_home_screen.dart';
import 'package:goa_dental_clinic/screens/patient_screens/patient_message_screen.dart';
import 'package:goa_dental_clinic/screens/register_screen.dart';
import 'package:goa_dental_clinic/screens/welcome_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'calendar_screen.dart';

class NavScreen extends StatefulWidget {
  @override
  State<NavScreen> createState() => _NavScreenState();

  NavScreen({this.screenNo = 1});
  int screenNo;
}

class _NavScreenState extends State<NavScreen> {
  List screens = [];
  int _currentIndex = 0;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? role;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // auth.signOut();
    _currentIndex = widget.screenNo - 1;
    checkRole();

  }

  checkRole() async {
    setState(() {
      isLoading = true;
    });
    role = await Pref('role', '').getString();
    print(role);
    if(role == 'doctor')
      screens = [HomeScreen(), CalendarScreen(), DoctorMessageScreen()];
    else
      screens = [PatientHomeScreen(), PatientCalendarScreen(), PatientMessageScreen()];

    setState(() {
      isLoading = false;
    });
  }
  _onItemTapped(index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: (isLoading) ? null : ((role == 'doctor') ? GNav(
          padding: EdgeInsets.only(bottom: 30, top: 25, left: 25, right: 25),
          onTabChange: _onItemTapped,
          activeColor: Colors.blue,
          gap: 8,
          tabs: [
            GButton(
              icon: Icons.home_outlined,
              text: 'Home',
            ),
            GButton(
              icon: Icons.calendar_month,
              text: 'Calendar',
            ),
            GButton(
              icon: Icons.message,
              text: 'Messages',
            ),
          ]) : GNav(
          padding: EdgeInsets.only(bottom: 30, top: 25, left: 25, right: 25),
          onTabChange: _onItemTapped,
          activeColor: Colors.blue,
          gap: 8,
          tabs: [
            GButton(
              icon: Icons.home_outlined,
              text: 'Home',
            ),
            GButton(
              icon: Icons.calendar_month,
              text: 'Calendar',
            ),
            GButton(
              icon: Icons.person,
              text: 'Profile',
            ),
          ])),
      body: (isLoading) ? Center(child: CircularProgressIndicator(color: kPrimaryColor,),) : screens[_currentIndex],
    );
  }
}