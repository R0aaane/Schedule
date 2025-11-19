import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Schedule.fromFirestore(DocumentSnapshot doc) {

    final data = doc.data() as Map<String, dynamic>;

    return Schedule(

      id: doc.id,

      title: data['title'] ?? '',

      date: (data['date'] as Timestamp).toDate(),

      description: data['description'] ?? '',

    );

  }

}
