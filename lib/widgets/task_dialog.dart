import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/task_bloc.dart';
import '../blocs/task_event.dart';
import '../constants.dart';

class TaskDialog extends StatelessWidget {
  final int? index;
  final String? currentTitle;
  final TextEditingController _textEditingController = TextEditingController();

  TaskDialog({super.key, this.index, this.currentTitle}) {
    if (currentTitle != null) {
      _textEditingController.text = currentTitle!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(index == null ? addTaskDialogTitle : editTaskDialogTitle),
      content: TextField(
        controller: _textEditingController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: taskHintText,
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(cancelButton),
        ),
        TextButton(
          onPressed: () {
            if (_textEditingController.text.isNotEmpty) {
              if (index == null) {
                context
                    .read<TaskBloc>()
                    .add(AddTask(_textEditingController.text));
              } else {
                context.read<TaskBloc>().add(
                      UpdateTask(index!, _textEditingController.text),
                    );
              }
              Navigator.pop(context);
            }
          },
          child: Text(index == null ? addTaskButton : updateTaskButton),
        ),
      ],
    );
  }
}
