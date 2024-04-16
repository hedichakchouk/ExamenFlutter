import 'package:examenflutteriit/components/calendar.dart';
import 'package:examenflutteriit/data/model/studient_model.dart';
import 'package:examenflutteriit/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late Future<List<StudentModel>> ListStudents;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  StudentModel student = StudentModel();

  void openAddStudentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add a Student"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: "Matricule"),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => student.matricule = int.tryParse(value ?? ''),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Name"),
                    onSaved: (value) => student.nom = value,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "First Name"),
                    onSaved: (value) => student.prenom = value,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  DropdownButtonFormField(
                    decoration: InputDecoration(labelText: "Gender"),
                    value: student.gender,
                    onChanged: (String? newValue) {
                      setState(() {
                        student.gender = newValue;
                      });
                    },
                    items: <String>['male', 'female'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  ElevatedButton(
                    onPressed: () => showCalendar(
                        context, DateRangePickerSelectionMode.single, (value) => changeDateCallback(value, "")),
                    child: Text('Select Date'),
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  // You can now save the student or do something else with the data
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    ListStudents = fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.themeData.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.white : Colors.black87,
      floatingActionButton: FloatingActionButton(onPressed: openAddStudentDialog, child: const Icon(Icons.add)),
      appBar: AppBar(
        title: Text('Students List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                ListStudents = fetchStudents();
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<StudentModel>>(
        future: ListStudents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                StudentModel student = snapshot.data![index];
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(student.nom!.substring(0, 1)),
                    ),
                    title: Text(student.nom!),
                    subtitle: Text(student.prenom!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Implement your edit action
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // Implement your delete action
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No students found'));
          }
        },
      ),
    );
  }
}

changeDateCallback(value, String dateDebutOfCurrentDay) async {
  if (dateDebutOfCurrentDay.isNotEmpty) {}
}

Future<List<StudentModel>> fetchStudents() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/students'));
  print(response.toString());
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => StudentModel.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load students');
  }
}
