import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:youtube_clone/login_page.dart';
import 'package:youtube_clone/splash_screen/verify_email_user.dart';

class CheckVerified extends StatelessWidget {
  const CheckVerified({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              return const VerifyUserEmail();
            }
            else{
              return const LoginPage();
              }
            }
      ),
    );
  }
}
