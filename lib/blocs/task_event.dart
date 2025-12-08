import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String title;
  final DateTime? deadline;

  const AddTask(this.title, this.deadline);

  @override
  List<Object> get props => [title, deadline ?? ''];
}

class UpdateTask extends TaskEvent {
  final int id;
  final String newTitle;
  final DateTime? deadline;

  const UpdateTask(this.id, this.newTitle, this.deadline);

  @override
  List<Object> get props => [id, newTitle, deadline ?? ''];
}

class ToggleTask extends TaskEvent {
  final int id;

  const ToggleTask(this.id);

  @override
  List<Object> get props => [id];
}

class DeleteTask extends TaskEvent {
  final int id;

  const DeleteTask(this.id);

  @override
  List<Object> get props => [id];
}
