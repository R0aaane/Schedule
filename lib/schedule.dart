import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:schedule/screen/scheduleadd.dart';

class Schedule {
  final String title;
  final String description;
  final String imagePath;
  final DateTime date;

  Schedule({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.date,
  });
}

List<Schedule> schedules = [
  Schedule(
    title: '打ち合わせ',
    description: 'クライアントとの定例会議',
    imagePath: 'assets/images/meeting.jpg',
    date: DateTime(2025, 10, 22),
  ),
  // 他の予定も追加
];

class ScheduleListPage extends StatefulWidget {
  @override
  _ScheduleListPageState createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  List<Schedule> schedules = [
    Schedule(
      title: '打ち合わせ',
      description: 'クライアントとの定例会議',
      imagePath: 'assets/images/meeting.jpg',
      date: DateTime(2025, 10, 22),
    ),
  ];

  void _addSchedule() async {
    final newSchedule = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSchedulePage()),
    );

    if (newSchedule != null && newSchedule is Schedule) {
      setState(() {
        schedules.add(newSchedule);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('スケジュール一覧')),
      body: ListView.builder(
        reverse: true,
        itemCount: schedules.length + 1,
        itemBuilder: (context, index) {
          if (index == schedules.length) {
            return SizedBox(height: 80);
          }

          final schedule = schedules[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Card(
              elevation: 2,
              child: Row(
                children: [
                  Container(
                    width: 120,
                    height: 80,
                    child: Image.file(File(schedule.imagePath), fit: BoxFit.cover),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(schedule.title,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(schedule.description, style: TextStyle(fontSize: 14)),
                          SizedBox(height: 4),
                          Text(
                            '${schedule.date.year}/${schedule.date.month}/${schedule.date.day}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSchedule,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}