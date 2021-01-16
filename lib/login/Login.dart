import 'dart:convert';

import 'package:appointment/home/Home.dart';
import 'package:appointment/login/DBProvider.dart';
import 'package:appointment/utils/RoundShapeButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 20,right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              Column(
                children: [
                  Center(
                    child: Container(
                      child: SvgPicture.asset('images/appointment.svg',height: 100,width: 100,),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    child: Text(
                      'Using Digital Appointments will make managing your beauty saloons, hair styling, makeup, cosmetics and everything else that requires appointments a walk in the park.',
                      textAlign: TextAlign.justify,style: TextStyle(fontFamily: 'poppins_regular',fontSize: 15),
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Center(
                    child: Container(
                      width: 200,
                      height: 40,
                      child:RoundShapeButton(onPressed: signInWithGoogle,text: 'Login with Google',radius: 25,
                      icon: Image.asset('images/search.png',width: 20,height: 20,),)
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    width: 200,
                    height: 40,
                    child: RoundShapeButton(text: 'Login with Outlook',onPressed: (){},radius: 25,
                      icon: Image.asset('images/outlook.png',height: 20,width: 20,),)
                  ),
                ],
              )

            ],
          ),
        ),

    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ["email",
        "https://www.googleapis.com/auth/calendar"]
  );

  static Map<String, dynamic> parseJwt(String token) {
    if (token == null) return null;
    final List<String> parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    final String payload = parts[1];
    final String normalized = base64Url.normalize(payload);
    final String resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(resp);
    if (payloadMap is! Map<String, dynamic>) {
      return null;
    }
    return payloadMap;
  }

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final idToken = googleSignInAuthentication.idToken;

    Map<String, dynamic> idMap = parseJwt(idToken);

    final String firstName = idMap["given_name"];
    final String lastName = idMap["family_name"];

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    print("Access Token ==> ${googleSignInAuthentication.accessToken}");
    print("Id Token ==> ${googleSignInAuthentication.idToken}");

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);


    if(user!=null){

      update(firstName, lastName, user.email, 'Google', googleSignInAuthentication.idToken, googleSignInAuthentication.accessToken);
    }
    return 'signInWithGoogle succeeded: $user';
  }

  void signOutGoogle() async{
    await googleSignIn.signOut();
    print("User Sign Out");
  }

  void update(String fName,String lName,String email,String loginType,String idToken,String accessToken) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnfName: fName,
      DatabaseHelper.columnlName: lName,
      DatabaseHelper.columnAccessToken : accessToken,
      DatabaseHelper.columnIdToken : idToken,
      DatabaseHelper.columnEmail: email,
      DatabaseHelper.columnIsLoginWith: loginType,
    };

    final data = await dbHelper.select(email);

    if (data.length != 0) {
      dbHelper.update(row, data[0]['_id']);
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => Home()
      ));
    }
    else {
      insertWithSocial(fName, lName, email, loginType,idToken,accessToken);
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => Home()
      ));
    }
  }

  void insertWithSocial(String fName,String lName,String email,String loginType,String idToken,String accessToken){
    Map<String, dynamic> row = {
      DatabaseHelper.columnfName : fName,
      DatabaseHelper.columnlName : lName,
      DatabaseHelper.columnAccessToken : accessToken,
      DatabaseHelper.columnIdToken : idToken,
      DatabaseHelper.columnEmail : email,
      DatabaseHelper.columnIsLoginWith : loginType,
    };
    dbHelper.insert(row);
  }
  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    allRows.forEach((row) {
      print(row);
    });
  }


}