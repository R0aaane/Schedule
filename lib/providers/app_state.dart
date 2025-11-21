import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/schedule.dart';



class AppState extends ChangeNotifier {

  User? _user;

  User? get user => _user;

  AppState() {

    FirebaseAuth.instance.authStateChanges().listen((User? user) {

      _user = user;

      notifyListeners();

    });

  }

  // 認証関連
  Future<String?> register(String email, String password) async {

    try {

      await FirebaseAuth.instance.createUserWithEmailAndPassword(

          email: email, password: password);

      return null;

    } on FirebaseAuthException catch (e) {

      return e.message;

    }

  }

  Future<String?> login(String email, String password) async {

    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(

          email: email, password: password);

      return null;

    } on FirebaseAuthException catch (e) {

      return e.message;

    }

  }

  Future<void> logout() async {

    await FirebaseAuth.instance.signOut();

  }

  // --- データ操作関連 ---

  Future<String?> uploadImage(File file) async {
    if (_user == null) return null;
    try {
      final String uid = _user!.uid;
      final String fileName = path.basename(file.path);
      // 'users/{uid}/images/{ファイル名}' のパスでStorageにアップロード
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child('images')
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');
      final UploadTask uploadTask = storageRef.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      // アップロードした画像のダウンロードURLを取得
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // スケジュール追加
  Future<void> addSchedule(String title, DateTime date, String description, {String? imageUrl}) async {

    if (_user == null) return;

    await FirebaseFirestore.instance
        .collection('users').doc(_user!.uid).collection('schedules').add({

      'title': title,
      'date': Timestamp.fromDate(date),
      'description': description,
      'imageUrl':imageUrl,
      'createdAt': FieldValue.serverTimestamp(),

    });

  }

  // スケジュール削除
  Future<void> deleteSchedule(String id) async {

    if (_user == null) return;

    await FirebaseFirestore.instance

        .collection('users').doc(_user!.uid).collection('schedules').doc(id).delete();

  }

  Future<void> updateSchedule(String id, String title, DateTime date, String description, {String? imageUrl}) async {
    if (_user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('schedules')
        .doc(id)
        .update({
      'title': title,
      'date': Timestamp.fromDate(date),
      'description': description,
      'imageUrl':imageUrl,
      // createdAtは更新しない（作成日時はそのまま残すため）
    });
  }

  // ユーザー名（プロフィール）の更新
  Future<void> updateProfileName(String name) async {

    if (_user == null) return;

    // users/{uid} ドキュメントに名前を保存（なければ作成、あれば更新）

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({

      'displayName': name,

    }, SetOptions(merge: true));

  }

  // ストリーム: 自分のスケジュール

  Stream<List<Schedule>> get mySchedulesStream {

    if (_user == null) return Stream.value([]);

    return FirebaseFirestore.instance

        .collection('users').doc(_user!.uid).collection('schedules')

        .orderBy('date')

        .snapshots()

        .map((snap) => snap.docs.map((doc) => Schedule.fromFirestore(doc)).toList());

  }

  // ストリーム: 自分のプロフィール情報（名前など）

  Stream<DocumentSnapshot> get myProfileStream {

    if (_user == null) return const Stream.empty();

    return FirebaseFirestore.instance

        .collection('users').doc(_user!.uid).snapshots();

  }

}
