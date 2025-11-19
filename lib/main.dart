import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

import '../providers/app_state.dart'; // 状態管理
import '../models/schedule.dart';     // モデル
import '../screens/setting.dart'; //設定画面
import '../screens/list-add.dart'; //スケジュール追加
import '../screens/list-schedule.dart'; //スケジュール追加
import '../screens/login.dart'; //ログイン

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(

    ChangeNotifierProvider(

      create: (context) => AppState(),

      child: const MyApp(),

    ),

  );

}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Firebase Schedule App',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),

      home: const AuthGate(),

    );

  }

}

class AuthGate extends StatelessWidget {

  const AuthGate({super.key});

  @override

  Widget build(BuildContext context) {

    final user = context.select((AppState s) => s.user);

    return user != null ? const ScheduleListScreen() : const LoginScreen();

  }

}
