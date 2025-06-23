import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_flutter/providers/agenda_provider.dart';
import 'package:todo_flutter/repositories/tasks_repository.dart';
import 'package:todo_flutter/screens/task_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AgendaProvider(TasksSharedPreferencesRepository()),
      child: MaterialApp(
        title: 'Agenda',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const TaskList(),
      ),
    );
  }
}
