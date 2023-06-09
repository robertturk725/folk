import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alert/flutter_alert.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:folk/pages/login&signup/phone_login.dart';
import 'package:folk/utils/Animations/FadeAnimation.dart';
import 'package:folk/utils/Animations/delayed_reveal.dart';
import 'package:folk/utils/Login_utils/loading_dialogs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:folk/models/UserModel.dart';
import 'package:folk/pages/signup.dart';
import 'package:folk/providers/AuthProvider.dart';
import 'package:folk/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:folk/widgets/bezierContainer.dart';
import 'package:folk/pages/login&signup/forgotPassword.dart';

import '../app_localizations.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void startFBLogin(String email, _fbId, _fbName, _fbPicUrl, login_Type) async {
    var url = '${Constants.SERVER_URL}user/fblogin';
     print(_fbPicUrl);
    try {
      var response = await http.post(
        url,
        body: {
          'email': email.toLowerCase(),
          'fb_url': _fbPicUrl.toString()
          },
      );
      var jsonResponse = await convert.jsonDecode(response.body);
      bool error = jsonResponse['error'];
      pr.hide();
      if (error) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('${jsonResponse['data']}'),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('close'))
                ],
              );
            });
      } else {
        var usrstatus = jsonResponse['loginstatus'];
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        print(usrstatus);
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

        if (usrstatus == 'newuser') {
          //Do Something Here
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PhoneLogin(
                  fbId: _fbId,
                  fbName: _fbName,
                  fbEmail: email,
                  fbPicUrl: _fbPicUrl,
                  loginType: login_Type)));
        } else {
         
          var userData = jsonResponse['data'];
          UserModel myModel = UserModel.fromJson(userData);

          //make my model usable to all widgets
          Provider.of<AuthProvider>(context, listen: false).userModel = myModel;
          // print(myModel.interestData.length.toString());
          String categoryString = '';
          if(myModel.userInterests[0].interestname != null){
                for (var i = 0; i < myModel.userInterests.length; i++) {
            // print(myModel.userInterests[i].interestname);

             if (categoryString == '') {
                        categoryString += myModel.userInterests[i].interestname;
                      } else {
                        categoryString +=
                            " - " + myModel.userInterests[i].interestname;
                      }
          }
          }
          print("huttooooooooooooooooooooooooooooooooooooooooooo");
         

          print("cat string is = "+categoryString);
          Provider.of<AuthProvider>(context, listen: false)
            .updateCategoryString(categoryString);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("gettoken", jsonResponse['token']);
          prefs.setString("email", email);
          prefs.setString("fburl", _fbPicUrl);
          // saveData(
          //     myModel.id, myModel.name, myModel.email, myModel.token);
          print("login succcessfull");
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => VerifyingScreen(
                  fbId: _fbId,
                  fbName: _fbName,
                  fbEmail: email,
                  fbPicUrl: _fbPicUrl,
                  loginType: login_Type)));
        }
      }
    } catch (err) {
      pr.hide();
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('check your internet connection'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close'))
              ],
            );
          });
    }
  }

  // void saveData(String id, String name, String email, password) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   sharedPreferences.setString('_id', id);
  // }

  bool isLoggedIn = false;
  var profileData;
  String login_Type = "";
  ProgressDialog pr;

  SharedPreferences prefs;

  var facebookLogin = FacebookLogin();

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onBackPressed() {
    return AwesomeDialog(
            context: context,
            dialogType: DialogType.WARNING,
            // customHeader: Image.asset("assets/images/macha.gif"),
            animType: AnimType.TOPSLIDE,
            btnOkText: AppLocalizations.of(context).translate('yes'),
            btnCancelText: AppLocalizations.of(context).translate('no'),
            tittle: AppLocalizations.of(context).translate('you_sure'),
            desc: AppLocalizations.of(context).translate('exit_app'),
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              exit(0);
            }).show() ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);

    pr.style(
        message: 'Please wait...',
        borderRadius: 10.0,
        progressWidget: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/loading2.gif'),
                    fit: BoxFit.cover))
                    ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressTextStyle: TextStyle(fontFamily: 'Montserrat'));

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            FadeAnimation(
              0.3,
              Container(
                child: new Image.asset(
                  'assets/images/bg-white.png',
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              top: 90.0,
              left: (MediaQuery.of(context).size.width) / 3,
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.cover)),
                height: 66.0,
                width: 140.0,
              ),
            ),
            Positioned(
              bottom: 20,
              left: 32,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    DelayedReveal(
                      delay: Duration(milliseconds: 300),
                      child: InkWell(
                        onTap: () {
                          log('Clikced on Login with facebook btn');
                          setState(() {
                            login_Type = "fb";
                          });
                          // Navigator.of(context).pushNamed("/home");
                          initiateFacebookLogin();
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Container(
                              height: 55,
                              width: MediaQuery.of(context).size.width / 1.2,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF2672CB),
                                      Color(0xFF2672CB)
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/images/fb-icon.png',
                                      scale: 1.4,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 35.0, right: 20),
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .translate('with_fb')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: 'Montserrat',
                                          // fontWeight: FontWeight.w100,
                                          // letterSpacing: 0.2,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    DelayedReveal(
                      delay: Duration(milliseconds: 450),
                      child: InkWell(
                        onTap: () {
                          log('Clikced on Login with 4n btn');
                          // CircularProgressIndicator();
                          setState(() {
                            login_Type = "otp";
                          });
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  PhoneLogin(loginType: login_Type)));

                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) =>
                          //         SetupStepThree()));
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              height: 55,
                              width: MediaQuery.of(context).size.width / 1.2,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFF6038),
                                      Color(0xFFFF9006)
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .translate('with_phone')
                                            .toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: 'Montserrat',
                                            // fontWeight: FontWeight.w600,
                                            // letterSpacing: 0.2,
                                            height: 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    DelayedReveal(
                      delay: Duration(milliseconds: 600),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: InkWell(
                            onTap: () {
                              log('Clikced on trouble with login');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPassword(),
                                ),
                              );
                            },
                            child: Container(
                              child: Text(
                                  AppLocalizations.of(context)
                                      .translate('trouble_login'),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      decoration: TextDecoration.underline)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    DelayedReveal(
                      delay: Duration(milliseconds: 750),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Container(
                            child: Text(
                                AppLocalizations.of(context)
                                    .translate('by_clicking'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                )),
                          ),
                        ),
                      ),
                    ),
                    DelayedReveal(
                      delay: Duration(milliseconds: 900),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Container(
                            child: Text(
                                AppLocalizations.of(context)
                                    .translate('terms_conditions'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                )),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void initiateFacebookLogin() async {
    var facebookLoginResult =
        await facebookLogin.logInWithReadPermissions(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        pr.show();
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(400)&access_token=${facebookLoginResult.accessToken.token}');

        var profile = json.decode(graphResponse.body);
        print(profile.toString());

        onLoginStatusChanged(true, profileData: profile);

        final _fbId = "${profileData['id']}";
        final _fbName = "${profileData['first_name']}";
        final _fbEmail = "${profileData['email']}";
        // final _gender = "${profileData['user_gender']}";
        final _fbPicUrl = profileData['picture']['data']['url'];

        if (_fbEmail != null) {
          print(_fbEmail);
          print(_fbPicUrl);
          startFBLogin(_fbEmail, _fbId, _fbName, _fbPicUrl, login_Type);
        } else {
          showAlert(
            context: context,
            title: AppLocalizations.of(context).translate('went_wrong'),
          );
          print("something went wrong ");
        }

        // print(_fbName+"\n"+_fbEmail);
        break;
    }
  }
}
