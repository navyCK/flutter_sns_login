import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'intro_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  Future <LoginScreen> _signOut() async {
    await FirebaseAuth.instance.signOut();
    return LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (!snapshot.hasData) {
            print("로그인을 해주세요.");
            return IntroScreen();
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("메인화면"),
                  ElevatedButton(onPressed: () {
                    Navigator.pushNamed(context, '/bible');
                  },
                    child: Text("성경 뷰어"),),
                  Text("${snapshot.data!.displayName}님 환영합니다."),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: CupertinoButton(
                        color: Colors.blue,
                        onPressed: _signOut,
                        child: Text(
                          '로그아웃',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}