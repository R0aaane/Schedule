import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/app_state.dart'; // 状態管理
import '../models/schedule.dart';     // モデル
import '../screens/setting.dart';     //　設定画面

class AddScheduleScreen extends StatefulWidget {

  const AddScheduleScreen({super.key});

  @override

  State<AddScheduleScreen> createState() => _AddScheduleScreenState();

}

class _AddScheduleScreenState extends State<AddScheduleScreen> {

  final _titleController = TextEditingController();

  final _descController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _pickDate() async {

    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));

    if (picked != null) setState(() => _selectedDate = picked);

  }

  Future<void> _pickTime() async {

    final picked = await showTimePicker(context: context, initialTime: _selectedTime);

    if (picked != null) setState(() => _selectedTime = picked);

  }

  void _save() async {

    if (_titleController.text.isEmpty) return;

    final dateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);

    await context.read<AppState>().addSchedule(_titleController.text, dateTime, _descController.text);

    if (mounted) {

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('追加しました')));

    }

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('予定を追加'),

        actions: [

          // 追加画面にも設定ボタンを配置

          IconButton(

            icon: const Icon(Icons.settings),

            tooltip: '設定',

            onPressed: () {

              Navigator.push(

                context,

                MaterialPageRoute(builder: (context) => const SettingsScreen()),

              );

            },

          ),

        ],

      ),

      body: Center(

        child: Container(

          constraints: const BoxConstraints(maxWidth: 600),

          padding: const EdgeInsets.all(16),

          child: ListView(

            children: [

              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'タイトル')),

              const SizedBox(height: 20),

              ListTile(title: Text(DateFormat('yyyy/MM/dd').format(_selectedDate)), trailing: const Icon(Icons.calendar_today), onTap: _pickDate),

              ListTile(title: Text(_selectedTime.format(context)), trailing: const Icon(Icons.access_time), onTap: _pickTime),

              const SizedBox(height: 20),

              TextField(controller: _descController, decoration: const InputDecoration(labelText: '詳細')),

              const SizedBox(height: 30),

              ElevatedButton(onPressed: _save, child: const Text('保存する')),

            ],

          ),

        ),

      ),

    );

  }

}
