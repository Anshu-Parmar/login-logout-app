import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:youtube_clone/bottom_navigation.dart';

import 'just_variables.dart';

class VerifyUserEmail extends StatefulWidget {
  const VerifyUserEmail({super.key});

  @override
  State<VerifyUserEmail> createState() => _VerifyUserEmailState();
}

class _VerifyUserEmailState extends State<VerifyUserEmail> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isCurrentUserLoggedIn = true;
    }

    if(!isEmailVerified){
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const BottomNavigator()
        : const Scaffold(
            body: Center(
              child: Dialog(
                child: Text("Please verify your email!!!"),
              ),
            ),
          );
  }

  Future sendVerificationEmail() async{
    try{
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    }catch (e){
      print(e);
    }
  }

  Future checkEmailVerified() async{

    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if(isEmailVerified) timer?.cancel();
  }
}
