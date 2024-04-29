import 'dart:convert';

import 'package:examenflutteriit/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int maleCount = 0;
  int femaleCount = 0;
  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
  }
  Future<void> fetchDataFromAPI() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/gender'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        maleCount = data['maleCount'];
        femaleCount = data['femaleCount'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<PieChartSectionData> showingSections(bool isDark) {
    final int total = maleCount + femaleCount;
    return [
      PieChartSectionData(
        color: isDark?Colors.black:Colors.white,
        value: maleCount.toDouble(),
        title: 'Male $maleCount',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark?Colors.white:Colors.black,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: femaleCount.toDouble(),
        title: 'Female $femaleCount',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark?Colors.white:Colors.black,
        ),
      ),
    ];
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.themeData.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.white : Colors.black87,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.white : Colors.black87,
        centerTitle: true,
        title: Text('DashBoard Page',
            style: TextStyle(
              color: isDark ? Colors.black87 : Colors.white,
            )),
      ),
      body:  Center(
        child: maleCount + femaleCount > 0 ? PieChart(
          PieChartData(
            pieTouchData: PieTouchData(longPressDuration: Duration(milliseconds: 0)),
            borderData: FlBorderData(show: false),
            sectionsSpace: 0,
            centerSpaceRadius: 80,
            sections: showingSections(isDark),
          ),
        ) : CircularProgressIndicator(),
      ),
    );
  }
}

