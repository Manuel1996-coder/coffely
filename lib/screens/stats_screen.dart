import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/coffee_provider.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<CoffeeProvider>(
          builder: (context, coffeeProvider, child) {
            if (coffeeProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: AppTheme.backgroundColor,
                  elevation: 0,
                  title: const Text('Deine Statistiken'),
                  titleTextStyle: Theme.of(context).textTheme.headlineLarge,
                ),
                SliverToBoxAdapter(
                  child: _buildCaffeineProgress(context, coffeeProvider),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wochenübersicht',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _buildWeeklyOverview(context, coffeeProvider),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tägliche Durchschnitte',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Letzte 7 Tage',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.secondaryTextColor,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDailyAverages(context, coffeeProvider),
                        const SizedBox(height: 24),
                        Text(
                          'Deine Lieblingsgetränke',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _buildFavoriteDrinks(context, coffeeProvider),
                        const SizedBox(height: 24),
                        Text(
                          'Koffein-Prognose',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _buildCaffeinePrognosis(context, coffeeProvider),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCaffeineProgress(
      BuildContext context, CoffeeProvider coffeeProvider) {
    // Berechne das aktuelle Koffein im Körper
    final currentCaffeine = coffeeProvider.predictCaffeineLevel(DateTime.now());

    // Maximales Koffein (etwa 400mg wird allgemein als Tageslimit angesehen)
    const maxCaffeine = 400.0;

    // Prozentwert (zwischen 0 und 1)
    final caffeinePercent = (currentCaffeine / maxCaffeine).clamp(0.0, 1.0);

    // Bestimme den Effekt basierend auf dem Koffeinlevel
    String effect;
    Color effectColor;

    if (caffeinePercent < 0.25) {
      effect = 'Leichte Wachheit';
      effectColor = Colors.green;
    } else if (caffeinePercent < 0.5) {
      effect = 'Optimale Konzentration';
      effectColor = Colors.blue;
    } else if (caffeinePercent < 0.75) {
      effect = 'Hohe Energie';
      effectColor = Colors.orange;
    } else {
      effect = 'Risiko von Nervosität';
      effectColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomPaint(
                size: const Size(80, 100),
                painter: CoffeeCupPainter(fillLevel: caffeinePercent),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktuelles Koffein',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${currentCaffeine.toStringAsFixed(0)} mg',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: _getCaffeineColor(caffeinePercent),
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: effectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        effect,
                        style: TextStyle(
                          color: effectColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            lineHeight: 10,
            percent: caffeinePercent,
            backgroundColor: Colors.grey[200],
            progressColor: _getCaffeineColor(caffeinePercent),
            barRadius: const Radius.circular(5),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 1000,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 mg',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Empfohlenes Limit: 400 mg',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCaffeineColor(double percent) {
    if (percent < 0.25) {
      return Colors.green;
    } else if (percent < 0.5) {
      return Colors.blue;
    } else if (percent < 0.75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildWeeklyOverview(
      BuildContext context, CoffeeProvider coffeeProvider) {
    final weekDays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final today = DateTime.now();

    // Erstelle BarChartGroups für die letzten 7 Tage
    final barGroups = <BarChartGroupData>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayDrinks = coffeeProvider.getDrinksForDay(date);

      final totalCaffeine = dayDrinks.fold<double>(
        0,
        (sum, drink) => sum + drink.caffeineAmount,
      );

      // Index des Wochentags für die Anzeige (0 = Montag)
      final weekdayIndex = (today.weekday - i - 1) % 7;

      barGroups.add(BarChartGroupData(
        x: 6 - i,
        barRods: [
          BarChartRodData(
            toY: totalCaffeine,
            color: date.day == today.day
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withOpacity(0.6),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ));
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 400,
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // Berechne den Index des Wochentags
                  int dayIndex = (today.weekday - (6 - value.toInt()) - 1) % 7;
                  if (dayIndex < 0) dayIndex += 7;

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      weekDays[dayIndex],
                      style: TextStyle(
                        color: value.toInt() == 6
                            ? AppTheme.primaryColor
                            : AppTheme.secondaryTextColor,
                        fontWeight: value.toInt() == 6
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
                interval: 100,
                reservedSize: 40,
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppTheme.primaryColor.withOpacity(0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                // Berechne das Datum für diesen Balken
                final date =
                    today.subtract(Duration(days: 6 - group.x.toInt()));
                return BarTooltipItem(
                  '${date.day}.${date.month}.${date.year}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toInt()} mg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyAverages(
      BuildContext context, CoffeeProvider coffeeProvider) {
    // Berechne die Durchschnittswerte für die letzten 7 Tage
    final today = DateTime.now();
    double totalCaffeine = 0;
    int totalDrinks = 0;

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dayDrinks = coffeeProvider.getDrinksForDay(date);

      totalDrinks += dayDrinks.length;
      totalCaffeine += dayDrinks.fold<double>(
        0,
        (sum, drink) => sum + drink.caffeineAmount,
      );
    }

    final avgDrinksPerDay = totalDrinks / 7;
    final avgCaffeinePerDay = totalCaffeine / 7;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.coffee,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tassen',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  avgDrinksPerDay.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'pro Tag',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Koffein',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${avgCaffeinePerDay.toInt()} mg',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'pro Tag',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteDrinks(
      BuildContext context, CoffeeProvider coffeeProvider) {
    // Zähle, wie oft jedes Getränk getrunken wurde
    final drinkCounts = <String, int>{};

    for (final drink in coffeeProvider.drinks) {
      drinkCounts[drink.name] = (drinkCounts[drink.name] ?? 0) + 1;
    }

    // Sortiere nach Häufigkeit
    final sortedDrinks = drinkCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final favoriteCount = min(3, sortedDrinks.length);

    if (favoriteCount == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: const Center(
          child: Text('Noch keine Getränke getrunken'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: List.generate(favoriteCount, (index) {
          final entry = sortedDrinks[index];
          final rank = index + 1;
          String icon;

          if (rank == 1) {
            icon = '🥇';
          } else if (rank == 2) {
            icon = '🥈';
          } else {
            icon = '🥉';
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${entry.value} mal getrunken',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.favorite,
                  color: index == 0
                      ? Colors.red
                      : (index == 1 ? Colors.orange : Colors.amber),
                  size: 20,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCaffeinePrognosis(
      BuildContext context, CoffeeProvider coffeeProvider) {
    // Zeige eine Prognose für die nächsten Stunden
    final now = DateTime.now();
    final timePoints = <DateTime>[];
    final caffeineValues = <double>[];

    // Prognose für die nächsten 12 Stunden
    for (int i = 0; i <= 12; i++) {
      final time = now.add(Duration(hours: i));
      timePoints.add(time);
      caffeineValues.add(coffeeProvider.predictCaffeineLevel(time));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 3 == 0 && value.toInt() < timePoints.length) {
                    final time = timePoints[value.toInt()];
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        '${time.hour}:00',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
                interval: 100,
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppTheme.primaryColor.withOpacity(0.8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final time = timePoints[spot.x.toInt()];
                  return LineTooltipItem(
                    '${time.hour}:00\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '${spot.y.toInt()} mg',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(timePoints.length, (index) {
                return FlSpot(index.toDouble(), caffeineValues[index]);
              }),
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ],
          minY: 0,
        ),
      ),
    );
  }
}

class CoffeeCupPainter extends CustomPainter {
  final double fillLevel;

  CoffeeCupPainter({required this.fillLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Definiere die Tasse
    final cupPath = Path()
      ..moveTo(width * 0.2, height * 0.2)
      ..lineTo(width * 0.2, height * 0.8)
      ..quadraticBezierTo(width * 0.2, height * 0.9, width * 0.3, height * 0.9)
      ..lineTo(width * 0.7, height * 0.9)
      ..quadraticBezierTo(width * 0.8, height * 0.9, width * 0.8, height * 0.8)
      ..lineTo(width * 0.8, height * 0.2)
      ..close();

    // Zeichne die Tasse
    final cupPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(cupPath, cupPaint);

    // Zeichne den Tassenrand
    final borderPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(cupPath, borderPaint);

    // Zeichne den Henkel
    final handlePath = Path()
      ..moveTo(width * 0.8, height * 0.3)
      ..quadraticBezierTo(
          width * 0.95, height * 0.3, width * 0.95, height * 0.5)
      ..quadraticBezierTo(
          width * 0.95, height * 0.7, width * 0.8, height * 0.7);

    canvas.drawPath(handlePath, borderPaint);

    // Zeichne den Kaffee in der Tasse
    if (fillLevel > 0) {
      final fillHeight = height * 0.7 - (height * 0.5 * fillLevel);
      final coffeePath = Path()
        ..moveTo(width * 0.2, fillHeight)
        ..lineTo(width * 0.2, height * 0.8)
        ..quadraticBezierTo(
            width * 0.2, height * 0.9, width * 0.3, height * 0.9)
        ..lineTo(width * 0.7, height * 0.9)
        ..quadraticBezierTo(
            width * 0.8, height * 0.9, width * 0.8, height * 0.8)
        ..lineTo(width * 0.8, fillHeight)
        ..close();

      final coffeePaint = Paint()
        ..color = AppTheme.primaryColor
        ..style = PaintingStyle.fill;

      canvas.drawPath(coffeePath, coffeePaint);
    }

    // Zeichne Dampf, wenn der Kaffee heiß ist (hoher Koffeingehalt)
    if (fillLevel > 0.8) {
      final steamPaint = Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      // Linker Dampfstrom
      final leftSteamPath = Path()
        ..moveTo(width * 0.35, height * 0.2)
        ..quadraticBezierTo(
            width * 0.3, height * 0.1, width * 0.35, height * 0.05);

      // Mittlerer Dampfstrom
      final middleSteamPath = Path()
        ..moveTo(width * 0.5, height * 0.2)
        ..quadraticBezierTo(
            width * 0.55, height * 0.05, width * 0.5, height * 0);

      // Rechter Dampfstrom
      final rightSteamPath = Path()
        ..moveTo(width * 0.65, height * 0.2)
        ..quadraticBezierTo(
            width * 0.7, height * 0.1, width * 0.65, height * 0.05);

      canvas.drawPath(leftSteamPath, steamPaint);
      canvas.drawPath(middleSteamPath, steamPaint);
      canvas.drawPath(rightSteamPath, steamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CoffeeCupPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel;
  }
}
