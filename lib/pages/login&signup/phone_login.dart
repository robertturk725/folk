import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:folk/Utils/Animations/FadeAnimation.dart';
import 'package:folk/app_localizations.dart';
import 'package:folk/models/UserModel.dart';
import 'package:folk/providers/AuthProvider.dart';
import 'dart:convert' as convert;
import 'package:folk/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:folk/utils/Login_utils/loading_dialogs.dart';

class PhoneLogin extends StatefulWidget {
  final fbId;
  final fbName;
  final fbEmail;
  final fbPicUrl;
  final loginType;
  PhoneLogin(
      {Key key,
      this.fbId,
      this.fbName,
      this.fbEmail,
      this.fbPicUrl,
      this.loginType})
      : super(key: key);

  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final _phoneNo = TextEditingController();
  Country _selected = Country.IT;
  String _countrycode = '+39';
  String _errorTxt = '';
  String _loginStatus = "";
  String phoneNum = "";
  bool isClicked = false;
  ProgressDialog pr;
     


  @override
  void initState() {
    setState(() {
      _errorTxt = "";
      _loginStatus = "";
    });
    // print(widget.fbId +
    //     "\n" +
    //     widget.fbName +
    //     "\n" +
    //     widget.fbEmail +
    //     "\n" +
    //     widget.fbPicUrl);
    log("LoginType = " + widget.loginType);
    print(_countrycode);
    super.initState();
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
                    fit: BoxFit.cover))),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressTextStyle: TextStyle(fontFamily: 'Montserrat'));

    return new Scaffold(
      resizeToAvoidBottomPadding: false, // this avoids the overflow error
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            _errorTxt = "";
          });
        },
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 50.0, left: 14),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    iconSize: 38,
                    onPressed: () {
                      log('Clikced on back btn');
                      Navigator.of(context).pop();
                      //go back
                    },
                  ),
                ),
                FadeAnimation(
                  0.8,
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Text(
                        AppLocalizations.of(context).translate('enter_phone'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(64, 75, 105, 1),
                          fontSize: 25,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                FadeAnimation(
                  1,
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width / 3.7,
                            margin: EdgeInsets.only(top: 20),
                            child: CountryPicker(
                              dense: false,
                              showFlag: true, //displays flag, true by default
                              showDialingCode:
                                  true, //displays dialing code, false by default
                              showName:
                                  false, //displays country name, true by default
                              showCurrency: false, //eg. 'British pound'
                              showCurrencyISO: false, //eg. 'GBP'
                              onChanged: (Country country) {
                                setState(() {
                                  _selected = country;
                                });

                                final countryCode = "+${country.dialingCode}";

                                _countrycode = countryCode.toString();

                                print(_countrycode);
                              },
                              selectedCountry: _selected,
                            ),
                          ),
                          FadeAnimation(
                            1,
                            Container(
                              width: MediaQuery.of(context).size.width / 1.6,
                              margin: EdgeInsets.only(top: 40),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: _phoneNo,
                                // maxLength: 15,
                                decoration: InputDecoration(
                                    border: new OutlineInputBorder(
                                        borderSide: new BorderSide(
                                            color: Color(0xFFE0E0E0))),
                                    labelText: AppLocalizations.of(context)
                                        .translate('phone_no'),
                                    errorText: _errorTxt,
                                    errorBorder: _errorTxt.isEmpty
                                        ? OutlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Color(0xFFE0E0E0)))
                                        : null,
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFE0E0E0)))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FadeAnimation(
                    1.2,
                    Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 30, left: 28, right: 28),
                          child: Text(
                            AppLocalizations.of(context).translate('tap_next_to'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF404B69),
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                  ),
                FadeAnimation(
                  1.4,
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 45, left: 26, right: 26),
                      child: InkWell(
                        onTap: () async {
                          if (checkNull()) {
                            pr.show();
                            setState(() {
                              _errorTxt = "";
                              isClicked = true;
                            });
                            if (validatePhone()) {
                              phoneNum = _countrycode + _phoneNo.text;
                              print(phoneNum);

                              final body = {"phone": phoneNum};
                              final _loginType = widget.loginType;

                              if (_loginType == "otp") {
                                //gegsegseg
                                var url =
                                    '${Constants.SERVER_URL}user/otplogin';

                                try {
                                  var response = await http.post(
                                    url,
                                    body: body,
                                  );
                                  var jsonResponse =
                                      await convert.jsonDecode(response.body);
                                  bool error = jsonResponse['error'];
                                  print(
                                      "-----------------------here---------------------");
                                  print(jsonResponse);
                                  if (error) {
                                    pr.hide();
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title:
                                                Text('${jsonResponse['data']}'),
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
                                    print(
                                        ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                                    print(usrstatus);
                                    print(
                                        ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

                                    if (usrstatus == 'olduser') {
                                      //Do Something Here
                                      var userData = jsonResponse['data'];
                                      UserModel myModel =
                                          UserModel.fromJson(userData);

                                      //make my model usable to all widgets
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .userModel = myModel;
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

                                      print(
                                          "cat string is = " + categoryString);
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .updateCategoryString(categoryString);

                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setString("gettoken", jsonResponse['token']);
                                      prefs.setString("phone", phoneNum);

                                      setState(() {
                                        _loginStatus = "otpolduser";
                                        //should go to home after verify
                                      });
                                      print('login status - ' + _loginStatus);
                                      pr.hide();
                                      //otp login old user
                                      navigateToVerifyingScreen();
                                    } else {
                                      print(
                                          "-----------------------here---------------------");

                                      setState(() {
                                        _loginStatus = "otpnewuser";
                                        //should go to stepone after verify
                                      });
                                      print('login status - ' + _loginStatus);

                                      pr.hide();
                                      //otp login new user
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  VerifyPhoneScreen(
                                                      phone: phoneNum,
                                                      loginStatus: _loginStatus,
                                                      loginType: _loginType)));
                                    }
                                  }
                                } catch (err) {
                                  pr.hide();
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              'check your internet connection'),
                                          actions: <Widget>[
                                            FlatButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('close'))
                                          ],
                                        );
                                      });
                                  return 'false';
                                }
                                // /fsdfes
                              } else {

                                
                                var url =
                                    '${Constants.SERVER_URL}user/otplogin';

                                try {
                                  var response = await http.post(
                                    url,
                                    body: body,
                                  );
                                  var jsonResponse =
                                      await convert.jsonDecode(response.body);
                                  bool error = jsonResponse['error'];
                                  print(
                                      "-----------------------here---------------------");
                                  print(jsonResponse);
                                  if (error) {
                                    pr.hide();
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title:
                                                Text('${jsonResponse['data']}'),
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
                                    print(
                                        ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                                    print(usrstatus);
                                    print(
                                        ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

                                    if (usrstatus == 'olduser') {
                                      //Do Something Here
                                      var userData = jsonResponse['data'];
                                      UserModel myModel =
                                          UserModel.fromJson(userData);

                                      //make my model usable to all widgets
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .userModel = myModel;
                                      // print(myModel.interestData.length.toString());
                                      String categoryString = '';

                                      for (var i = 0;
                                          i < myModel.userInterests.length;
                                          i++) {
                                        print(myModel
                                            .userInterests[i].interestname);

                                        if (categoryString == '') {
                                          categoryString += myModel
                                              .userInterests[i].interestname;
                                        } else {
                                          categoryString += " - " +
                                              myModel.userInterests[i]
                                                  .interestname;
                                        }
                                      }

                                      print(
                                          "cat string is = " + categoryString);
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .updateCategoryString(categoryString);

                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setString(
                                          "gettoken", jsonResponse['token']);

                                      setState(() {
                                        _loginStatus = "fbnewuserOtpOld";
                                        //should go to home after verify
                                      });
                                      print("login status - " + _loginStatus);
                                      log("fb new user who already have an otp login");
                                      pr.hide();
                                      navigateToVerifyingScreen();
                                    } else {
                                      print(
                                          "-----------------------here---------------------");
                                      setState(() {
                                        _loginStatus = "fbnewuserOtpNew";
                                        //should go to stepone after verify
                                      });

                                      print("login status - " + _loginStatus);
                                      log("fb new user who doesnt hvae an otp login");

                                      final _fbId = widget.fbId;
                                      final _fbName = widget.fbName;
                                      final _fbEmail = widget.fbEmail;
                                      final _fbPicUrl = widget.fbPicUrl;
                                      pr.hide();
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  VerifyPhoneScreen(
                                                    phone: phoneNum,
                                                    fbId: _fbId,
                                                    fbName: _fbName,
                                                    fbEmail: _fbEmail,
                                                    fbPicUrl: _fbPicUrl,
                                                    loginType: widget.loginType,
                                                    loginStatus: _loginStatus,
                                                  )));
                                    }
                                  }
                                } catch (err) {
                                  pr.hide();
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              'check your internet connection'),
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

                                //puka

                              }
                            }

                            // Navigator.of(context).pushNamed("/pincode");
                          } else {
                            pr.hide();
                            setState(() {
                              _errorTxt = AppLocalizations.of(context)
                                  .translate('c_code_needed');
                            });
                          }
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width / 1.15,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF6038), Color(0xFFFF9006)],
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('next_btn')
                                  .toUpperCase(),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Padding(
                //     padding: const EdgeInsets.only(top: 8.0),
                //     child: isClicked ? showLoader() : null),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool checkNull() {
    if (_phoneNo.text == '') {
      return false;
    } else {
      return true;
    }
  }

  // isCountryCode(){
  //   if(_countrycode == ''){
  //     setState(() {
  //       _errorTxt = "Select your country code";
  //     });
  //   }
  //   else{
  //     setState(() {
  //       _errorTxt = "";
  //     });
  //   }
  // }

  bool validatePhone() {
    if (_countrycode == '') {
      setState(() {
        _errorTxt = AppLocalizations.of(context).translate('err_select_c_code');
      });
      return false;
    } else if (_phoneNo.text.length >= 9) {
      print("valid 4n number");
      return true;
    } else {
      setState(() {
        _errorTxt = AppLocalizations.of(context).translate('err_shoub_be_9');
      });
      return false;
    }
  }

  // Future<bool> navigateToLogin() {
  //   return showDialog(
  //     builder: (context) => CupertinoAlertDialog(
  //       title: Text('You already have an Otp login with this number !'),
  //       content: Column(
  //         children: <Widget>[
  //           Padding(
  //             padding: const EdgeInsets.only(top:8.0),
  //             child: Text("Try login with phone number !"),
  //           ),
  //         ],
  //       ),
  //       actions: <Widget>[
  //         FlatButton(
  //           color: Colors.orange,
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             Navigator.of(context).pop();
  //           },
  //           child: Text('Go Back To Login',
  //               style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 14,
  //                         fontFamily: 'Montserrat',
  //                         fontWeight: FontWeight.bold
  //                       ),
  //           ),
  //         )
  //       ],
  //     ),
  //     context: context,
  //   );
  //   false;
  // }

  navigateToVerifyingScreen() {
    final _phone = phoneNum;
    final _fbId = widget.fbId;
    final _fbName = widget.fbName;
    final _fbEmail = widget.fbEmail;
    final _fbPicUrl = widget.fbPicUrl;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyPhoneScreen(
            phone: _phone,
            fbId: _fbId,
            fbName: _fbName,
            fbEmail: _fbEmail,
            fbPicUrl: _fbPicUrl,
            loginStatus: _loginStatus,
            loginType: widget.loginType),
      ),
    );
  }

  // bool checklength() {
  //   if (_phoneNo.text == '') {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }
}
