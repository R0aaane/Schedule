import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

// ---------------------------------------------------------

// 1. データモデル (Schedule Model)

// ---------------------------------------------------------

class Schedule {

  final String id;

  final String title;

  final DateTime date;

  final String description;

  Schedule({

    required this.id,

    required this.title,

    required this.date,

    this.description = '',

  });

}

// ---------------------------------------------------------

// 2. 状態管理 (Schedule Provider & Auth Logic)

// ---------------------------------------------------------

class AppState extends ChangeNotifier {

  // ログイン状態の管理（簡易版）

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  // スケジュールリストの管理

  final List<Schedule> _schedules = [];

  List<Schedule> get schedules => _schedules;

  // ログイン処理

  bool login(String username, String password) {

    // 実際はここでAPI通信などを行いますが、今回はデモ用に固定値で認証

    if (username == 'admin' && password == 'password') {

      _isLoggedIn = true;

      notifyListeners();

      return true;

    }

    return false;

  }

  // ログアウト処理

  void logout() {

    _isLoggedIn = false;

    notifyListeners();

  }

  // スケジュール追加

  void addSchedule(String title, DateTime date, String description) {

    final newSchedule = Schedule(

      id: DateTime.now().toString(), // IDは簡易的に現在時刻を使用

      title: title,

      date: date,

      description: description,

    );

    _schedules.add(newSchedule);

    // 日付順にソート

    _schedules.sort((a, b) => a.date.compareTo(b.date));

    notifyListeners();

  }

  // スケジュール削除

  void deleteSchedule(String id) {

    _schedules.removeWhere((item) => item.id == id);

    notifyListeners();

  }

}

// ---------------------------------------------------------

// 3. メインエントリポイント (Main)

// ---------------------------------------------------------

void main() {

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

      title: 'Web Schedule Manager',

      debugShowCheckedModeBanner: false, // デバッグバナーを消す

      theme: ThemeData(

        primarySwatch: Colors.blue,

        useMaterial3: true,

      ),

      home: const AuthGate(),

    );

  }

}

// ログイン状態によって画面を切り替えるWidget

class AuthGate extends StatelessWidget {

  const AuthGate({super.key});

  @override

  Widget build(BuildContext context) {

    final appState = context.watch<AppState>();

    return appState.isLoggedIn ? const ScheduleListScreen() : const LoginScreen();

  }

}

// ---------------------------------------------------------

// 4. ログイン画面 (Login Screen)

// ---------------------------------------------------------

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override

  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();

  String _errorMessage = '';

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(

        child: Container(

          width: 400, // Web向けに幅を制限

          padding: const EdgeInsets.all(32),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius: BorderRadius.circular(8),

            boxShadow: [

              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)

            ],

          ),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              const Text('スケジュール管理', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),

              TextField(

                controller: _usernameController,

                decoration: const InputDecoration(labelText: 'ユーザー名 (admin)', border: OutlineInputBorder()),

              ),

              const SizedBox(height: 16),

              TextField(

                controller: _passwordController,

                decoration: const InputDecoration(labelText: 'パスワード (password)', border: OutlineInputBorder()),

                obscureText: true,

              ),

              const SizedBox(height: 8),

              Text(_errorMessage, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 16),

              SizedBox(

                width: double.infinity,

                height: 48,

                child: ElevatedButton(

                  onPressed: () {

                    final success = context.read<AppState>().login(

                      _usernameController.text,

                      _passwordController.text,

                    );

                    if (!success) {

                      setState(() {

                        _errorMessage = 'ユーザー名またはパスワードが違います';

                      });

                    }

                  },

                  child: const Text('ログイン'),

                ),

              ),

            ],

          ),

        ),

      ),

      backgroundColor: Colors.grey[100],

    );

  }

}

// ---------------------------------------------------------

// 5. スケジュール一覧画面 (List Screen)

// ---------------------------------------------------------

class ScheduleListScreen extends StatelessWidget {

  const ScheduleListScreen({super.key});

  @override

  Widget build(BuildContext context) {

    final schedules = context.watch<AppState>().schedules;

    return Scaffold(

      appBar: AppBar(

        title: const Text('スケジュール一覧'),

        actions: [

          IconButton(

            icon: const Icon(Icons.logout),

            tooltip: 'ログアウト',

            onPressed: () => context.read<AppState>().logout(),

          )

        ],

      ),

      body: schedules.isEmpty

          ? const Center(child: Text('予定がありません。右下のボタンから追加してください。'))

          : ListView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: schedules.length,

        itemBuilder: (context, index) {

          final item = schedules[index];

          return Card(

            elevation: 2,

            margin: const EdgeInsets.only(bottom: 12),

            child: ListTile(

              leading: CircleAvatar(

                backgroundColor: Colors.blue[100],

                child: Text(

                  '${item.date.day}',

                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),

                ),

              ),

              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),

              subtitle: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(DateFormat('yyyy/MM/dd HH:mm').format(item.date)),

                  if (item.description.isNotEmpty) Text(item.description),

                ],

              ),

              trailing: IconButton(

                icon: const Icon(Icons.delete, color: Colors.grey),

                onPressed: () {

                  context.read<AppState>().deleteSchedule(item.id);

                  ScaffoldMessenger.of(context).showSnackBar(

                    const SnackBar(content: Text('削除しました')),

                  );

                },

              ),

            ),

          );

        },

      ),

      floatingActionButton: FloatingActionButton.extended(

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(builder: (context) => const AddScheduleScreen()),

          );

        },

        label: const Text('追加'),

        icon: const Icon(Icons.add),

      ),

    );

  }

}

// ---------------------------------------------------------

// 6. スケジュール追加画面 (Add Screen)

// ---------------------------------------------------------

class AddScheduleScreen extends StatefulWidget {

  const AddScheduleScreen({super.key});

  @override

  State<AddScheduleScreen> createState() => _AddScheduleScreenState();

}

class _AddScheduleScreenState extends State<AddScheduleScreen> {

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  final _descController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  TimeOfDay _selectedTime = TimeOfDay.now();

  // 日付選択ピッカー

  Future<void> _pickDate() async {

    final picked = await showDatePicker(

      context: context,

      initialDate: _selectedDate,

      firstDate: DateTime(2000),

      lastDate: DateTime(2100),

    );

    if (picked != null) {

      setState(() => _selectedDate = picked);

    }

  }

  // 時間選択ピッカー

  Future<void> _pickTime() async {

    final picked = await showTimePicker(

      context: context,

      initialTime: _selectedTime,

    );

    if (picked != null) {

      setState(() => _selectedTime = picked);

    }

  }

  void _saveSchedule() {

    if (_formKey.currentState!.validate()) {

      // 日付と時間を結合

      final dateTime = DateTime(

        _selectedDate.year,

        _selectedDate.month,

        _selectedDate.day,

        _selectedTime.hour,

        _selectedTime.minute,

      );

      context.read<AppState>().addSchedule(

        _titleController.text,

        dateTime,

        _descController.text,

      );

      Navigator.pop(context); // 一覧画面に戻る

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('スケジュールを追加しました')),

      );

    }

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text('予定を追加')),

      body: Center(

        child: Container(

          constraints: const BoxConstraints(maxWidth: 600), // Webで見やすいように幅制限

          padding: const EdgeInsets.all(16),

          child: Form(

            key: _formKey,

            child: ListView(

              children: [

                TextFormField(

                  controller: _titleController,

                  decoration: const InputDecoration(labelText: 'タイトル', border: OutlineInputBorder()),

                  validator: (value) => value == null || value.isEmpty ? 'タイトルを入力してください' : null,

                ),

                const SizedBox(height: 20),

                // 日付と時刻の選択行

                Row(

                  children: [

                    Expanded(

                      child: ListTile(

                        title: Text(DateFormat('yyyy/MM/dd').format(_selectedDate)),

                        trailing: const Icon(Icons.calendar_today),

                        shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),

                        onTap: _pickDate,

                      ),

                    ),

                    const SizedBox(width: 10),

                    Expanded(

                      child: ListTile(

                        title: Text(_selectedTime.format(context)),

                        trailing: const Icon(Icons.access_time),

                        shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),

                        onTap: _pickTime,

                      ),

                    ),

                  ],

                ),

                const SizedBox(height: 20),

                TextFormField(

                  controller: _descController,

                  decoration: const InputDecoration(labelText: '詳細（任意）', border: OutlineInputBorder()),

                  maxLines: 3,

                ),

                const SizedBox(height: 30),

                SizedBox(

                  height: 50,

                  child: ElevatedButton(

                    onPressed: _saveSchedule,

                    child: const Text('保存する'),

                  ),

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

}
