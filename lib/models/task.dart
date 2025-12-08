import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String title;
  final bool isDone;
  final DateTime? deadline;

  const Task({
    required this.id,
    required this.title,
    this.isDone = false,
    this.deadline,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
        'deadline': deadline?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch,
        title: json['title'],
        isDone: json['isDone'] ?? false,
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'])
            : null,
      );

  @override
  List<Object?> get props => [id, title, isDone, deadline];
}
