import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/bottom_nav.dart';
import 'login_page.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  double I = 0, P = 0, V = 0;
  double topI = 100, topP = 100, topV = 100;

  List<double> iList = [];
  List<double> pList = [];
  List<double> vList = [];

  int s1 = 0, s2 = 0, s3 = 0;

  @override
  void initState() {
    super.initState();

    // Ambil nilai notification
    dbRef.child('notification').once().then((snapshot) {
      final notif = snapshot.snapshot.value as Map?;
      setState(() {
        topI = (notif?['top_I'] ?? 100).toDouble();
        topP = (notif?['top_P'] ?? 100).toDouble();
        topV = (notif?['top_V'] ?? 100).toDouble();
      });
    });

    // Ambil data monitoring
    dbRef.child('monitoring').onValue.listen((event) {
      final data = event.snapshot.value as Map?;

      final newI = (data?['I'] ?? 0) * 1.0;
      final newP = (data?['P'] ?? 0) * 1.0;
      final newV = (data?['V'] ?? 0) * 1.0;

      setState(() {
        if (newI != I) updateList(iList, newI);
        if (newP != P) updateList(pList, newP);
        if (newV != V) updateList(vList, newV);

        I = newI;
        P = newP;
        V = newV;
      });
    });

    // Ambil data switch
    dbRef.child('switch').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      setState(() {
        s1 = (data?['S1'] ?? 0) as int;
        s2 = (data?['S2'] ?? 0) as int;
        s3 = (data?['S3'] ?? 0) as int;
      });
    });
  }

  void updateList(List<double> list, double value) {
    if (list.length >= 20) list.removeAt(0);
    list.add(value);
  }

  void toggleSwitch(String key, int currentValue) {
    final newValue = currentValue == 1 ? 0 : 1;
    dbRef.child('switch/$key').set(newValue);
  }

  Widget buildSwitchCard(String label, int value) {
    final isActive = value == 1;

    return Expanded(
      child: GestureDetector(
        onTap: () => toggleSwitch(label, value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 75,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.green : Colors.grey,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive ? Colors.green.withOpacity(0.5) : Colors.black26,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.power_settings_new,
                color: isActive ? Colors.green : Colors.grey,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChart(List<double> values, String label, Color color) {
    double minY = -1;
    double maxY = 100;

    if (label.contains('Voltage')) {
      maxY = 300;
    } else if (label.contains('Current')) {
      maxY = 15;
    } else if (label.contains('Power')) {
      maxY = 5;
    }

    return Card(
      color: Theme.of(context).cardColor.withOpacity(0.8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
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
                        (e) => FlSpot(e.key.toDouble(), e.value.clamp(minY, maxY)),
                      ).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(),
                    handleBuiltInTouches: true,
                  ),
                  minY: minY,
                  maxY: maxY,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard(String label, double value, double threshold, Color color) {
    final isOver = value > threshold;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOver ? Colors.red : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isOver ? Colors.redAccent : Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                value.toStringAsFixed(2),
                key: ValueKey<double>(value),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserCard(User? user) {
    return Card(
      color: Theme.of(context).cardColor.withOpacity(0.8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/user.png'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                user?.email ?? "Guest",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.microtask(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      });
      return const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildUserCard(user),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        buildInfoCard("A", I, topI, Colors.red),
                        const SizedBox(width: 4),
                        buildInfoCard("V", V, topV, Colors.blue),
                        const SizedBox(width: 4),
                        buildInfoCard("P/KwH", P, topP, Colors.green),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        buildSwitchCard("S1", s1),
                        buildSwitchCard("S2", s2),
                        buildSwitchCard("S3", s3),
                      ],
                    ),
                    const SizedBox(height: 16),
                    buildChart(iList, 'Current (A)', Colors.red),
                    buildChart(vList, 'Voltage (V)', Colors.blue),
                    buildChart(pList, 'Power (P)', Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
