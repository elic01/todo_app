import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// --------------------------------------------------------------------------
// 1. THE MODEL
// Defines what a 'Task' looks like and how to convert it to/from JSON
// --------------------------------------------------------------------------
class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});

  // Convert a Task object to a Map (JSON) for storage
  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
      };

  // Create a Task object from a Map (JSON)
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        isDone: json['isDone'] ?? false,
      );
}

// --------------------------------------------------------------------------
// 2. THE CONTROLLER
// Handles the logic: Loading, Adding, Updating, and Saving data
// --------------------------------------------------------------------------
class TaskController extends GetxController {
  // The list of tasks, observed by GetX (.obs makes it reactive)
  var tasks = <Task>[].obs;
  
  // Instance of GetStorage
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Retrieve data when the app starts
    List? storedTasks = box.read<List>('tasks');
    
    if (storedTasks != null) {
      // Convert the raw JSON list back into Task objects
      tasks.assignAll(storedTasks.map((e) => Task.fromJson(e)).toList());
    }
  }

  // Helper method to save current list to storage
  void saveData() {
    box.write('tasks', tasks.map((e) => e.toJson()).toList());
  }

  void addTask(String title) {
    tasks.add(Task(title: title));
    saveData(); // Save to storage immediately
  }

  void updateTask(int index, String newTitle) {
    tasks[index].title = newTitle;
    tasks.refresh(); // Notify UI of deep change
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

// --------------------------------------------------------------------------
// 3. THE VIEW (UI)
// The visual interface of the app
// --------------------------------------------------------------------------
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage before running the app
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
  // Inject the controller
  final TaskController controller = Get.put(TaskController());
  final TextEditingController textEditingController = TextEditingController();

  TodoScreen({super.key});

  // Helper function to show Add/Edit Dialog
  void showTaskDialog(BuildContext context, {int? index}) {
    // If index is provided, we are editing, so pre-fill the text
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
            // Add Mode
            controller.addTask(textEditingController.text);
          } else {
            // Edit Mode
            controller.updateTask(index, textEditingController.text);
          }
          Get.back(); // Close dialog
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
      // Obx is a widget that listens to the controller's observables
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
                    // Edit Button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showTaskDialog(context, index: index),
                    ),
                    // Delete Button
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