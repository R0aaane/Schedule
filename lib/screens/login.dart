import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/app_state.dart'; // 状態管理
import '../models/schedule.dart';     // モデル


class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override

  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _isLoginMode = true;

  String? _errorMessage;

  bool _isLoading = false;

  Future<void> _submit() async {

    setState(() { _isLoading = true; _errorMessage = null; });

    final appState = context.read<AppState>();

    String? error;

    if (_isLoginMode) {

      error = await appState.login(_emailController.text.trim(), _passwordController.text.trim());

    } else {

      error = await appState.register(_emailController.text.trim(), _passwordController.text.trim());

    }

    if (mounted) setState(() { _isLoading = false; if (error != null) _errorMessage = error; });

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(

        child: Container(

          width: 400,

          padding: const EdgeInsets.all(32),

          decoration: BoxDecoration(

            color: Colors.white, borderRadius: BorderRadius.circular(12),

            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],

          ),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              Text(_isLoginMode ? 'ログイン' : '新規登録', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),

              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'メールアドレス', border: OutlineInputBorder())),

              const SizedBox(height: 16),

              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'パスワード', border: OutlineInputBorder())),

              const SizedBox(height: 16),

              if (_errorMessage != null) Text(_errorMessage!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 16),

              _isLoading ? const CircularProgressIndicator() : SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: _submit, child: Text(_isLoginMode ? 'ログイン' : '登録'))),

              const SizedBox(height: 16),

              TextButton(

                onPressed: () => setState(() => _isLoginMode = !_isLoginMode),

                child: Text(_isLoginMode ? '新規作成はこちら' : 'ログインへ戻る'),

              ),

            ],

          ),

        ),

      ),

    );

  }

}
