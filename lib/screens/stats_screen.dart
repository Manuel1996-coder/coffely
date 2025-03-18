import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildCaffeineProgress(context, coffeeProvider),
                  const SizedBox(height: 24),
                  _buildWeeklyOverview(context, coffeeProvider),
                  const SizedBox(height: 24),
                  _buildFavoritesAndAverage(context, coffeeProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Deine Kaffee-Statistiken',
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }

  Widget _buildCaffeineProgress(BuildContext context, CoffeeProvider provider) {
    final currentCaffeineLevel = provider.predictCaffeineLevel();
    // Maximaler Koffeingehalt für einen durchschnittlichen Erwachsenen (ca. 400 mg)
    const maxCaffeine = 400.0;
    final caffeinePercentage = min(1.0, currentCaffeineLevel / maxCaffeine);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktueller Koffeinstand',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${currentCaffeineLevel.toStringAsFixed(1)} mg',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'von empfohlenen 400 mg',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildEffectsIndicator(context, caffeinePercentage),
                  ],
                ),
                CircularPercentIndicator(
                  radius: 70.0,
                  lineWidth: 15.0,
                  animation: true,
                  percent: caffeinePercentage,
                  center: SizedBox(
                    width: 70,
                    height: 70,
                    child: CustomPaint(
                      painter: CoffeeCupPainter(fillLevel: caffeinePercentage),
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: _getCaffeineColor(caffeinePercentage),
                  backgroundColor: Colors.grey[200]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectsIndicator(
      BuildContext context, double caffeinePercentage) {
    String effectText;
    Color effectColor;

    if (caffeinePercentage < 0.2) {
      effectText = 'Leichte Wachheit';
      effectColor = Colors.green[600]!;
    } else if (caffeinePercentage < 0.5) {
      effectText = 'Optimale Konzentration';
      effectColor = Colors.orange[600]!;
    } else if (caffeinePercentage < 0.8) {
      effectText = 'Hohe Aufmerksamkeit';
      effectColor = Colors.deepOrange[600]!;
    } else {
      effectText = 'Risiko von Nervosität';
      effectColor = Colors.red[600]!;
    }

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: effectColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          effectText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: effectColor,
              ),
        ),
      ],
    );
  }

  Color _getCaffeineColor(double percentage) {
    if (percentage < 0.25) {
      return Colors.green[600]!;
    } else if (percentage < 0.5) {
      return Colors.orange[600]!;
    } else if (percentage < 0.75) {
      return Colors.deepOrange[600]!;
    } else {
      return Colors.red[600]!;
    }
  }

  Widget _buildWeeklyOverview(BuildContext context, CoffeeProvider provider) {
    final weeklyData = provider.getWeeklyCaffeineConsumption();
    final maxCaffeine = weeklyData.values.isEmpty
        ? 400.0
        : max(weeklyData.values.reduce(max), 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wochenübersicht',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxCaffeine + 50,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.white.withOpacity(0.8),
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String weekDay = weeklyData.keys.elementAt(groupIndex);
                        return BarTooltipItem(
                          '$weekDay: ${rod.toY.toStringAsFixed(1)} mg',
                          const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < weeklyData.length) {
                            return Text(
                              weeklyData.keys.elementAt(index),
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxCaffeine / 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: List.generate(
                    weeklyData.length,
                    (index) {
                      final value = weeklyData.values.elementAt(index);
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            width: 22,
                            color: AppTheme.secondaryColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesAndAverage(
      BuildContext context, CoffeeProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildDailyAverage(context, provider),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFavoriteDrinks(context, provider),
        ),
      ],
    );
  }

  Widget _buildDailyAverage(BuildContext context, CoffeeProvider provider) {
    final avgConsumption = provider.getAverageDailyConsumption();
    final avgDrinks =
        avgConsumption / 80; // Annahme: Durchschnittlicher Espresso hat 80mg

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Täglicher Durchschnitt',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.coffee_outlined,
                  size: 28,
                  color: AppTheme.secondaryColor,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${avgDrinks.toStringAsFixed(1)} Tassen',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${avgConsumption.toStringAsFixed(0)} mg Koffein',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteDrinks(BuildContext context, CoffeeProvider provider) {
    final favorites = provider.getFavoriteDrinks();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lieblingsgetränke',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (favorites.isEmpty)
              Text(
                'Noch keine Daten',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...favorites.take(3).map((drink) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppTheme.accentColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        drink,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
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
    final cupWidth = size.width * 0.8;
    final cupHeight = size.height * 0.75;
    final handleWidth = size.width * 0.2;
    final handleHeight = size.height * 0.4;

    // Griff zeichnen
    final handlePaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final handlePath = Path()
      ..moveTo(size.width * 0.75, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.4,
          size.width * 0.75, size.height * 0.6);

    canvas.drawPath(handlePath, handlePaint);

    // Tasse zeichnen
    final cupPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final cupRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.45, size.height * 0.5),
        width: cupWidth,
        height: cupHeight,
      ),
      const Radius.circular(6),
    );

    canvas.drawRRect(cupRect, cupPaint);

    // Kaffee Füllung
    if (fillLevel > 0) {
      final fillHeight = cupHeight * fillLevel;
      final coffeeColor = AppTheme.primaryColor.withOpacity(0.7);

      final coffeePaint = Paint()
        ..color = coffeeColor
        ..style = PaintingStyle.fill;

      final coffeeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.45 - cupWidth / 2,
          size.height * 0.5 + cupHeight / 2 - fillHeight,
          cupWidth,
          fillHeight,
        ),
        const Radius.circular(6),
      );

      canvas.drawRRect(coffeeRect, coffeePaint);
    }

    // Dampf zeichnen, wenn die Tasse ziemlich voll ist
    if (fillLevel > 0.7) {
      final steamPaint = Paint()
        ..color = Colors.grey.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final random = Random();

      // Mehrere Dampfwölkchen
      for (int i = 0; i < 3; i++) {
        final startX = size.width * (0.35 + 0.1 * i);
        final startY = size.height * 0.1;

        final steamPath = Path()
          ..moveTo(startX, startY + size.height * 0.1)
          ..cubicTo(
            startX - 5 + random.nextDouble() * 10,
            startY - 5 + random.nextDouble() * 10,
            startX + 5 + random.nextDouble() * 10,
            startY - 15 + random.nextDouble() * 10,
            startX,
            startY - 20,
          );

        canvas.drawPath(steamPath, steamPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
