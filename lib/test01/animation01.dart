import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // 画面の中央に配置
        body: Center(
          child: MyAnimatedBox(),
        ),
      ),
    );
  }
}

// アニメーションする箱のWidget
class MyAnimatedBox extends StatefulWidget {
  const MyAnimatedBox({super.key});

  @override
  State<MyAnimatedBox> createState() => _MyAnimatedBoxState();
}

class _MyAnimatedBoxState extends State<MyAnimatedBox> {
  // 箱の状態を管理する変数（最初は「false」にしておく）
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 画面（箱）をタップした時の動作
      onTap: () {
        setState(() {
          // true と false を切り替える（スイッチのような役割）
          _isExpanded = !_isExpanded;
        });
      },
      // ★ここが主役！ AnimatedContainer
      child: AnimatedContainer(
        // 1. アニメーションにかける時間（1秒）
        duration: const Duration(seconds: 1),
        
        // 2. アニメーションの動き方（ボヨンと跳ねる動き）
        curve: Curves.elasticOut,

        // 3. 変化させたいプロパティ（_isExpandedの値によって切り替える）
        // 幅：trueなら300、falseなら100
        width: _isExpanded ? 300.0 : 100.0,
        // 高さ
        height: _isExpanded ? 300.0 : 100.0,
        // 色
        color: _isExpanded ? Colors.blue : Colors.orange,
        // アライメント（中の文字の位置）
        alignment: _isExpanded ? Alignment.center : AlignmentDirectional.topCenter,
        
        // 4. 中身（テキストなど）
        child: const Text(
          'Tap Me!',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}