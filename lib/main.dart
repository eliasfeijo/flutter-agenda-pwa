import 'package:flutter/material.dart';
import 'package:duration_picker/duration_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Tasks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class TaskForm extends StatefulWidget {
  const TaskForm({super.key});
  // This widget is the form for scheduling a new task.
  final String formHeading = 'Schedule a new task';
  final String title = '';
  final DateTime? beginsAt = null;
  final Duration? duration = null;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedBeginDate;
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    _selectedBeginDate = widget.beginsAt;
    _duration = widget.duration ?? const Duration(hours: 1);
  }

  Future<void> _selectDuration(BuildContext context) async {
    final Duration? picked = await showDurationPicker(
      context: context,
      initialTime: _duration ?? const Duration(hours: 1),
    );
    if (picked != null && picked != _duration) {
      setState(() {
        _duration = picked;
      });
    }
  }

  Future<void> _selectDateBegin(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBeginDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedBeginDate) {
      setState(() {
        _selectedBeginDate = pickedDate;
      });
      if(context.mounted) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            _selectedBeginDate = DateTime(
              _selectedBeginDate?.year ?? DateTime.now().year,
              _selectedBeginDate?.month ?? DateTime.now().month,
              _selectedBeginDate?.day ?? DateTime.now().day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });
        }
      }
    }
  }

  void _submitForm() {
    // This function can be used to handle form submission logic
    // For now, it just prints the values to the console
    print('Title: ${_titleController.text}');
    print('Begins at: $_selectedBeginDate');
    print('Duration: $_duration');
    // Show a snackbar for feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text('Task Scheduled')
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        width: 160,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 48, maxWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child:Text(
                widget.formHeading,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            Row(
              // Date/Time input (Begins at)
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Begins at:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 12.0),
                  ),
                  onPressed: () => _selectDateBegin(context),
                  child: Text(
                    _selectedBeginDate == null
                        ? 'Now'
                        : '${'${_selectedBeginDate!.toLocal()}'.split(' ')[0]} ${_selectedBeginDate!.toLocal().hour}:${_selectedBeginDate!.toLocal().minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ],
            ),
            Row(
              // Duration input
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Duration:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 12.0),
                  ),
                  onPressed: () => _selectDuration(context),
                  child: Text(
                    _duration == null
                        ? 'Select Duration'
                        : '${_duration!.inHours}h ${_duration!.inMinutes.remainder(60)}m',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: _submitForm,
                child: const Text('Schedule Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Wrap the TaskForm in a card to give it some padding and a border
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  margin: const EdgeInsets.all(16.0),
                  child: TaskForm(),
                ),
              ],
              )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
