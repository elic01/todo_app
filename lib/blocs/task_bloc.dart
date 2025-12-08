import 'package:bloc/bloc.dart';

import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/task_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService _taskService;
  final NotificationService _notificationService;

  TaskBloc(this._taskService, this._notificationService) : super(TaskInitial()) {
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
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch,
          title: event.title,
          deadline: event.deadline,
        );

        final updatedTasks = List<Task>.from(state.tasks)..add(newTask);
        _taskService.saveTasks(updatedTasks);

        if (newTask.deadline != null && !newTask.isDone) {
          _notificationService.scheduleNotification(
            newTask.id,
            'Task Deadline',
            'Your task "${newTask.title}" is due.',
            newTask.deadline!,
          );
        }

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
        final updatedTasks = state.tasks.map((task) {
          if (task.id == event.id) {
            final updatedTask = Task(
              id: task.id,
              title: event.newTitle,
              isDone: task.isDone,
              deadline: event.deadline,
            );

            if (updatedTask.deadline != null && !updatedTask.isDone) {
              _notificationService.scheduleNotification(
                updatedTask.id,
                'Task Deadline',
                'Your task "${updatedTask.title}" is due.',
                updatedTask.deadline!,
              );
            } else {
              _notificationService.cancelNotification(task.id);
            }

            return updatedTask;
          }
          return task;
        }).toList();

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
        final updatedTasks = state.tasks.map((task) {
          if (task.id == event.id) {
            final updatedTask = Task(
              id: task.id,
              title: task.title,
              isDone: !task.isDone,
              deadline: task.deadline,
            );

            if (updatedTask.isDone) {
              _notificationService.cancelNotification(task.id);
            } else if (updatedTask.deadline != null) {
              _notificationService.scheduleNotification(
                updatedTask.id,
                'Task Deadline',
                'Your task "${updatedTask.title}" is due.',
                updatedTask.deadline!,
              );
            }

            return updatedTask;
          }
          return task;
        }).toList();

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
        final updatedTasks = state.tasks.where((task) => task.id != event.id).toList();
        _taskService.saveTasks(updatedTasks);
        _notificationService.cancelNotification(event.id);
        emit(TaskLoadSuccess(updatedTasks));
      } catch (_) {
        emit(TaskLoadFailure());
      }
    }
  }
}
