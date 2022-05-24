import 'package:flutter/material.dart';
import 'db.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'To Do'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DbManager dbManager = DbManager();
  late Future<List<Task>> taskList;
  TextEditingController _newTask = TextEditingController();

  void _createTask() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: 180,
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      controller: _newTask,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter the Task',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('Close', style:TextStyle(color: Colors.red),),
                          onPressed: () => {
                            Navigator.pop(context),
                            _newTask.text = "",
                          },
                        ),
                        TextButton(
                          child: const Text('Add',style:TextStyle(color: Colors.black),),
                          onPressed: () => {
                            dbManager.insertTask(_newTask.text),
                            setState(() {
                              taskList = dbManager.getTask();
                            }),
                            _newTask.text = "",
                            Navigator.pop(context)
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    taskList = dbManager.getTask();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: TaskList(list: taskList)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        tooltip: 'Add new Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}


class TaskList extends StatefulWidget {
  TaskList({Key? key, required this.list}) : super(key: key);
  Future<List<Task>> list;
  @override
  _TaskList createState() => _TaskList();
}

class _TaskList extends State<TaskList> {
  final DbManager dbManager = DbManager();

  late Task task;
  late List<Task> taskList;

  deleteTask(int id){
    dbManager.deleteTask(id);
    setState(() {
      widget.list = dbManager.getTask();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: widget.list,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            taskList = snapshot.data as List<Task>;
            return ListView.builder(
              itemCount: taskList.length,
              itemBuilder: (context, index) {
                task = taskList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            task.name,
                            style: const TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteTask(task.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
