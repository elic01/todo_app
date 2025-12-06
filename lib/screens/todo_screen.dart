import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/task_bloc.dart';
import '../blocs/task_event.dart';
import '../blocs/task_state.dart';
import '../constants.dart';
import '../models/task.dart';
import '../widgets/task_dialog.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  void _showTaskDialog(BuildContext context, {int? index, String? currentTitle}) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        index: index,
        currentTitle: currentTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(myTasksTitle),
          centerTitle: true,
          backgroundColor: primaryAccentColor,
          foregroundColor: primaryTextColor,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
            labelColor: primaryTextColor,
            unselectedLabelColor: primaryTextColor,
            indicatorColor: primaryTextColor,
          ),
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TaskLoadFailure) {
              return const Center(child: Text('Failed to load tasks'));
            }
            if (state is TaskLoadSuccess) {
              final pendingTasks = state.tasks.where((task) => !task.isDone).toList();
              final completedTasks = state.tasks.where((task) => task.isDone).toList();

              return TabBarView(
                children: [
                  _buildTaskList(context, pendingTasks, isPending: true),
                  _buildTaskList(context, completedTasks, isPending: false),
                ],
              );
            }
            return const Center(child: Text('Something went wrong!'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showTaskDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<Task> tasks, {required bool isPending}) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          isPending ? noTasksYet : 'No completed tasks yet.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: hintTextColor),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final task = tasks[index];
        // Find the original index of the task in the main list
        final originalIndex = (context.read<TaskBloc>().state as TaskLoadSuccess)
            .tasks
            .indexOf(task);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: Checkbox(
              value: task.isDone,
              onChanged: (val) =>
                  context.read<TaskBloc>().add(ToggleTask(originalIndex)),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: task.isDone ? hintTextColor : secondaryTextColor,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: primaryColor),
                  onPressed: () => _showTaskDialog(
                    context,
                    index: originalIndex,
                    currentTitle: task.title,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: errorColor),
                  onPressed: () =>
                      context.read<TaskBloc>().add(DeleteTask(originalIndex)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
