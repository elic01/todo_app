import 'package:bloc/bloc.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService _taskService;

  TaskBloc(this._taskService) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<ToggleTask>(_onToggleTask);
    on<DeleteTask>(_onDeleteTask);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    emit(TaskLoadInProgress());
    try {
      final tasks = _taskService.getTasks();
      emit(TaskLoadSuccess(tasks));
    } catch (_) {
      emit(TaskLoadFailure());
    }
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) {
    final state = this.state;
    if (state is TaskLoadSuccess) {
      try {
        final updatedTasks = List<Task>.from(state.tasks)..add(Task(title: event.title));
        _taskService.saveTasks(updatedTasks);
        emit(TaskLoadSuccess(updatedTasks));
      } catch (_) {
        emit(TaskLoadFailure());
      }
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) {
    final state = this.state;
    if (state is TaskLoadSuccess) {
      try {
        final updatedTasks = List<Task>.from(state.tasks);
        updatedTasks[event.index] = Task(title: event.newTitle, isDone: updatedTasks[event.index].isDone);
        _taskService.saveTasks(updatedTasks);
        emit(TaskLoadSuccess(updatedTasks));
      } catch (_) {
        emit(TaskLoadFailure());
      }
    }
  }

  void _onToggleTask(ToggleTask event, Emitter<TaskState> emit) {
    final state = this.state;
    if (state is TaskLoadSuccess) {
      try {
        final updatedTasks = List<Task>.from(state.tasks);
        final task = updatedTasks[event.index];
        updatedTasks[event.index] = Task(title: task.title, isDone: !task.isDone);
        _taskService.saveTasks(updatedTasks);
        emit(TaskLoadSuccess(updatedTasks));
      } catch (_) {
        emit(TaskLoadFailure());
      }
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) {
    final state = this.state;
    if (state is TaskLoadSuccess) {
      try {
        final updatedTasks = List<Task>.from(state.tasks)..removeAt(event.index);
        _taskService.saveTasks(updatedTasks);
        emit(TaskLoadSuccess(updatedTasks));
      } catch (_) {
        emit(TaskLoadFailure());
      }
    }
  }
}
