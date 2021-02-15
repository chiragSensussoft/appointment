import 'dart:convert';
import 'dart:io';
import 'package:appointment/home/Home.dart';
import 'package:appointment/utils/CuastomDropDown.dart';
import 'package:appointment/utils/DBProvider.dart';
import 'package:appointment/utils/RoundShapeButton.dart';
import 'package:appointment/utils/drop_down.dart';
import 'package:appointment/utils/values/Constant.dart';
import 'package:appointment/utils/values/Dimen.dart';
import 'package:appointment/utils/values/Strings/Strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

SharedPreferences _sharedPreferences;

class _LoginState extends State<Login> with SingleTickerProviderStateMixin{
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    // checkIfLogin();
    super.initState();
      setValue();
  }
  String dropdownValue1 = 'One';
  String dropdownValue2 = 'Two';
  var _value;
  // Toast toast = Toast();
  Color warna = Colors.red;

  void _aksiPilihan(Menu menu){
    setState(() {
      warna=menu.warna;
    });
  }
  String text;
  int selectedIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children:[
            /// DD1
            Container(
              color: Colors.transparent,
              margin: EdgeInsets.only(right: Dimen().dp_20,top: 35),
              alignment: Alignment.topRight,
              child: SimpleAccountMenu(
                text: text,
                selectedIndex: selectedIndex,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: Colors.white,
                icons: [
                  Container(
                    // height:40,
                      child: Text("English",style: TextStyle(color: Colors.black,fontSize: 14),textAlign: TextAlign.center)),
                  Container(
                      child: Text("हिन्दी",style: TextStyle(color: Colors.black,fontSize: 14),textAlign: TextAlign.center)),
                  Container(
                      child: Text("ગુજરાતી",style: TextStyle(color: Colors.black,fontSize: 14),textAlign: TextAlign.center,)),
                ],
                onChange: (index) {
                  print(index);
                  if(index == 0){
                    setState(() {
                      text ="English";
                      selectedIndex = index;
                      Constant.languageCode = 'en';
                      languageCode(code: Constant.languageCode);
                    });
                  }
                  if(index == 1){
                    setState(() {
                      text ="हिन्दी";
                      selectedIndex = index;
                      Constant.languageCode = 'hi';
                      languageCode(code: Constant.languageCode);
                    });
                  }
                  if(index == 2){
                    setState(() {
                      text ="ગુજરાતી";
                      selectedIndex = index;
                      Constant.languageCode = 'gu';
                      languageCode(code: Constant.languageCode);
                    });
                  }
                },
              ),
            )


          ]
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(left: Dimen().dp_20,right: Dimen().dp_20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          child: Image.asset('images/appointment.png',height: 100,width: 100,),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 40),
                        child: Text(Resources.from(context,Constant.languageCode).strings.title,
                          textAlign: TextAlign.justify,style: TextStyle(fontFamily: 'poppins_regular',fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50,),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text( Resources.from(context,Constant.languageCode).strings.signInText,style: TextStyle(
                            fontSize: 16,fontFamily: 'poppins_medium'
                        ),),
                      ),
                      Center(
                        child: Container(
                            width: 200,
                            height: 40,
                            child:RoundShapeButton(
                              onPressed: () async {
                                try {
                                  final result = await InternetAddress.lookup('google.com');
                                  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                    signInWithGoogle();
                                  }
                                } on SocketException catch (_) {
                                  Constant.showToast(Resources.from(context, Constant.languageCode).strings.checkInternet, Toast.LENGTH_SHORT);
                                }

                              },
                              width: 1,
                              color: Colors.white,
                              text: Resources.from(context,Constant.languageCode).strings.googleBtnText,radius: 25,
                              icon: Image.asset('images/search.png',width: 20,height: 20,),)
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        width: 200,
                        height: 40,
                        child:RoundShapeButton(text: Resources.from(context,Constant.languageCode).strings.outLookBtnText,
                          width: 1,
                          color: Colors.white,
                          onPressed: (){
                            // Navigator.pushReplacement(context, MaterialPageRoute(
                            //   builder: (_) => Home(),
                            // ));
                            // toast.overLay = false;
                            // toast.showOverLay("Coming Soon!", Colors.white, Colors.black54, context);

                          },radius: 25,
                          icon: Image.asset('images/outlook.png',height: 20,width: 20),),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> languageCode({String code})async{
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(Constant().languageKey, code);
  }

  setValue()async{
    _sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      switch(_sharedPreferences.getString(Constant().languageKey)){
        case 'gu':
          return text = "ગુજરાતી";
        case 'hi':
          return text = "हिन्दी";
        default:
          return text = "English";
      }
    });
  }

  // checkIfLogin()async{
  //   _sharedPreferences = await SharedPreferences.getInstance();
  //   if(_sharedPreferences.getBool('isLogin')==true){
  //     Navigator.pushReplacement(context, MaterialPageRoute(
  //         builder: (_) => Home()
  //     ));
  //   }
  // }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ["email","https://www.googleapis.com/auth/userinfo.profile",
      "https://www.googleapis.com/auth/calendar"],
    clientId: "148622577769-nq42nevup780o2699h0ohtj1stsapmjj.apps.googleusercontent.com",
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
      Constant.email = user.email;
      Constant.token = googleSignInAuthentication.accessToken;
      _sharedPreferences.setBool('isLogin',true);
      update(firstName, lastName, user.email, 'Google', googleSignInAuthentication.idToken, googleSignInAuthentication.accessToken,user.displayName,user.photoUrl);
    }
    return 'signInWithGoogle succeeded: $user';
  }

  void signOutGoogle() async{
    await googleSignIn.signOut();
    print("User Sign Out");
  }

  void update(String fName,String lName,String email,String loginType,String idToken,String accessToken,String name,String photoUrl) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnfName: fName,
      DatabaseHelper.columnlName: lName,
      DatabaseHelper.columnEmail: email,
      DatabaseHelper.columnIsLoginWith: loginType,
      DatabaseHelper.columnAccessToken : accessToken,
      DatabaseHelper.columnIdToken : idToken,
      DatabaseHelper.columnPhotoUrl : photoUrl
    };

    final data = await dbHelper.select(email);

    if (data.length != 0) {
      dbHelper.update(row, data[0]['_id']);

      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => Home()
      ));
    }
    else {
      insertWithSocial(fName, lName, email, loginType,idToken,accessToken,photoUrl);
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => Home()
      ));
    }
  }

  void insertWithSocial(String fName,String lName,String email,String loginType,String idToken,String accessToken,
      String photoUrl){
    Map<String, dynamic> row = {
      DatabaseHelper.columnfName : fName,
      DatabaseHelper.columnlName : lName,
      DatabaseHelper.columnEmail : email,
      DatabaseHelper.columnIsLoginWith : loginType,
      DatabaseHelper.columnAccessToken : accessToken,
      DatabaseHelper.columnIdToken : idToken,
      DatabaseHelper.columnPhotoUrl : photoUrl
    };
    dbHelper.insert(row);
  }

}
class Menu{
  const Menu({this.teks, this.warna});
  final String teks;
  final Color warna;
}

List<Menu> listMenu = const <Menu>[
  const Menu (teks:"Merah", warna: Colors.red ),
  const Menu (teks:"Biru", warna: Colors.blue ),
  const Menu (teks:"Hijau", warna: Colors.green ),
];
