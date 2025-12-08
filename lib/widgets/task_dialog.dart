import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/task_bloc.dart';
import '../blocs/task_event.dart';
import '../constants.dart';

class TaskDialog extends StatefulWidget {
  final int? id;
  final String? currentTitle;
  final DateTime? currentDeadline;

  const TaskDialog({
    super.key,
    this.id,
    this.currentTitle,
    this.currentDeadline,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late final TextEditingController _textEditingController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.currentTitle);
    _selectedDate = widget.currentDeadline;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.id == null ? addTaskDialogTitle : editTaskDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: taskHintText,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'No deadline set'
                      : 'Deadline: ${DateFormat.yMd().format(_selectedDate!)}',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(cancelButton),
        ),
        TextButton(
          onPressed: () {
            if (_textEditingController.text.isNotEmpty) {
              if (widget.id == null) {
                context.read<TaskBloc>().add(
                      AddTask(
                        _textEditingController.text,
                        _selectedDate,
                      ),
                    );
              } else {
                context.read<TaskBloc>().add(
                      UpdateTask(
                        widget.id!,
                        _textEditingController.text,
                        _selectedDate,
                      ),
                    );
              }
              Navigator.pop(context);
            }
          },
          child: Text(widget.id == null ? addTaskButton : updateTaskButton),
        ),
      ],
    );
  }
}
