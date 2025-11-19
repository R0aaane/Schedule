import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../providers/app_state.dart';

class ScheduleDetailScreen extends StatelessWidget {

  final Schedule schedule;

  // コンストラクタで、表示したいスケジュールのデータを受け取る

  const ScheduleDetailScreen({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        title: const Text('詳細'),

        actions: [

          // ここでも削除できるようにしておくと便利

          IconButton(

            icon: const Icon(Icons.delete),

            tooltip: '削除',

            onPressed: () {
              // 削除確認ダイアログ

              showDialog(

                context: context,

                builder: (ctx) =>
                    AlertDialog(

                      title: const Text('削除しますか？'),

                      content: const Text('この操作は取り消せません。'),

                      actions: [

                        TextButton(

                          onPressed: () => Navigator.pop(ctx),

                          child: const Text('キャンセル'),

                        ),

                        TextButton(

                          onPressed: () {
                            // 削除実行

                            context.read<AppState>().deleteSchedule(
                                schedule.id);

                            Navigator.pop(ctx); // ダイアログを閉じる

                            Navigator.pop(context); // 詳細画面を閉じて一覧に戻る

                            ScaffoldMessenger.of(context).showSnackBar(

                              const SnackBar(content: Text('削除しました')),

                            );
                          },

                          child: const Text(
                              '削除', style: TextStyle(color: Colors.red)),

                        ),

                      ],

                    ),

              );
            },

          ),

        ],

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(24),

        child: Center(

          child: Container(

            constraints: const BoxConstraints(maxWidth: 800), // Webで見やすい幅制限

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // タイトル

                Text(

                  schedule.title,

                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(

                    fontWeight: FontWeight.bold,

                  ),

                ),

                const SizedBox(height: 20),

                // 日時表示エリア

                Row(

                  children: [

                    const Icon(Icons.access_time, color: Colors.grey),

                    const SizedBox(width: 8),

                    Text(

                      DateFormat('yyyy年MM月dd日(E) HH:mm', 'ja').format(
                          schedule.date),

                      style: const TextStyle(
                          fontSize: 18, color: Colors.black87),

                    ),

                  ],

                ),

                const Divider(height: 40),

                // 詳細テキスト

                const Text(

                  '詳細メモ',

                  style: TextStyle(fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),

                ),

                const SizedBox(height: 8),

                Text(

                  schedule.description.isEmpty ? '（詳細はありません）' : schedule
                      .description,

                  style: const TextStyle(fontSize: 16, height: 1.6),

                ),

              ],

            ),

          ),

        ),

      ),

    );
  }

}