import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/app_state.dart'; // 状態管理
import '../models/schedule.dart';     // モデル
import '../screens/setting.dart';     //　設定画面

class AddScheduleScreen extends StatefulWidget {
  // 編集する場合のために、既存のスケジュールを受け取れるようにする（nullなら新規追加）
  final Schedule? scheduleToEdit;
  const AddScheduleScreen({super.key, this.scheduleToEdit});
  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}
class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  File? _selectedImageFile;
  String? _initialImageUrl;

  @override
  void initState() {
    super.initState();
    // 編集モード（データが渡された）なら、その値で初期化する
    if (widget.scheduleToEdit != null) {
      final item = widget.scheduleToEdit!;
      _titleController.text = item.title;
      _descController.text = item.description;
      _selectedDate = item.date;
      _selectedTime = TimeOfDay.fromDateTime(item.date);
      _initialImageUrl = item.imageUrl;
    } else {
      // 新規モードなら現在時刻
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) setState(() => _selectedDate = picked);
  }
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
        context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }
  void _save() async {
    if (_titleController.text.isEmpty) return;
    final dateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );
    final appState = context.read<AppState>();
    if (widget.scheduleToEdit != null) {
      // ★編集モード: 更新処理を呼ぶ
      await appState.updateSchedule(
        widget.scheduleToEdit!.id,
        _titleController.text,
        dateTime,
        _descController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('変更を保存しました')),
        );
      }
    } else {
      await appState.addSchedule(
        _titleController.text,
        dateTime,
        _descController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('追加しました')),
        );
      }
    }
    if (mounted) {
      Navigator.pop(context); // 画面を閉じる
    }
  }
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await
    picker.pickImage(source: ImageSource.gallery);
    if(pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
        //新しい画像を選択したら既存のURLはリセット
        _initialImageUrl = null;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // 画面タイトルを使い分ける
    final isEdit = widget.scheduleToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '予定を編集' : '予定を追加'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'タイトル', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(DateFormat('yyyy/MM/dd').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                onTap: _pickDate,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                onTap: _pickTime,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: '詳細', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEdit ? '変更を保存する' : '追加する'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}