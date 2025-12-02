import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});


  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        isDone: json['isDone'] ?? false,
      );
}

class TaskController extends GetxController {
  var tasks = <Task>[].obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    List? storedTasks = box.read<List>('tasks');
    
    if (storedTasks != null) {
      tasks.assignAll(storedTasks.map((e) => Task.fromJson(e)).toList());
    }
  }

  void saveData() {
    box.write('tasks', tasks.map((e) => e.toJson()).toList());
  }

  void addTask(String title) {
    tasks.add(Task(title: title));
    saveData();
  }

  void updateTask(int index, String newTitle) {
    tasks[index].title = newTitle;
    tasks.refresh();
    saveData();
  }

  void toggleTask(int index) {
    tasks[index].isDone = !tasks[index].isDone;
    tasks.refresh();
    saveData();
  }

  void deleteTask(int index) {
    tasks.removeAt(index);
    saveData();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetStorage ToDo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: TodoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoScreen extends StatelessWidget {
  final TaskController controller = Get.put(TaskController());
  final TextEditingController textEditingController = TextEditingController();
  TodoScreen({super.key});

  void showTaskDialog(BuildContext context, {int? index}) {
    if (index != null) {
      textEditingController.text = controller.tasks[index].title;
    } else {
      textEditingController.clear();
    }

    Get.defaultDialog(
      title: index == null ? "Add New Task" : "Edit Task",
      content: TextField(
        controller: textEditingController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "Enter task here...",
          border: OutlineInputBorder(),
        ),
      ),
      textConfirm: index == null ? "Add" : "Update",
      textCancel: "Cancel",
      onConfirm: () {
        if (textEditingController.text.isNotEmpty) {
          if (index == null) {
            controller.addTask(textEditingController.text);
          } else {
            controller.updateTask(index, textEditingController.text);
          }
          Get.back();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.tasks.isEmpty) {
          return const Center(
            child: Text(
              "No tasks yet.\nTap + to add one!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.tasks.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final task = controller.tasks[index];
            
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: Checkbox(
                  value: task.isDone,
                  onChanged: (val) => controller.toggleTask(index),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isDone ? Colors.grey : Colors.black,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showTaskDialog(context, index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.deleteTask(index),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}