import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String title;
  final bool isDone;

  const Task({required this.title, this.isDone = false});

  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        isDone: json['isDone'] ?? false,
      );

  @override
  List<Object?> get props => [title, isDone];
}
