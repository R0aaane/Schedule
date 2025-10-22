import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '/schedule.dart';
import 'scheduleadd.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Schedule> schedules = [];

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
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return Card(
            child: ListTile(
              leading: Image.file(File(schedule.imagePath), width: 80, fit: BoxFit.cover),
              title: Text(schedule.title),
              subtitle: Text(schedule.description),
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