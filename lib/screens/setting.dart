import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 必要に応じて
import '../providers/app_state.dart'; // 状態管理へアクセスするため
import '../models/schedule.dart';     // モデルを使うため

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({super.key});

  @override

  State<SettingsScreen> createState() => _SettingsScreenState();

}

class _SettingsScreenState extends State<SettingsScreen> {

  final _nameController = TextEditingController();

  bool _isLoading = false;

  @override

  void initState() {

    super.initState();

    // 初期値として現在の名前を取得してセットする処理があれば良いですが、

    // ここではStreamBuilderの中で処理するため、buildメソッド内で解決します。

  }

  Future<void> _saveProfile() async {

    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);

    await context.read<AppState>().updateProfileName(_nameController.text);

    if (mounted) {

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('設定を保存しました')));

    }

  }

  @override

  Widget build(BuildContext context) {

    final appState = context.read<AppState>();

    return Scaffold(

      appBar: AppBar(title: const Text('設定')),

      body: StreamBuilder<DocumentSnapshot>(

        stream: appState.myProfileStream,

        builder: (context, snapshot) {

          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          final currentName = data?['displayName'] ?? '未設定';

          // 初回のみ、コントローラーに現在の値をセット（ユーザーが入力を始めたら上書きしないように制御）

          if (_nameController.text.isEmpty && currentName != '未設定') {

            _nameController.text = currentName;

          }

          return Center(

            child: Container(

              constraints: const BoxConstraints(maxWidth: 600),

              padding: const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text('プロフィール設定', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  Text('現在の名前: $currentName', style: const TextStyle(color: Colors.grey)),

                  const SizedBox(height: 10),

                  TextField(

                    controller: _nameController,

                    decoration: const InputDecoration(

                      labelText: '新しい名前',

                      border: OutlineInputBorder(),

                      prefixIcon: Icon(Icons.person),

                    ),

                  ),

                  const SizedBox(height: 20),

                  SizedBox(

                    width: double.infinity,

                    height: 50,

                    child: ElevatedButton(

                      onPressed: _isLoading ? null : _saveProfile,

                      child: _isLoading ? const CircularProgressIndicator() : const Text('名前を保存'),

                    ),

                  ),

                  const Divider(height: 60),

                  const Text('アカウント操作', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  SizedBox(

                    width: double.infinity,

                    child: OutlinedButton.icon(

                      icon: const Icon(Icons.logout),

                      label: const Text('ログアウト'),

                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),

                      onPressed: () {

                        Navigator.pop(context); // 設定画面を閉じる

                        appState.logout();

                      },

                    ),

                  ),

                ],

              ),

            ),

          );

        },

      ),

    );

  }

}
