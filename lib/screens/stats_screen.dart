import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../providers/coffee_provider.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  // Kaffeefarben - weichere, pastellige Töne
  static const Color accentColor = Color(0xFF8D6E63); // Sanftes Braun als Hauptfarbe
  static const Color lightAccentColor = Color(0xFFBCAAA4); // Helles Braun
  static const Color darkAccentColor = Color(0xFF5D4037); // Dunkles Braun
  static const Color warningColor = Color(0xFFE6A278); // Warmes Orange als Warnfarbe
  static const Color successColor = Color(0xFF81C784); // Sanftes Grün für Erfolg
  
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de_DE', null);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: AppTheme.backgroundColor,
                  elevation: 0,
                  leadingWidth: 64,
                  leading: Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.insights_rounded, color: accentColor),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  title: const Text('Deine Statistiken'),
                  titleTextStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                  child: _buildCaffeineProgress(context, coffeeProvider),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, 'Wochenübersicht', Icons.calendar_today_rounded),
                        const SizedBox(height: 12),
                        _buildWeeklyOverview(context, coffeeProvider),
                        const SizedBox(height: 24),
                        _buildSectionHeader(context, 'Tägliche Durchschnitte', Icons.auto_graph_rounded),
                        const SizedBox(height: 12),
                        _buildDailyAverages(context, coffeeProvider),
                        const SizedBox(height: 24),
                        _buildSectionHeader(context, 'Deine Lieblingsgetränke', Icons.favorite_rounded),
                        const SizedBox(height: 12),
                        _buildFavoriteDrinks(context, coffeeProvider),
                        const SizedBox(height: 24),
                        _buildSectionHeader(context, 'Koffein-Prognose', Icons.trending_down_rounded),
                        const SizedBox(height: 12),
                        _buildCaffeinePrognosis(context, coffeeProvider),
                        const SizedBox(height: 50),
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

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: darkAccentColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCaffeineProgress(
      BuildContext context, CoffeeProvider coffeeProvider) {
    // Berechne das aktuelle Koffein im Körper
    final currentCaffeine = coffeeProvider.predictCaffeineLevel(DateTime.now());

    // Maximales Koffein aus dem Provider (individuell für den Nutzer)
    final maxCaffeine = coffeeProvider.caffeineLimit;

    // Prozentwert (zwischen 0 und 1)
    final caffeinePercent = (currentCaffeine / maxCaffeine).clamp(0.0, 1.0);

    // Bestimme den Effekt basierend auf dem Koffeinlevel
    String effect;
    Color effectColor;

    if (caffeinePercent < 0.25) {
      effect = 'Leichte Wachheit';
      effectColor = successColor;
    } else if (caffeinePercent < 0.5) {
      effect = 'Optimale Konzentration';
      effectColor = accentColor;
    } else if (caffeinePercent < 0.75) {
      effect = 'Hohe Energie';
      effectColor = warningColor;
    } else {
      effect = 'Risiko von Nervosität';
      effectColor = Colors.red[400]!;
    }

    return FadeTransition(
      opacity: _animationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutQuart,
        )),
        child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              )
            ],
      ),
      child: Column(
        children: [
          Row(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  SizedBox(
                    width: 80,
                    height: 110,
                    child: CustomPaint(
                      painter: CoffeeCupPainter(
                        fillLevel: caffeinePercent,
                        isAnimated: true,
                        animationValue: _animationController.value,
                      ),
                    ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktuelles Koffein',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutQuart,
                          tween: Tween<double>(begin: 0, end: currentCaffeine),
                          builder: (context, value, child) {
                            return Text(
                              '${value.toInt()} mg',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: _getCaffeineColor(caffeinePercent),
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                            color: effectColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: effectColor.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getEffectIcon(caffeinePercent),
                                color: effectColor,
                                size: 16, 
                              ),
                              const SizedBox(width: 4),
                              Text(
                        effect,
                        style: TextStyle(
                          color: effectColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                              ),
                            ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
              const SizedBox(height: 20),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutQuart,
                tween: Tween<double>(begin: 0, end: caffeinePercent),
                builder: (context, value, child) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearPercentIndicator(
                          lineHeight: 16,
                          percent: value,
                          backgroundColor: Colors.grey[100],
            progressColor: _getCaffeineColor(caffeinePercent),
                          barRadius: const Radius.circular(12),
            padding: EdgeInsets.zero,
                          animation: false,
            animationDuration: 1000,
                          center: Text(
                            '${(value * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: value > 0.5 ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      if (currentCaffeine > 400)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 mg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: lightAccentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: darkAccentColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
              Text(
                'Empfohlenes Limit: 400 mg',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: darkAccentColor,
                            fontWeight: FontWeight.w500,
                          ),
              ),
            ],
                    ),
          ),
        ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getEffectIcon(double percent) {
    if (percent < 0.25) {
      return Icons.sentiment_satisfied_outlined;
    } else if (percent < 0.5) {
      return Icons.sentiment_very_satisfied_rounded;
    } else if (percent < 0.75) {
      return Icons.mood_rounded;
    } else {
      return Icons.mood_bad_rounded;
    }
  }

  Color _getCaffeineColor(double caffeinePercent) {
    if (caffeinePercent < 0.25) {
      return successColor;
    } else if (caffeinePercent < 0.5) {
      return accentColor;
    } else if (caffeinePercent < 0.75) {
      return warningColor;
    } else {
      return Colors.red[400]!;
    }
  }

  Widget _buildWeeklyOverview(
      BuildContext context, CoffeeProvider coffeeProvider) {
    final weekDays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final today = DateTime.now();

    // Erstelle BarChartGroups für die letzten 7 Tage
    final barGroups = <BarChartGroupData>[];
    double maxCaffeineValue = 400.0; // Standardwert für 400mg

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayDrinks = coffeeProvider.getDrinksForDay(date);

      final totalCaffeine = dayDrinks.fold<double>(
        0,
        (sum, drink) => sum + drink.caffeineAmount,
      );

      // Update maxCaffeineValue wenn ein höherer Wert gefunden wurde
      if (totalCaffeine > maxCaffeineValue) {
        maxCaffeineValue = totalCaffeine * 1.2; // 20% mehr für Platz im Diagramm
      }

      // Index des Wochentags für die Anzeige (0 = Montag)
      final weekdayIndex = (today.weekday - i - 1) % 7;

      // Farbe ermitteln (mit Verläufen)
      final color = date.day == today.day
          ? accentColor
          : getGradientColor(totalCaffeine);

      barGroups.add(BarChartGroupData(
        x: 6 - i,
        barRods: [
          BarChartRodData(
            toY: totalCaffeine > 0 ? totalCaffeine : 5, // Minimumlevel für leere Tage
            color: color,
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.7),
                color,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            width: 12, // Schmalere Balken für mehr Platz
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxCaffeineValue,
              color: Colors.grey[200],
            ),
          ),
        ],
      ));
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      )),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Anpassung an die Bildschirmgröße
          final chartHeight = constraints.maxWidth < 360 ? 170.0 : 190.0;
          final isSmallScreen = constraints.maxWidth < 360;

          return Container(
            // Höhe reduziert um Overflow zu verhindern
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wichtig für korrektes Layoutverhalten
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Kaffeekonsum letzte Woche',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: darkAccentColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        DateFormat('dd.MM.').format(today.subtract(const Duration(days: 6))) +
                        '-' +
                        DateFormat('dd.MM.').format(today),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: chartHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4), // Reduziert für weniger Platz
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceBetween,
                        maxY: maxCaffeineValue,
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

                                final date = today.subtract(Duration(days: 6 - value.toInt()));
                                final isToday = date.day == today.day;

                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isToday)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: accentColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      const SizedBox(height: 2), // Weniger Abstand
                                      Container(
                                        decoration: BoxDecoration(
                                          color: isToday 
                                              ? accentColor.withOpacity(0.15)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isToday ? 4 : 0, 
                                            vertical: isToday ? 2 : 0
                                          ),
                                          child: Text(
                                            weekDays[dayIndex],
                                            style: TextStyle(
                                              color: isToday
                                                  ? darkAccentColor
                                                  : AppTheme.secondaryTextColor,
                                              fontWeight: isToday
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              fontSize: isSmallScreen ? 9 : 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              reservedSize: 24, // Reduziert für weniger Platz
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // Formatiere Zahlen für bessere Platzausnutzung
                                String label;
                                if (value >= 1000) {
                                  label = '${(value / 1000).toStringAsFixed(1)}k';
                                } else {
                                  label = value.toInt().toString();
                                }
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: AppTheme.secondaryTextColor,
                                      fontSize: isSmallScreen ? 8 : 9,
                                    ),
                                  ),
                                );
                              },
                              interval: maxCaffeineValue > 500 ? 200 : 100,
                              reservedSize: 40, // Mehr Platz für Y-Achsenbeschriftungen
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
                          horizontalInterval: maxCaffeineValue > 500 ? 200 : 100,
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: barGroups,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: darkAccentColor.withOpacity(0.9),
                            tooltipRoundedRadius: 16,
                            tooltipPadding: const EdgeInsets.all(12),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              // Berechne das Datum für diesen Balken
                              final date =
                                  today.subtract(Duration(days: 6 - group.x.toInt()));
                              final dateStr = DateFormat.yMMMd('de_DE').format(date);
                              
                              return BarTooltipItem(
                                '$dateStr\n',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${rod.toY.toInt() <= 5 ? '0' : rod.toY.toInt()} mg Koffein',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
  
  Color getGradientColor(double caffeineValue) {
    if (caffeineValue < 100) {
      return successColor.withOpacity(0.8);
    } else if (caffeineValue < 200) {
      return lightAccentColor;
    } else if (caffeineValue < 300) {
      return accentColor;
    } else if (caffeineValue < 400) {
      return warningColor;
    } else {
      return Colors.red[400]!;
    }
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

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      )),
      child: Row(
      children: [
        Expanded(
          child: Container(
              padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    accentColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                    padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.coffee_rounded,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutBack,
                    tween: Tween<double>(begin: 0, end: avgDrinksPerDay),
                    builder: (context, value, child) {
                      return Text(
                        value.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                          color: accentColor,
                      ),
                      );
                    },
                ),
                  const SizedBox(height: 4),
                Text(
                    'Kaffees pro Tag',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearPercentIndicator(
                    lineHeight: 6,
                    percent: (avgDrinksPerDay / 5).clamp(0.0, 1.0), // 5 als Referenz
                    backgroundColor: Colors.grey[200],
                    progressColor: accentColor,
                    barRadius: const Radius.circular(3),
                    padding: EdgeInsets.zero,
                    animation: true,
                    animationDuration: 1000,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
              padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    _getCaffeineColor(avgCaffeinePerDay / 400).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                    padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                      color: _getCaffeineColor(avgCaffeinePerDay / 400).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.bolt_rounded,
                      color: _getCaffeineColor(avgCaffeinePerDay / 400),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutBack,
                    tween: Tween<double>(begin: 0, end: avgCaffeinePerDay),
                    builder: (context, value, child) {
                      return Text(
                        '${value.toInt()} mg',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                          color: _getCaffeineColor(avgCaffeinePerDay / 400),
                      ),
                      );
                    }
                ),
                  const SizedBox(height: 4),
                Text(
                    'Koffein pro Tag',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearPercentIndicator(
                    lineHeight: 6,
                    percent: (avgCaffeinePerDay / 400).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    progressColor: _getCaffeineColor(avgCaffeinePerDay / 400),
                    barRadius: const Radius.circular(3),
                    padding: EdgeInsets.zero,
                    animation: true,
                    animationDuration: 1000,
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildFavoriteDrinks(
      BuildContext context, CoffeeProvider coffeeProvider) {
    // Zähle, wie oft jedes Getränk getrunken wurde
    final drinkCounts = <String, int>{};
    final drinkCaffeine = <String, double>{};

    for (final drink in coffeeProvider.drinks) {
      drinkCounts[drink.name] = (drinkCounts[drink.name] ?? 0) + 1;
      drinkCaffeine[drink.name] = drink.caffeineAmount;
    }

    // Sortiere nach Häufigkeit
    final sortedDrinks = drinkCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final favoriteCount = min(3, sortedDrinks.length);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      )),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              Colors.white,
              lightAccentColor.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: favoriteCount == 0
            ? _buildEmptyFavorites(context)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Was du am liebsten trinkst',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: darkAccentColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(favoriteCount, (index) {
                    final entry = sortedDrinks[index];
                    final rank = index + 1;
                    final caffeineAmount = drinkCaffeine[entry.key] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center, // Vertikale Zentrierung
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _getMedalColor(rank).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _getMedalEmoji(rank),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center, // Vertikale Zentrierung
                                children: [
                                  Text(
                                    entry.key,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: darkAccentColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    crossAxisAlignment: WrapCrossAlignment.center, // Zentrierung
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${entry.value}×',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: accentColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getCaffeineColor(caffeineAmount / 400).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${caffeineAmount.toInt()} mg',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: _getCaffeineColor(caffeineAmount / 400),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.favorite,
                              color: _getMedalColor(rank),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
  
  Widget _buildEmptyFavorites(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.coffee_outlined,
          size: 48,
          color: accentColor.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'Noch keine Getränke getrunken',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Deine Lieblingsgetränke werden hier angezeigt',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.tertiaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return warningColor;
      case 2:
        return accentColor;
      case 3:
        return lightAccentColor;
      default:
        return Colors.grey;
    }
  }
  
  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '🏆';
    }
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

    // Berechne, wann der Nutzer koffeinfrei sein wird
    DateTime caffeineFreeTime = now.add(const Duration(hours: 12));
    bool willBeCaffeineFree = false;
    for (int i = 0; i < timePoints.length; i++) {
      if (caffeineValues[i] <= 5) { // Wir betrachten unter 5mg als "koffeinfrei"
        caffeineFreeTime = timePoints[i];
        willBeCaffeineFree = true;
        break;
      }
    }
    
    // Berechne, wie viele weitere Tassen Kaffee heute erlaubt wären
    final currentCaffeine = caffeineValues.first;
    final caffeineLimit = coffeeProvider.caffeineLimit;
    final caffeinePercentage = (currentCaffeine / caffeineLimit).clamp(0.0, 1.0);
    final remainingCaffeine = (caffeineLimit - currentCaffeine).clamp(0, double.infinity);
    final espressoAmount = 60.0; // Durchschnittlicher Koffeingehalt eines Espresso in mg
    final filterCoffeeAmount = 120.0; // Durchschnittlicher Koffeingehalt eines Filterkaffees in mg
    
    final remainingEspressos = (remainingCaffeine / espressoAmount).floor();
    final remainingCoffees = (remainingCaffeine / filterCoffeeAmount).floor();
    
    String caffeineMessage;
    Color messageColor;
    IconData messageIcon;
    
    if (caffeinePercentage >= 0.8) {
      // Über oder nahe am Limit
      final formatter = DateFormat('HH:mm', 'de_DE');
      caffeineMessage = 'Limit fast erreicht. Nächster Kaffee besser nach ${formatter.format(now.add(Duration(hours: 4)))} Uhr';
      messageColor = warningColor;
      messageIcon = Icons.access_time_rounded;
    } else if (caffeinePercentage < 0.4) {
      // Viel Spielraum
      caffeineMessage = 'Du hast heute noch viel Spielraum – gönn dir ruhig noch eine Tasse.';
      messageColor = successColor;
      messageIcon = Icons.coffee;
    } else {
      // Zwischen 40-80%
      caffeineMessage = 'Du bist gut in Balance – weiter so.';
      messageColor = accentColor;
      messageIcon = Icons.check_circle_outline;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      )),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Anpassung an die Bildschirmgröße
          final chartHeight = constraints.maxWidth < 360 ? 170.0 : 190.0;
          final isSmallScreen = constraints.maxWidth < 360;

          return Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  lightAccentColor.withOpacity(0.07),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wichtig für korrektes Layout
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 8,
                  children: [
                    Text(
                      'Koffeinabbau',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: darkAccentColor,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: accentColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm', 'de_DE').format(now),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: chartHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8), // Extra Padding unten
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
                          horizontalInterval: 100,
                        ),
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
                                if (value % (isSmallScreen ? 4 : 3) == 0 && value.toInt() < timePoints.length) {
                                  final time = timePoints[value.toInt()];
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4, 
                                        vertical: 2
                                      ),
                                      decoration: BoxDecoration(
                                        color: time.hour == now.hour
                                            ? accentColor.withOpacity(0.15)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${time.hour}:00',
                                        style: TextStyle(
                                          color: time.hour == now.hour
                                              ? darkAccentColor
                                              : AppTheme.secondaryTextColor,
                                          fontSize: isSmallScreen ? 8 : 9,
                                          fontWeight: time.hour == now.hour
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              reservedSize: 28, // Mehr Platz für X-Achsenbeschriftungen
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // Formatiere Zahlen für bessere Platzausnutzung
                                String label;
                                if (value >= 1000) {
                                  label = '${(value / 1000).toStringAsFixed(1)}k';
                                } else {
                                  label = value.toInt().toString();
                                }
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: AppTheme.secondaryTextColor,
                                      fontSize: isSmallScreen ? 8 : 9,
                                    ),
                                  ),
                                );
                              },
                              interval: 100,
                              reservedSize: 40, // Mehr Platz für Y-Achsenbeschriftungen
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: darkAccentColor.withOpacity(0.9),
                            tooltipRoundedRadius: 16,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final time = timePoints[spot.x.toInt()];
                                final formattedTime = DateFormat('HH:mm', 'de_DE').format(time);
                                return LineTooltipItem(
                                  '$formattedTime\n',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${spot.y.toInt()} mg',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
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
                            color: accentColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                final isCurrent = index == 0;
                                final isCaffeineFree = caffeineValues[index] <= 5;
                                
                                Color dotColor = accentColor;
                                if (isCurrent) {
                                  dotColor = darkAccentColor;
                                } else if (isCaffeineFree) {
                                  dotColor = successColor;
                                }
                                
                                return FlDotCirclePainter(
                                  radius: isCurrent ? 4 : 2.5,
                                  color: dotColor,
                                  strokeWidth: 1.5,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  accentColor.withOpacity(0.3),
                                  accentColor.withOpacity(0.1),
                                  accentColor.withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        minY: 0,
                        maxY: caffeineValues.first > 400 ? caffeineValues.first * 1.1 : 400,
                        clipData: FlClipData.all(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F4F0), // Leicht abgesetzter, warmer Farbton
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: messageColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: messageColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          messageIcon,
                          color: messageColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          caffeineMessage,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: darkAccentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

class CoffeeCupPainter extends CustomPainter {
  final double fillLevel;
  final bool isAnimated;
  final double animationValue;

  CoffeeCupPainter({
    required this.fillLevel, 
    this.isAnimated = false, 
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Schatten für die Tasse
    final shadowPath = Path()
      ..moveTo(width * 0.2, height * 0.25)
      ..lineTo(width * 0.2, height * 0.8)
      ..quadraticBezierTo(width * 0.2, height * 0.9, width * 0.3, height * 0.9)
      ..lineTo(width * 0.7, height * 0.9)
      ..quadraticBezierTo(width * 0.8, height * 0.9, width * 0.8, height * 0.8)
      ..lineTo(width * 0.8, height * 0.25)
      ..quadraticBezierTo(width * 0.5, height * 0.35, width * 0.2, height * 0.25)
      ..close();
      
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawPath(shadowPath, shadowPaint);

    // Definiere die Tasse mit Rundungen
    final cupPath = Path()
      ..moveTo(width * 0.2, height * 0.2)
      ..lineTo(width * 0.2, height * 0.8)
      ..quadraticBezierTo(width * 0.2, height * 0.9, width * 0.3, height * 0.9)
      ..lineTo(width * 0.7, height * 0.9)
      ..quadraticBezierTo(width * 0.8, height * 0.9, width * 0.8, height * 0.8)
      ..lineTo(width * 0.8, height * 0.2)
      ..quadraticBezierTo(width * 0.65, height * 0.15, width * 0.5, height * 0.15)
      ..quadraticBezierTo(width * 0.35, height * 0.15, width * 0.2, height * 0.2)
      ..close();

    // Zeichne die Tasse
    final cupPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white,
          Colors.grey[50]!,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(cupPath, cupPaint);

    // Zeichne den Tassenrand mit Farbverlauf
    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          _StatsScreenState.lightAccentColor.withOpacity(0.8),
          Colors.grey[400]!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(cupPath, borderPaint);

    // Zeichne Highlights auf der Tasse (Glanzeffekt)
    final highlightPath = Path()
      ..moveTo(width * 0.25, height * 0.25)
      ..quadraticBezierTo(width * 0.35, height * 0.22, width * 0.4, height * 0.25)
      ..quadraticBezierTo(width * 0.45, height * 0.28, width * 0.25, height * 0.3)
      ..close();
      
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(highlightPath, highlightPaint);

    // Zeichne den Henkel mit Farbverlauf
    final handlePath = Path()
      ..moveTo(width * 0.8, height * 0.3)
      ..quadraticBezierTo(
          width * 0.95, height * 0.35, width * 0.95, height * 0.5)
      ..quadraticBezierTo(
          width * 0.95, height * 0.65, width * 0.8, height * 0.7);
          
    final handlePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          _StatsScreenState.lightAccentColor.withOpacity(0.8),
          Colors.grey[400]!,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(handlePath, handlePaint);

    // Zeichne oberen Rand der Tasse
    final rimPath = Path()
      ..moveTo(width * 0.2, height * 0.2)
      ..quadraticBezierTo(width * 0.35, height * 0.15, width * 0.5, height * 0.15)
      ..quadraticBezierTo(width * 0.65, height * 0.15, width * 0.8, height * 0.2);
      
    canvas.drawPath(rimPath, borderPaint);

    // Zeichne den Kaffee in der Tasse mit Animation und basierend auf Koffeinlevel
    if (fillLevel > 0) {
      // Berechne die tatsächliche Füllhöhe mit Animation
      double animatedFillLevel = isAnimated 
          ? fillLevel * animationValue 
          : fillLevel;
      
      // Füllstand basierend auf dem Koffeinlevel
      final fillHeight = height * 0.8 - (height * 0.55 * animatedFillLevel);
      
      // Kaffeeoberfläche mit sanfter Kurve
      final coffeeSurfacePath = Path()
        ..moveTo(width * 0.2, fillHeight)
        ..quadraticBezierTo(width * 0.5, fillHeight - height * 0.02, width * 0.8, fillHeight);
      
      // Vollständiger Kaffeepfad
      final coffeePath = Path()
        ..moveTo(width * 0.2, fillHeight)
        ..quadraticBezierTo(width * 0.5, fillHeight - height * 0.02, width * 0.8, fillHeight)
        ..lineTo(width * 0.8, height * 0.8)
        ..quadraticBezierTo(width * 0.8, height * 0.9, width * 0.7, height * 0.9)
        ..lineTo(width * 0.3, height * 0.9)
        ..quadraticBezierTo(width * 0.2, height * 0.9, width * 0.2, height * 0.8)
        ..close();

      // Kaffeefarbe basierend auf Füllstand
      final coffeeColor = _getCoffeeColor(fillLevel);

      final coffeePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            coffeeColor,
            coffeeColor.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, fillHeight, width, height - fillHeight))
        ..style = PaintingStyle.fill;

      canvas.drawPath(coffeePath, coffeePaint);
      
      // Zeichne Glanzeffekt auf dem Kaffee
      final coffeeHighlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
        
      canvas.drawPath(coffeeSurfacePath, coffeeHighlightPaint);
    }

    // Zeichne Dampf, wenn der Kaffee heiß ist (hoher Koffeingehalt)
    if (fillLevel > 0.5 && isAnimated) {
      final steamPaint = Paint()
        ..color = _StatsScreenState.lightAccentColor.withOpacity(animationValue * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      // Erstelle Dampfpfade mit Animation
      final dampfOffset = sin(animationValue * 3) * width * 0.02;

      // Linker Dampfstrom
      final leftSteamPath = Path()
        ..moveTo(width * 0.35, height * 0.2)
        ..quadraticBezierTo(
            width * (0.3 + dampfOffset), height * 0.1, 
            width * (0.35 - dampfOffset), height * 0.05);

      // Mittlerer Dampfstrom
      final middleSteamPath = Path()
        ..moveTo(width * 0.5, height * 0.15)
        ..quadraticBezierTo(
            width * (0.55 - dampfOffset), height * 0.05, 
            width * (0.5 + dampfOffset), height * 0);

      // Rechter Dampfstrom
      final rightSteamPath = Path()
        ..moveTo(width * 0.65, height * 0.2)
        ..quadraticBezierTo(
            width * (0.7 - dampfOffset), height * 0.1, 
            width * (0.65 + dampfOffset), height * 0.05);

      canvas.drawPath(leftSteamPath, steamPaint);
      canvas.drawPath(middleSteamPath, steamPaint);
      canvas.drawPath(rightSteamPath, steamPaint);
    }
  }
  
  Color _getCoffeeColor(double fillLevel) {
    if (fillLevel < 0.3) {
      return _StatsScreenState.lightAccentColor; // Hellbraun für niedrigen Koffeingehalt
    } else if (fillLevel < 0.6) {
      return _StatsScreenState.accentColor; // Mittelbraun für mittleren Koffeingehalt
    } else {
      return _StatsScreenState.darkAccentColor; // Dunkelbraun für hohen Koffeingehalt
    }
  }

  @override
  bool shouldRepaint(covariant CoffeeCupPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel || 
           oldDelegate.animationValue != animationValue;
  }
}
