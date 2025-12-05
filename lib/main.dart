import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

import 'blocs/task_bloc.dart';
import 'blocs/task_event.dart';
import 'constants.dart';
import 'screens/todo_screen.dart';
import 'services/task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TodoScreen(),
        ),
      ],
    );

    return BlocProvider(
      create: (context) => TaskBloc(TaskService())..add(LoadTasks()),
      child: MaterialApp.router(
        routerConfig: router,
        title: appTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
