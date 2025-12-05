import 'package:equatable/equatable.dart';

import '../models/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String title;

  const AddTask(this.title);

  @override
  List<Object> get props => [title];
}

class UpdateTask extends TaskEvent {
  final int index;
  final String newTitle;

  const UpdateTask(this.index, this.newTitle);

  @override
  List<Object> get props => [index, newTitle];
}

class ToggleTask extends TaskEvent {
  final int index;

  const ToggleTask(this.index);

  @override
  List<Object> get props => [index];
}

class DeleteTask extends TaskEvent {
  final int index;

  const DeleteTask(this.index);

  @override
  List<Object> get props => [index];
}
