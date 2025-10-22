import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:schedule/schedule.dart';

class AddSchedulePage extends StatefulWidget {
  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _imagePath;

  Future<void> _pickImage() async {
    // image_pickerパッケージを使って画像選択
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _saveSchedule() {
    // 保存処理（後でHiveやSQLiteに接続）
    final newSchedule = Schedule(
      title: _titleController.text,
      description: _descController.text,
      imagePath: _imagePath ?? '',
      date: DateTime.now(),
    );
    // 保存処理を追加
    Navigator.pop(context, newSchedule); // 戻る
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('予定を追加')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'タイトル')),
            TextField(controller: _descController, decoration: InputDecoration(labelText: '説明')),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text('画像を選択'),
            ),
            if (_imagePath != null)
              Image.file(File(_imagePath!), height: 100),
            Spacer(),
            ElevatedButton(
              onPressed: _saveSchedule,
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
