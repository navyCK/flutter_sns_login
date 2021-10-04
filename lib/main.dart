import 'package:flutter/material.dart';
import 'package:flutter_sns_login/home.dart';
import 'package:flutter_sns_login/screen/main_screen.dart';
import 'package:flutter_sns_login/screen/login_screen.dart';
import 'package:flutter_sns_login/screen/splash_screen.dart';
import 'package:kakao_flutter_sdk/all.dart';

void main() {
  KakaoContext.clientId = "1128cbbb1c703ee9eaa67949532000be";
  KakaoContext.javascriptClientId = "cd3f6202868247b8475acc67c5686064";
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '성경',
      debugShowCheckedModeBanner: false,  // debug, release 라벨 제거
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(),
        '/home': (context) => Home(),
      },
    );
  }
}
