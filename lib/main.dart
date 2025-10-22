import 'package:flutter/material.dart';
import 'package:schedule/screen/title.dart'; // ホーム画面を別ファイルにしている場合

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'スケジュール管理',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // 最初に表示する画面
    );
  }
}