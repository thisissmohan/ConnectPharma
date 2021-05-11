import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'LoginPage.dart';

class PharmacySignUpPage extends StatefulWidget {
  @override
  _PharmacySignUpPageState createState() => new _PharmacySignUpPageState();
}

class _PharmacySignUpPageState extends State<PharmacySignUpPage> {
  bool _passwordVisible = true;
  bool checkedValue = false;

  String _password, _email;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("Pharmacy Users");

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Stack(
          alignment: Alignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Back/Sign Up/Log In Widgets
            Align(
              alignment: Alignment(0, -0.88),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      child: Icon(Icons.keyboard_backspace,
                          size: 35.0, color: Colors.grey),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Sign Up",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 35.0,
                          color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        //Go to LogIn Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LogInPage()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "LogIn",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15.0,
                              color: Color(0xFF5DB075)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            //Email/Password Text Fields
            Align(
              alignment: Alignment(0, -0.21),
              //TODO: USE FORM WIDGET FOR THIS LIKE THIS: https://flutter.dev/docs/cookbook/forms/validation#:~:text=Validate%20the%20input%20by%20providing,the%20TextFormField%20isn't%20empty.
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    //Email Text Field
                    Container(
                      width: 324,
                      child: TextFormField(
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Please type in a email!';
                          }
                          _formKey.currentState.save();
                        },
                        onSaved: (input) {
                          _email = input;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF6F6F6),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFFE8E8E8))),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE8E8E8)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: 'Email',
                          hintStyle:
                              TextStyle(color: Color(0xFFBDBDBD), fontSize: 16),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    //Password Text Field
                    Container(
                      width: 324,
                      child: TextFormField(
                        validator: (input) {
                          if (input.length < 6) {
                            return 'Please type in a passowrd longer then 6 characters!';
                          }
                        },
                        onSaved: (input) => _password = input,
                        obscureText: !_passwordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF6F6F6),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFFE8E8E8))),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE8E8E8)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: 'Password',
                          hintStyle:
                              TextStyle(color: Color(0xFFBDBDBD), fontSize: 16),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Color(0xFFBDBDBD),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            color: Color(0xFFBDBDBD),
                            splashRadius: 1,
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    //Newsletter Check Box
                    CheckboxListTile(
                      title: RichText(
                        text: TextSpan(
                          text:
                              "I would like to receive your newsletter and other promotional information.",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 14.0,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                      activeColor: Color(0xFF5DB075),
                      value: checkedValue,
                      onChanged: (newValue) {
                        //todo: Save the check value information to save to account
                        setState(() {
                          checkedValue = newValue;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    ),
                  ],
                ),
              ),
            ),
            //Google/Twitter/Facebook Icons
            Align(
              alignment: Alignment(0, 0.42),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //Google
                  GestureDetector(
                    onTap: () {
                      //Log In Using Google
                    },
                    child: SvgPicture.asset('assets/icons/GoogleIcon.svg',
                        width: 48, height: 48),
                  ),
                  SizedBox(width: 50),
                  //Facebook
                  GestureDetector(
                      onTap: () {
                        //Log In Using Twitter
                      },
                      child: SvgPicture.asset('assets/icons/FacebookIcon.svg',
                          width: 48, height: 48)),
                  SizedBox(width: 50),
                  //Twitter
                  GestureDetector(
                      onTap: () {
                        //Log In Using Facebook
                      },
                      child: SvgPicture.asset('assets/icons/TwitterIcon.svg',
                          width: 48, height: 48)),
                ],
              ),
            ),
            //Sign Up Button
            Align(
              alignment: Alignment(0, 0.87),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 324,
                    height: 51,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xFF5DB075)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ))),
                      onPressed: () {
                        //Login to account and send to disgnated pharmacy or pharmacist page
                        signUpPharmacy();
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Sign Up as a Pharmacy",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signUpPharmacy() async {
    //Validate Fields
    print("IN THE SIGN UP PHARMACY");
    final formState = _formKey.currentState;
    if (formState.validate()) {
      //Login to firebase
      formState.save();
      try {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Successfully sign up")));
        // ignore: unused_local_variable
        /*UserCredential user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password)
            .then((result) {
          dbRef.child(result.user.uid).set({
            "email": _email,
            "user_type": "Pharmacy",
          }).then((res) {
            // Direct to Pharmacy Information Form pages
          });
        });*/
        //Send to Pharmacy Sign Up Information Page
      } catch (e) {
        print(e.message);
      }
    }
  }
}