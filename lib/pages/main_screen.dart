import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:examenflutteriit/components/lottie/lottie_animation.dart';
import 'package:examenflutteriit/data/model/studient_model.dart';
import 'package:examenflutteriit/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    ListStudents = fetchStudents();
  }

  void openAddStudentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add a Student"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: "Matricule*", hintStyle: TextStyle(color: Colors.green)),
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
                  // ElevatedButton(
                  //   onPressed: () => showCalendar(
                  //       context, DateRangePickerSelectionMode.single, (value) => changeDateCallback(value, "")),
                  //   child: Text('Select Date'),
                  // )
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
                  addStudent(student.matricule!, student.nom!, student.prenom!, DateTime.now().toString(),
                      student.gender!, '2023-09-28T22:00:00.000Z');
                  Navigator.of(context).pop();
                  setState(() {
                    ListStudents = fetchStudents();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addStudent(
      int matricule, String nom, String prenom, String dateInscription, String gender, String dateOfBirth) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/students'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'matricule': matricule,
          'nom': nom,
          'prenom': prenom,
          'dateInscription': dateInscription,
          'gender': gender,
          'dateOfBirth': ""
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: false,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Opps!',
            message: 'Student added successfully',
            contentType: ContentType.success,
          ),
          duration: const Duration(seconds: 3),
        ));
        setState(() {
          ListStudents = fetchStudents();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: false,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Opps!',
            message: 'Failed to add student. Error: ${response.statusCode}',
            contentType: ContentType.failure,
          ),
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        showCloseIcon: false,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Opps!',
          message: 'Failed to add student. Error: $e',
          contentType: ContentType.failure,
        ),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  Future<void> deleteStudent(int matricule) async {
    final response = await http.delete(Uri.parse('http://10.0.2.2:3000/api/students/$matricule'));
    if (response.statusCode == 200) {
      setState(() {
        ListStudents = fetchStudents();
      });
    } else {
      throw Exception('Failed to delete student');
    }
  }




  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.themeData.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.white : Colors.black87,
      floatingActionButton: FloatingActionButton(
          onPressed: openAddStudentDialog, backgroundColor: Colors.brown.shade50, child: const Icon(Icons.add)),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.white : Colors.transparent,
        title: Text(
          'Students List',
          style: TextStyle(color: isDark ? Colors.black87 : Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.black87 : Colors.white,
            ),
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
            return Center(
                child: LottieAnimation(
              animationPath: 'assets/lottie/noDataFound.json',
              width: 200,
              fit: BoxFit.fill,
              height: 200,
            ));
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LottieAnimation(
                      animationPath: 'assets/lottie/emptyData.json',
                      width: 200,
                      fit: BoxFit.fill,
                      height: 200,
                    ),
                    Text(
                      'No students found',
                      style: TextStyle(color: isDark ? Colors.black : Colors.white),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  StudentModel student = snapshot.data![index];
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: isDark ? Colors.green.shade200 : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isDark ? Colors.brown.shade50 : Colors.green.shade100,
                        child: Text(student.nom!.substring(0, 1)),
                      ),
                      title: Text(
                        '${student.nom!} ${student.prenom!}',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      ),
                      subtitle: Text(student.gender!, style: TextStyle(color: isDark ? Colors.black : Colors.black87)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: isDark ? Colors.black87 : Colors.green,
                              ),
                              onPressed: () async {
                                try {
                                  StudentModel student = await fetchStudentDetails(snapshot.data![index].matricule!);
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Edit Student"),
                                        content: Form(
                                          key: formKey,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: <Widget>[
                                                TextFormField(
                                                  initialValue: student.matricule.toString(),
                                                  decoration: InputDecoration(labelText: "Matricule"),
                                                  readOnly: true,
                                                ),
                                                TextFormField(
                                                  initialValue: student.nom,
                                                  decoration: InputDecoration(labelText: "Name"),
                                                  onSaved: (value) => student.nom = value,
                                                  validator: (value) => value!.isEmpty ? 'Required' : null,
                                                ),
                                                TextFormField(
                                                  initialValue: student.prenom,
                                                  decoration: InputDecoration(labelText: "First Name"),
                                                  onSaved: (value) => student.prenom = value,
                                                  validator: (value) => value!.isEmpty ? 'Required' : null,
                                                ),
                                                TextFormField(
                                                  initialValue: student.dateOfBirth,
                                                  decoration: InputDecoration(labelText: "Date of Birth"),
                                                  onSaved: (value) => student.dateOfBirth = value,
                                                ),
                                                DropdownButtonFormField(
                                                  decoration: InputDecoration(labelText: "Gender"),
                                                  value: student.gender,
                                                  onChanged: (String? newValue) {
                                                    setState(() {
                                                      student.gender = newValue;
                                                    });
                                                  },
                                                  items: <String>['male', 'female']
                                                      .map<DropdownMenuItem<String>>((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  validator: (value) => value == null ? 'Required' : null,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Save'),
                                            onPressed: () {
                                              if (formKey.currentState!.validate()) {
                                                formKey.currentState!.save();
                                                updateStudent(student).then((result) {
                                                  if (result) {
                                                    setState(() {
                                                      ListStudents = fetchStudents();
                                                    });
                                                    Navigator.of(context).pop();
                                                  } else {
                                                    print('Error updating student');
                                                  }
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } catch (error) {
                                  print('Failed to fetch student details: $error');
                                }
                                ;
                              }),
                          IconButton(
                            icon: Icon(
                              Icons.delete_sharp,
                              color: isDark ? Colors.black87 : Colors.red,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Confirm Delete"),
                                    content: Text("Are you sure you want to delete this student?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                          deleteStudent(student.matricule!);
                                        },
                                        child: Text(
                                          "Delete",
                                          style:
                                              TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          } else {
            return Center(
                child: Text(
              'No students found',
              style: TextStyle(color: Colors.black),
            ));
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

Future<bool> updateStudent(StudentModel student) async {
  try {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/api/students/${student.matricule}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'matricule': student.matricule,
        'nom': student.nom,
        'prenom': student.prenom,
        'dateOfBirth': student.dateOfBirth,
        'gender': student.gender,
      }),
    );

    if (response.statusCode == 200) {
      print('Student updated successfully');
      return true;
    } else {
      print('Failed to update student. Status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error updating student: $e');
    return false;
  }
}

Future<StudentModel> fetchStudentDetails(int matricule) async {
  final url = Uri.parse('http://10.0.2.2:3000/api/students/$matricule');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return StudentModel.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load student with matricule $matricule. Status code: ${response.statusCode}');
  }
}


