import 'dart:async';
import 'dart:convert';
import 'package:examenflutteriit/components/lottie/lottie_animation.dart';
import 'package:examenflutteriit/main.dart'; // Assuming ThemeProvider is defined here
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late StreamController<Map<String, int>> _streamController;
  late Timer _timer;
  int touchedIndex = 0;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController.broadcast();
    _timer = Timer.periodic(const Duration(seconds: 0), (timer) => fetchDataFromAPI());
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
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 80.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: isDark ? Colors.black : Colors.white,
            value: maleCount.toDouble(),
            title: 'Male $maleCount',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              shadows: shadows,
            ),
            badgeWidget: Badge(
              'assets/boy.jpg',
              size: widgetSize,
              borderColor: Colors.black54,
            ),
            badgePositionPercentageOffset: .98,
          );
        case 1:
          return PieChartSectionData(
            color: Colors.green,
            value: femaleCount.toDouble(),
            title: 'Female $femaleCount',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              shadows: shadows,
            ),
            badgeWidget: Badge('assets/girl.jpg', size: widgetSize, borderColor: Colors.deepOrangeAccent),
            badgePositionPercentageOffset: .98,
          );
        default:
          throw Exception('Oh no');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.themeData.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.white : Colors.black87,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.white : Colors.transparent,
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
            return const Center(child: CircularProgressIndicator());
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
                  swapAnimationCurve: Curves.linear,
                  swapAnimationDuration: const Duration(milliseconds: 1),
                  PieChartData(
                    pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                          setState(() {
                            if (pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            } else {
                              touchedIndex = -1;
                            }
                          });
                        }
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 80,
                    sections: showingSections(maleCount, femaleCount, isDark),
                  ),
                ),
              );
            }
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

class Badge extends StatelessWidget {
  const Badge(
    this.image, {
    required this.size,
    required this.borderColor,
  });
  final String image;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Image.asset(
          image,
        ),
      ),
    );
  }
}
