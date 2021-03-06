import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gank/constant/strings.dart';
import 'package:flutter_gank/event/event_bus.dart';
import 'package:flutter_gank/model/user_model.dart';
import 'package:flutter_gank/net/github_api.dart';
import 'package:flutter_gank/utils/user_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginActivity extends StatefulWidget {
  LoginActivity({Key key}) : super(key: key);

  @override
  _LoginActivityState createState() => new _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity>
    with SingleTickerProviderStateMixin, GithubApi {
  final BasicMessageChannel<String> platform =
      const BasicMessageChannel<String>(
          FLUTTER_MESSAGE_CHANNEL_NAME, const StringCodec());

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();

  TextEditingController signupEmailController = new TextEditingController();
  TextEditingController signupNameController = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();
  TextEditingController signupConfirmPasswordController =
      new TextEditingController();

  Color left = Colors.black;
  Color right = Colors.white;
  Color start = const Color(0xFF00ACC1);
  Color end = const Color(0xFF217CE9);

  MethodChannel flutterNativePlugin;
  String _userName, _password;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [start, end],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[_buildSignIn(context)],
            ),
            SafeArea(
                child: Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 10.0),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 30,
                  )),
            )),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: FlatButton(
                    onPressed: () {},
                    child: Text(
                      STRING_LOGIN_TIP,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontFamily: "WorkSansMedium"),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    flutterNativePlugin = MethodChannel(FLUTTER_NATIVE_PLUGIN_CHANNEL_NAME);
    platform.setMessageHandler(_handlePlatformMessage);
  }

  Future<String> _handlePlatformMessage(String message) async {
    Map pushData = json.decode(message);
    String accessToken = await getAccessToken(pushData['code']);
    await _handleLogin(await getUserInfo(accessToken), context);
    return '';
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 150.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 190.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmailLogin,
                          controller: loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          onChanged: (value) {
                            _userName = value;
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              IconData(0xe653, fontFamily: 'IconFont'),
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: STRING_USERNAME_HINT,
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePasswordLogin,
                          controller: loginPasswordController,
                          obscureText: true,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          onChanged: (value) {
                            _password = value;
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              IconData(0xe659, fontFamily: 'IconFont'),
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: STRING_PASSWORD_HINT,
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 170.0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: start,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: end,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                      colors: [end, start],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: end,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "LOGIN",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontFamily: "WorkSansBold"),
                      ),
                    ),
                    onPressed: () async {
                      bool isSuccess = await login(_userName, _password);
                      await _handleLogin(isSuccess, context);
                    }),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Colors.white10,
                          Colors.white,
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    "Or",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontFamily: "WorkSansMedium"),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white10,
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () async {
                await flutterNativePlugin.invokeMethod(
                    'oAuthInBrowser', {'url': GithubApi.browserOAuth2Url});
              },
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  IconData(0xe612, fontFamily: 'IconFont'),
                  size: 30,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future _handleLogin(bool isSuccess, BuildContext context) async {
    if (isSuccess) {
      Fluttertoast.showToast(
          msg: STRING_LOGIN_SUCCESS,
          backgroundColor: Colors.black,
          gravity: ToastGravity.CENTER,
          textColor: Colors.white);
      User user = await UserUtils.getUser();
      eventBus.fire(LoginEvent(user));
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(
          msg: STRING_LOGIN_FAILED,
          backgroundColor: Colors.black,
          gravity: ToastGravity.CENTER,
          textColor: Colors.white);
    }
  }
}
