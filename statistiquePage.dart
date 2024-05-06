import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accommodation App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StatisticsScreen(),
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Your Statistics'),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {}, // Placeholder for filtering or options
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: AnimatedStatsChart(),
            ),
            StatisticCard(
              icon: Icons.history,
              title: 'Total Bookings',
              subtitle: '15 bookings this year',
            ),
            StatisticCard(
              icon: Icons.place,
              title: 'Favorite Destination',
              subtitle: 'Paris, France',
            ),
            StatisticCard(
              icon: Icons.monetization_on,
              title: 'Total Expenses',
              subtitle: '€3,000 this year',
            ),
            StatisticCard(
              icon: Icons.star,
              title: 'Latest Review',
              subtitle: 'Hotel des Alpes - 5 stars',
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/images/statistique.png', // Ensure the path is correct
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const StatisticCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class AnimatedStatsChart extends StatefulWidget {
  @override
  _AnimatedStatsChartState createState() => _AnimatedStatsChartState();
}

class _AnimatedStatsChartState extends State<AnimatedStatsChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(
          milliseconds: 1500), // Augmentation de la durée de l'animation
      vsync: this,
    );

    // Démarrer l'animation lorsque le widget est construit
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _animationController.forward();
    });

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        height: 220,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 3),
                  FlSpot(2, 2),
                  FlSpot(4, 5),
                  FlSpot(6, 3.1),
                  FlSpot(8, 4),
                  FlSpot(10, 3),
                  FlSpot(12, 4),
                ],
                isCurved: true,
                color: Colors.blue,
                barWidth: 5,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
