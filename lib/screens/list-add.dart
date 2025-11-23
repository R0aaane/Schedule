import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
        //新しい画像を選択した場合はリセット
        _initialImageUrl = null;
      });
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

    String? finalImageUrl;

    if (_selectedImageFile != null) {
      //　新しい画像が選択されていた場合はアップロード
      finalImageUrl = await appState.uploadImage(_selectedImageFile!);
      if (finalImageUrl == null) {
        //アップロード失敗
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('画像のアップロードに失敗しました。')));
        }
        return;
      }
      else if (_initialImageUrl != null) {
        //既存画像があればそちらを使用
        finalImageUrl = _initialImageUrl;
      }

      //FireStoreへの書き込み
      if (widget.scheduleToEdit != null) {
        //編集画面へ
        await appState.updateSchedule(
          widget.scheduleToEdit!.id,
          _titleController.text,
          dateTime,
          _descController.text,
          imageUrl: finalImageUrl, //画像Urlを渡す
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('変更を保存しました')));
        }
      } else {
        await appState.addSchedule(
          _titleController.text,
          dateTime,
          _descController.text,
          imageUrl: finalImageUrl, //画像Urlを渡す
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('追加しました')));
        }
      }

      if (mounted) {
        // 編集から戻る際は、詳細画面も閉じるため2回popする
        if (widget.scheduleToEdit != null) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          Navigator.pop(context);
        }
      }
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

              Container(
                height: 200,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _buildImagePreview(),
                ),
              ),
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

  // ★画像プレビューを構築するヘルパー関数
  Widget _buildImagePreview() {
    // 1. 新しく画像が選択された場合
    if (_selectedImageFile != null) {
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
            future:_selectedImageFile!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
            return Image.memory(
              snapshot.data!, //バイトデータで表示
              fit: BoxFit.cover,
              width: double.infinity,
            );
          }
          //データ読み込み中はロード表示
          return const Center(child:
          CircularProgressIndicator());
        },
        );
      } else {
        return Image.file(
          _selectedImageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
        );
      }
    }
    // 2. 既存の画像URLがある場合（編集時）
    if (widget.scheduleToEdit?.imageUrl != null) {
      return Image.network(
        widget.scheduleToEdit!.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
      );
    }

    // 3. 画像がない場合
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.camera_alt, size: 40, color: Colors.grey),
        SizedBox(height: 8),
        Text('タップして写真を選択', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}