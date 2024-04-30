import 'dart:async';
import 'dart:convert';
import 'package:examenflutteriit/components/lottie/lottie_animation.dart';
import 'package:examenflutteriit/main.dart'; // Assuming ThemeProvider is defined here
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
  late StreamController<Map<String, int>> _streamController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController.broadcast();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => fetchDataFromAPI());
    fetchDataFromAPI();
  }

  @override
  void dispose() {
    _timer.cancel();
    _streamController.close();
    super.dispose();
  }

  Future<void> fetchDataFromAPI() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/gender'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _streamController.sink.add({'maleCount': data['maleCount'], 'femaleCount': data['femaleCount']});
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      _streamController.addError('Failed to fetch data');
    }
  }

  List<PieChartSectionData> showingSections(int maleCount, int femaleCount, bool isDark) {
    return [
      PieChartSectionData(
        color: isDark ? Colors.black : Colors.white,
        value: maleCount.toDouble(),
        title: 'Male $maleCount',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
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
          color: isDark ? Colors.white : Colors.black,
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
      body: StreamBuilder<Map<String, int>>(
        stream: _streamController.stream,
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
              final maleCount = snapshot.data!['maleCount']!;
              final femaleCount = snapshot.data!['femaleCount']!;
              return Center(
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(longPressDuration: Duration(milliseconds: 0)),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 80,
                    sections: showingSections(maleCount, femaleCount, isDark),
                  ),
                ),
              );
            }
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
