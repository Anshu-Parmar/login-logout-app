import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:youtube_clone/splash_screen/just_variables.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String phoneNumber;
  late String userEmailId;
  late String userPassword;
  late String reEnterPassword;
  late String smsCode;
  late String verificationIdd;
  bool isOtpSent = false;
  final formKey = GlobalKey<FormState>();
  var otpTextController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText('Login'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Form(
            key: formKey,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Enter Email',
                    ),
                    validator: (value) {
                      if (value!.isEmpty || !RegExp(
                          r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$')
                          .hasMatch(value)) {
                        return 'Enter correct emailId';
                      } else {
                        return null;
                      }
                    },

                    onSaved: (newValue) {
                      userEmailId = newValue!;
                      print('emailid save executed on save');
                    },
                  ),
                ),
                const SizedBox(height: 5,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                      labelText: 'Enter Password',
                    ),
                    validator: (value) {
                      if (value!.isEmpty || !RegExp(
                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$')
                          .hasMatch(value)) {
                        return 'Must have one: uppercase, lowercase, digit, specialchar.';
                      } else {
                        return null;
                      }
                    },

                    onSaved: (newValue) {
                      userPassword = newValue!;
                      print('password save executed on save');
                    },
                  ),
                ),
                const SizedBox(height: 5,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                      labelText: 'Re-Enter Password',
                    ),

                    onChanged: (value) {
                      reEnterPassword = value;
                    },

                    validator: (value) {
                      if (value!.isEmpty || value!=reEnterPassword) {
                        return 'Not same as above!';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),

                const SizedBox(height: 5,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Enter Phone Number',
                    ),
                    validator: (value) {
                      if (value!.isEmpty || !RegExp(
                          r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s./0-9]+$')
                          .hasMatch(value) || value.length != 10) {
                        return 'Enter correct phone number';
                      } else {
                        return null;
                      }
                    },

                    onChanged: (value) {
                      phoneNumber = value;
                      print('phone number $phoneNumber');
                    },

                    onSaved: (newValue) {
                      phoneNumber = newValue!;
                      print('executed on save');
                    },
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          getOtp();
                        },
                        child: const AutoSizeText('Send Otp...')
                    ),
                    TextButton(
                        onPressed: () {
                          getEmailVerification();
                        },
                        child: const AutoSizeText('Send Email...')
                    ),
                  ],
                ),
              ],
            ),
          ),
         callOtpField(),
        ],
      ),
    );
  }

  void getOtp() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+91$phoneNumber',
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {},
           codeSent: (String verificationId, int? resendToken) async{
             verificationIdd = verificationId;
             isOtpSent=true;
              print('CODE HAS BEEN SENT!!!');
             setState(() { });
           },
           codeAutoRetrievalTimeout: (String verificationId) {},
      );

    }
  }

  void getEmailVerification() async{
    isCurrentUserLoggedIn = true;
    if (formKey.currentState!.validate()){
      formKey.currentState!.save();
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: userEmailId,
          password: userPassword,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }

      sendVerificationEmail();
      print('Email SENT TO EMAILID FOR VERIFICATION');

    }
  }

  Widget callOtpField(){
    if (isOtpSent==true){
      return Column(
        children: [
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Pinput(
              length: 6,
              showCursor: true,

              onChanged: (value){
                smsCode = value;
                print("This is the OTP: $smsCode");
              },
            ),
          ),
          const SizedBox(height: 10,),
          TextButton(
              onPressed: () async {
                smsCode = otpTextController.text;
                PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationIdd, smsCode: smsCode);
                print('Credentials generated!');
                await FirebaseAuth.instance.signInWithCredential(credential).then((value) => print('User is signed in'),);
              },
              child: const AutoSizeText('Submit Otp')
          ),
        ],
      );
    }else{
      return const SizedBox();
    }
  }

  Future sendVerificationEmail() async {
    try{
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch(e){
      print(e);
    }

  }


}


