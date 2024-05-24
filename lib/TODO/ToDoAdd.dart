import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  // Convert Todo object to a map
  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'date': date,
      'role': role,
    };
  }
}
class TodoAdd extends StatefulWidget {
  @override
  _TodoAddState createState() => _TodoAddState();
}

class _TodoAddState extends State<TodoAdd> {
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
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _dateController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Create a new Todo object
      Todo todo = Todo(
        id: '',
        companyName: _companyNameController.text,
        date: DateTime.parse(_dateController.text),
        role: _roleController.text,
      );

      try {
        // Add the Todo object to Firestore
        await FirebaseFirestore.instance.collection('Todo').add(todo.toMap());

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Todo added successfully')),
        );

        // Clear the form
        _formKey.currentState!.reset();
        _companyNameController.clear();
        _dateController.clear();
        _roleController.clear();
      } catch (e) {
        // Show an error message if adding the todo fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add todo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Todo'),
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
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}