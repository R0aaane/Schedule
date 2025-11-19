import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedule/screens/schedule.dart';
import '../providers/app_state.dart'; // 状態管理
import '../models/schedule.dart';     // モデル
import '../screens/setting.dart'; //設定画面
import '../screens/list-add.dart'; //スケジュール追加

class ScheduleListScreen extends StatelessWidget {

  const ScheduleListScreen({super.key});

  @override

  Widget build(BuildContext context) {

    final appState = context.read<AppState>();

    return Scaffold(

      appBar: AppBar(

        // StreamBuilderを使って、タイトル部分にユーザー名を表示

        title: StreamBuilder<DocumentSnapshot>(

          stream: appState.myProfileStream,

          builder: (context, snapshot) {

            final data = snapshot.data?.data() as Map<String, dynamic>?;

            final name = data?['displayName'] ?? 'ゲスト';

            return Text('$name の予定');

          },

        ),

        actions: [

          // 設定画面への遷移ボタン

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

      body: StreamBuilder<List<Schedule>>(

        stream: appState.mySchedulesStream,

        builder: (context, snapshot) {

          if (snapshot.hasError) return const Center(child: Text('エラーが発生しました'));

          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final schedules = snapshot.data ?? [];

          if (schedules.isEmpty) return const Center(child: Text('予定がありません'));

          return ListView.builder(

            padding: const EdgeInsets.all(16),

            itemCount: schedules.length,

            itemBuilder: (context, index) {

              final item = schedules[index];

              return Card(

                child: ListTile(

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (conetext) => ScheduleDetailScreen(schedule: item),
                      ),
                    );
                  },

                  leading: CircleAvatar(child: Text('${item.date.day}')),

                  title: Text(item.title),

                  subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(item.date)),

                  trailing: IconButton(

                    icon: const Icon(Icons.delete, color: Colors.grey),

                    onPressed: () => appState.deleteSchedule(item.id),

                  ),

                ),

              );

            },

          );

        },

      ),

      floatingActionButton: FloatingActionButton(

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(builder: (context) => const AddScheduleScreen()),

          );

        },

        child: const Icon(Icons.add),

      ),

    );

  }

}
