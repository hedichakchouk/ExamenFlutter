import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:csv/csv.dart';
import 'package:examenflutteriit/components/calendar.dart';
import 'package:examenflutteriit/components/lottie/lottie_animation.dart';
import 'package:examenflutteriit/data/model/studient_model.dart';
import 'package:examenflutteriit/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ListStudents = fetchStudents();
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
      return StudentModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load student with matricule $matricule. Status code: ${response.statusCode}');
    }
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
                  TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: "Date of Birth"),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                        dateController.text = formattedDate;
                      }
                    },
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
                      student.gender!, dateController.text);
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

  Future<void> addStudent(int matricule, String nom, String prenom, String dateInscription, String gender, String dateOfBirth) async {
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
          'dateOfBirth': dateOfBirth
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

  Future<void> sendEmail(String filePath) async {
    final Email email = Email(
      body: 'Attached is the list of students',
      subject: 'List of Students',
      recipients: ['hedichakchoukk@gmail.com'],
      attachmentPaths: [filePath],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  createCSV() async {
    List<StudentModel> list = await fetchStudents() ;
    List<List<dynamic>> finalList = [];
    for (var element in list) {
      List<dynamic> tempList = [];
      tempList.add(element.matricule);
      tempList.add(element.nom);
      tempList.add(element.prenom);
      tempList.add(element.dateInscription);
      tempList.add(element.dateOfBirth);
      tempList.add(element.gender);
       finalList.add(tempList);
    }
    await getCSVAndSendEmail(finalList).then((value) => { sendEmail(value)});

  }


  Future<String> getCSVAndSendEmail(List associateList) async {
    List<List<dynamic>> rows = <List<dynamic>>[];
    List<dynamic> row = [];
    row.add("Matricule");
    row.add("First Name");
    row.add("Name");
    row.add("date Inscription");
    row.add("Date of Birth");
    row.add("Gender");
    rows.add(row);
    for (var element in associateList) {
      List<dynamic> row = [];
      row.add(element[0]);
      row.add(element[1]);
      row.add(element[2]);
      row.add(element[3]);
      row.add(element[4]);
      row.add(element[5] );
      rows.add(row);
    }


    String csv = const ListToCsvConverter().convert(rows);
    Directory directory = await getApplicationDocumentsDirectory();
    File csvFile = File("${directory.path}/students.csv");
    await csvFile.writeAsString(csv);

    return csvFile.path;

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
        leading: IconButton(
          icon: Icon(Icons.share, color: isDark ? Colors.black87 : Colors.white),
          onPressed: () {
            createCSV();
          },
        ),
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
                                                  readOnly: true,
                                                  onTap: () {
                                                    TextFormField(
                                                      controller: dateController,
                                                      decoration: InputDecoration(labelText: "Date of Birth"),
                                                      onTap: () async {
                                                        final DateTime? pickedDate = await showDatePicker(
                                                          context: context,
                                                          initialDate: DateTime.now(),
                                                          firstDate: DateTime(1900),
                                                          lastDate: DateTime.now(),
                                                        );
                                                        if (pickedDate != null) {
                                                          String formattedDate =
                                                              DateFormat('yyyy-MM-dd').format(pickedDate);
                                                          dateController.text = formattedDate;
                                                        }
                                                      },
                                                      validator: (value) => value!.isEmpty ? 'Required' : null,
                                                    );
                                                  },
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
                                };
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


