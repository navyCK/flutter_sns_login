import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isDialogVisible = false; // 다이얼로그 visible

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text("로그인 중..."),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    new Future.delayed(new Duration(seconds: 2), () {
      Navigator.pop(context); //pop dialog
      Navigator.pop(context); //pop dialog
      // _login();
    });
  }

  void _signGuest() {
    _onLoading();
    FirebaseAuth.instance.signInAnonymously();
  }

  void _loading() {
    FutureBuilder(
        future: signInWithGoogle(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          }
          //error가 발생하게 될 경우 반환하게 되는 부분
          else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 15),
              ),
            );
          }
          // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
          else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                snapshot.data.toString(),
                style: TextStyle(fontSize: 15),
              ),
            );
          }
        });
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    _onLoading();
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    _onLoading();
    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  Future<UserCredential> signInWithKaKao() async {
    final clientState = Uuid().v4();
    final url = Uri.https('kauth.kakao.com', '/oauth/authorize', {
      'response_type': 'code',
      'client_id': "d8625d4e2554d69009f8ffb7f3d30e64",
      'response_mode': 'form_post',
      'redirect_uri':
          'https://pinnate-alpine-passionfruit.glitch.me/callbacks/kakao/sign_in',
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: "webauthcallback");
    final body = Uri.parse(result).queryParameters;
    print(body["code"]);

    final tokenUrl = Uri.https('kauth.kakao.com', '/oauth/token', {
      'grant_type': 'authorization_code',
      'client_id': "d8625d4e2554d69009f8ffb7f3d30e64",
      'redirect_uri':
          'https://pinnate-alpine-passionfruit.glitch.me/callbacks/kakao/sign_in',
      'code': body["code"],
    });
    var responseTokens = await http.post(Uri.parse(tokenUrl.toString()));
    Map<String, dynamic> bodys = json.decode(responseTokens.body);
    var response = await http.post(
        Uri.parse(
            'https://pinnate-alpine-passionfruit.glitch.me/callbacks/kakao/token'),
        body: {"accessToken": bodys['access_token']});
    _onLoading();
    return FirebaseAuth.instance.signInWithCustomToken(response.body);
  }

  Future<UserCredential> signInWithNaver() async {
    final clientState = Uuid().v4();
    final url = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
      'response_type': 'code',
      'client_id': "VVq0rj0r52jTE2vV9lqQ",
      'redirect_uri':
          'https://pinnate-alpine-passionfruit.glitch.me/callbacks/naver/sign_in',
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: "webauthcallback");
    final body = Uri.parse(result).queryParameters;

    final tokenUrl = Uri.https('nid.naver.com', '/oauth2.0/token', {
      'grant_type': 'authorization_code',
      'client_id': "VVq0rj0r52jTE2vV9lqQ",
      'client_secret': "WpFnn3C606",
      'code': body["code"],
      'state': clientState,
    });
    var responseTokens = await http.post(Uri.parse(tokenUrl.toString()));
    Map<String, dynamic> bodys = json.decode(responseTokens.body);
    var response = await http.post(
        Uri.parse(
            "https://pinnate-alpine-passionfruit.glitch.me/callbacks/naver/token"),
        body: {"accessToken": bodys['access_token']});
    _onLoading();
    return FirebaseAuth.instance.signInWithCustomToken(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildElevatedButton(
                  _loading, "assets/icon/icon_google.png", "구글 로그인", Color(0xffffffff), Colors.black54
              ),

              buildElevatedButton(
                  signInWithFacebook, "assets/icon/icon_facebook.png", "페이스북 로그인", Color(0xff3B5998), Colors.white
              ),

              // 테스트 모드에선 오류 발생 - 이메일 필수 동의가 아니기 때문에 정식 출시 시 이메일 필수 동의하기.
              buildElevatedButton(
                  signInWithKaKao, "assets/icon/icon_kakao.png", "카카오 로그인", Color(0xffFEE500), Colors.black87
              ),

              buildElevatedButton(
                  signInWithNaver, "assets/icon/icon_naver.png", "네이버 로그인", Color(0xff1DC800), Colors.white
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("또는"),
              ),

              buildElevatedButton(
                  _signGuest, "assets/icon/icon_guest.png", "게스트로 이용", Color(0xffDCDCDC), Colors.black87
              ),

              Visibility(
                  visible: _isDialogVisible,
                  child: Container(
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton buildElevatedButton(Function() portal, String imgSrc, String text, Color bgColor, Color textColor) {
    return ElevatedButton.icon(
              onPressed: portal,
              icon: Image.asset(
                imgSrc,
                height: 18,
              ),
              label: Text(text),
              style: ElevatedButton.styleFrom(
                  fixedSize: Size(280, 40),
                  primary: bgColor,
                  onPrimary: textColor,
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
              ),
          );
  }
}
