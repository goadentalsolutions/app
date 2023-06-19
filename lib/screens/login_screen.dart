import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goa_dental_clinic/screens/patient_screens/add_patient_screen.dart';
import 'package:goa_dental_clinic/screens/register_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/alert.dart';
import '../classes/pref.dart';
import '../constants.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/google_button.dart';
import '../custom_widgets/icon_textfield.dart';
import 'doctor_screens/nav_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController otpController = TextEditingController();
  bool codeSent = false, verified = true, isVerifyButtonVisible = false;
  String phoneNumber = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  late String verId;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool otpLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> sendCode(BuildContext context) async {
    setState(() {
      otpLoading = true;
    });
    await auth.verifyPhoneNumber(
      phoneNumber: '$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              '$e',
              style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          codeSent = true;
          verId = verificationId;
          otpLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

  }

  Future<void> verifyCode() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verId, smsCode: otpController.text);
      await auth.signInWithCredential(credential);

      setState(() {
        verified = true;
      });

      await isNew();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            '$e',
            style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  isNew() async {
    try {
      final data =
      await firestore.collection('Users').doc(auth.currentUser!.uid).get();
      print(data['setup']);
      try {
        if (data['setup'] == 1) {
          try {
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.setString('role', data['role']);
            pref.setString('name', data['name']);
            pref.setString('email', data['email']);
          }
          catch(e){
            print('Pref error: $e');
          }
          if(data['role'] == 'doctor')
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NavScreen()));
          else
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddPatientScreen()));
        }
        if(data['setup'] == 2){
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NavScreen()));
        }
      } catch (e) {
        print('$e-----');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RegisterScreen()));
      }
    }
    catch(e){
      print(e);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterScreen()));
    }
  }

  bool isValid(){
    if(!phoneNumber.startsWith('+91')){
      setState(() {
        phoneNumber = "+91$phoneNumber";
      });
    }
    if(phoneNumber.isEmpty){
      Alert(context, 'Phone number cannot be empty');
      return false;
    }
    if(phoneNumber.length > 13){
      Alert(context, 'Enter a valid phone number');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16,),
                Hero(
                  tag: 'hero1',
                  child: Container(
                    height: size.height * 0.3,
                    child: SvgPicture.asset('svgs/logo.svg'),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  'Let\'s get started !',
                  style: kBigText,
                ),
                SizedBox(height: 8),
                Text('Enter your phone number'),
                SizedBox(
                  height: 24,
                ),
                IconTextField(
                  icon: Icons.phone,
                  hintText: 'Phone Number',
                  inputType: TextInputType.phone,
                  onChanged: (newValue) {
                    setState(() {
                      phoneNumber = newValue;
                    });
                  },
                ),
                SizedBox(
                  height: 24,
                ),
                CustomButton(
                    text: !codeSent ? 'Send Otp' : 'Resend Otp',
                    backgroundColor: kButtonBlue,
                    onPressed: () {
                      if(isValid())
                      sendCode(context);
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => NavScreen()));
                    }, isLoading: otpLoading, loadingWidget: Center(child: CircularProgressIndicator(color: Colors.white,),),),
                SizedBox(
                  height: 16,
                ),
                Visibility(
                  child: Center(
                    child: Text(
                      'OTP has been sent !',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ),
                  visible: codeSent,
                ),
                Visibility(
                  child: SizedBox(
                    height: 16,
                  ),
                  visible: codeSent,
                ),
                Visibility(
                  child: Pinput(
                    length: 6,
                    controller: otpController,
                    onChanged: (newValue) {
                      if (newValue.length == 6) {
                        setState(() {
                          isVerifyButtonVisible = true;
                        });
                      }
                    },
                  ),
                  visible: codeSent,
                ),
                Visibility(
                  child: SizedBox(
                    height: 24,
                  ),
                  visible: codeSent,
                ),
                Visibility(
                  child: CustomButton(
                    text: 'Verify',
                    backgroundColor: kPrimaryColor,
                    onPressed: () {
                      setState(
                        () {
                          verified = false;
                          // if(!(!verified && isVerifyButtonVisible))
                          verifyCode();
                        },
                      );
                    },
                    isLoading: (!verified && isVerifyButtonVisible),
                    loadingWidget: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  visible: isVerifyButtonVisible,
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
