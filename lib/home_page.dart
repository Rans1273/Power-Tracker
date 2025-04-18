import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

import 'tools_page.dart';
import 'widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  double I = 0, P = 0, V = 0;

  List<double> iList = [];
  List<double> pList = [];
  List<double> vList = [];

  @override
  void initState() {
    super.initState();
    dbRef.child('monitoring').onValue.listen((event) {
      final data = event.snapshot.value as Map;

      final newI = data['I'] * 1.0;
      final newP = data['P'] * 1.0;
      final newV = data['V'] * 1.0;

      setState(() {
        I = newI;
        P = newP;
        V = newV;

        updateList(iList, newI);
        updateList(pList, newP);
        updateList(vList, newV);
      });
    });
  }

  void updateList(List<double> list, double value) {
    if (list.length >= 10) list.removeAt(0);
    list.add(value);
  }

  Widget buildChart(List<double> values, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: values.asMap().entries.map(
                    (e) => FlSpot(e.key.toDouble(), e.value),
                  ).toList(),
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  // Removed tooltipBgColor
                ),
                touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  // You can handle the touch event here if necessary
                },
                handleBuiltInTouches: true,
              ),
              minY: 0, // Add a minimum Y-axis value to prevent overflow
              maxY: 100, // Adjust max Y-axis value as needed
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Welcome, ${user?.email ?? "Guest"}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            Text("Current (I): $I", style: const TextStyle(fontSize: 20)),
            buildChart(iList, 'Current (I)', Colors.red),
            const SizedBox(height: 24),
            Text("Power (P): $P", style: const TextStyle(fontSize: 20)),
            buildChart(pList, 'Power (P)', Colors.green),
            const SizedBox(height: 24),
            Text("Voltage (V): $V", style: const TextStyle(fontSize: 20)),
            buildChart(vList, 'Voltage (V)', Colors.blue),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }
}
