import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String companyName;
  final DateTime date;
  final String role;

  Todo({
    required this.id,
    required this.companyName,
    required this.date,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'date': date,
      'role': role,
    };
  }
}

class TodoUpdate extends StatefulWidget {
  final String? todoId;

  TodoUpdate({Key? key, this.todoId}) : super(key: key);

  @override
  _TodoUpdateState createState() => _TodoUpdateState();
}

class _TodoUpdateState extends State<TodoUpdate> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyNameController;
  late TextEditingController _dateController;
  late TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _dateController = TextEditingController();
    _roleController = TextEditingController();
    if (widget.todoId != null) {
      _loadTodo();
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _dateController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _loadTodo() {
    FirebaseFirestore.instance.collection('todos').doc(widget.todoId).get().then((doc) {
      if (doc.exists) {
        setState(() {
          _companyNameController.text = doc['companyName'];
          _dateController.text = doc['date'];
          _roleController.text = doc['role'];
        });
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Todo todo = Todo(
        id: widget.todoId ?? '',
        companyName: _companyNameController.text,
        date: DateTime.parse(_dateController.text),
        role: _roleController.text,
      );

      try {
        if (widget.todoId != null) {
          await FirebaseFirestore.instance.collection('Todo').doc(widget.todoId).update(todo.toMap());
        } else {
          await FirebaseFirestore.instance.collection('Todo').add(todo.toMap());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.todoId != null ? 'Todo updated' : 'Todo added')),
        );

        _formKey.currentState!.reset();
        _companyNameController.clear();
        _dateController.clear();
        _roleController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${widget.todoId != null ? 'update' : 'add'} todo: $e')),
        );
      }
    }
  }

  Future<void> _deleteTodo() async {
    try {
      await FirebaseFirestore.instance.collection('todos').doc(widget.todoId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todo deleted')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete todo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todoId != null ? 'Edit Todo' : 'Add Todo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(labelText: 'Company Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _roleController,
                decoration: InputDecoration(labelText: 'Role'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter role';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(widget.todoId != null ? 'Update' : 'Add'),
                  ),
                  if (widget.todoId != null)
                    ElevatedButton(
                      onPressed: _deleteTodo,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      child: Text('Delete'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
