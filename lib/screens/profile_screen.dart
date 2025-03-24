import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/coffee_provider.dart';
import '../models/coffee_drink.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  // Füge separate Controller für die Tab-Inhalte hinzu
  final _overviewScrollController = ScrollController();
  final _historyScrollController = ScrollController();
  final _settingsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  Future<void> _saveProfileImage(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString('profile_image_path', path);
    } else {
      await prefs.remove('profile_image_path');
    }
    setState(() {
      _profileImagePath = path;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _overviewScrollController.dispose();
    _historyScrollController.dispose();
    _settingsScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 120 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 120 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: AppTheme.primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: AnimatedOpacity(
                      opacity: _showAppBarTitle ? 1.0 : 0.0,
                      duration: AppTheme.animationDuration,
                      child: const Text('Dein Profil'),
                    ),
                    titlePadding: const EdgeInsets.only(bottom: 52),
                    background: _buildProfileHeader(),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      color: AppTheme.primaryColor,
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withOpacity(0.7),
                        labelStyle: const TextStyle(fontSize: 14),
                        tabAlignment: TabAlignment.fill,
                        tabs: const [
                          Tab(text: 'Übersicht'),
                          Tab(text: 'Verlauf'),
                          Tab(text: 'Einstellungen'),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(provider),
                _buildHistoryTab(provider),
                _buildSettingsTab(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.primaryColor,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showProfileImageOptions(),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipOval(
                        child: _profileImagePath != null
                            ? Image.file(
                                File(_profileImagePath!),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kaffeeliebhaber',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Seit dem 01.03.2024 dabei',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(CoffeeProvider provider) {
    final totalDrinks = provider.drinks.length;
    final totalCaffeine = provider.drinks.fold<double>(
      0,
      (sum, drink) => sum + drink.caffeineAmount,
    );

    final mostPopularDrink = _getMostPopularDrink(provider);
    final weekdayWithMostCoffee = _getWeekdayWithMostCoffee(provider);

    return SingleChildScrollView(
      controller: _overviewScrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deine Kaffeegewohnheiten',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Getränke',
                  totalDrinks.toString(),
                  Icons.local_cafe,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Koffein',
                  '${totalCaffeine.toStringAsFixed(0)} mg',
                  Icons.bolt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart section
          Text(
            'Monatsübersicht',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildMonthlyChart(provider),
          const SizedBox(height: 24),

          // Insights
          Text(
            'Interessante Fakten',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            context,
            'Lieblingsgetränk',
            mostPopularDrink,
            'Du hast dieses Getränk am häufigsten getrunken',
            Icons.favorite,
            AppTheme.accentColor,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            context,
            'Kaffee-Wochentag',
            weekdayWithMostCoffee,
            'An diesem Tag trinkst du am meisten Kaffee',
            Icons.date_range,
            AppTheme.secondaryColor,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            context,
            'Deine Koffein-Bilanz',
            'Moderat',
            'Dein Koffeinkonsum liegt im gesunden Bereich',
            Icons.check_circle,
            AppTheme.successColor,
          ),
          const SizedBox(height: 24),

          // Achievements
          Text(
            'Deine Erfolge',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildAchievementProgress(
            context,
            'Kaffee-Enthusiast',
            'Trinke 100 Tassen Kaffee',
            0.67,
          ),
          const SizedBox(height: 12),
          _buildAchievementProgress(
            context,
            'Vielfältiger Geschmack',
            'Probiere 10 verschiedene Kaffeesorten',
            0.8,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.trending_up,
                color: AppTheme.successColor,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '+12%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(CoffeeProvider provider) {
    final List<FlSpot> spots = List.generate(30, (index) {
      // In einer echten App würde hier die tatsächliche Anzahl der getrunkenen Tassen pro Tag stehen
      // Für dieses Beispiel simulieren wir zufällige Daten
      final random = index % 3 == 0
          ? 4.0
          : (index % 7 == 0 ? 5.0 : (index % 2 == 0 ? 3.0 : 2.0));
      return FlSpot(index.toDouble(), random);
    });

    return AspectRatio(
      aspectRatio: 1.7,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        padding: const EdgeInsets.fromLTRB(8, 24, 20, 24),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey[300],
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 5,
                  getTitlesWidget: (value, meta) {
                    const days = ['1', '5', '10', '15', '20', '25', '30'];
                    final index = value ~/ 5;
                    if (index >= 0 && index < days.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          days[index],
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value % 1 == 0) {
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
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 30,
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 29,
            minY: 0,
            maxY: 6,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
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
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: AppTheme.primaryColor.withOpacity(0.8),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toInt()} Tassen',
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementProgress(
    BuildContext context,
    String title,
    String description,
    double progress,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(CoffeeProvider provider) {
    final drinks = provider.drinks;

    if (drinks.isEmpty) {
      return const Center(
        child: Text('Noch keine Kaffees getrunken'),
      );
    }

    // Gruppiere Getränke nach Tagen
    final Map<String, List<CoffeeDrink>> groupedDrinks = {};
    for (final drink in drinks) {
      final date = _formatDate(drink.timestamp);
      if (!groupedDrinks.containsKey(date)) {
        groupedDrinks[date] = [];
      }
      groupedDrinks[date]!.add(drink);
    }

    // Sortiere Tage absteigend (neueste zuerst)
    final sortedDates = groupedDrinks.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      controller: _historyScrollController,
      padding: const EdgeInsets.all(20),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final drinksForDate = groupedDrinks[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                date,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...drinksForDate.map((drink) => _buildDrinkHistoryItem(drink)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildDrinkHistoryItem(CoffeeDrink drink) {
    final time = _formatTime(drink.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.coffee,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        title: Text(
          drink.name,
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(time),
        trailing: SizedBox(
          width: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${drink.caffeineAmount.toStringAsFixed(0)} mg',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Koffein',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      controller: _settingsScrollController,
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingsCategory('Account'),
        _buildSettingsItem(
          'Profil bearbeiten',
          Icons.person,
          AppTheme.primaryColor,
          onTap: () {
            _showProfileEditDialog();
          },
        ),
        _buildSettingsItem(
          'Benachrichtigungen',
          Icons.notifications,
          AppTheme.accentColor,
          onTap: () {
            _showNotificationsSettings();
          },
        ),
        _buildSettingsItem(
          'Datenschutz',
          Icons.lock,
          AppTheme.secondaryColor,
          onTap: () {
            _showPrivacySettings();
          },
        ),
        _buildSettingsCategory('Präferenzen'),
        _buildSettingsItem(
          'Einheiten',
          Icons.straighten,
          Colors.teal,
          onTap: () {
            _showUnitsSettings();
          },
        ),
        _buildSettingsItem(
          'Koffeinlimit anpassen',
          Icons.warning,
          Colors.orange,
          onTap: () {
            _showCaffeineLimitDialog();
          },
        ),
        _buildSettingsCategory('App'),
        _buildSettingsItem(
          'Über uns',
          Icons.info,
          Colors.blue,
          onTap: () {
            _showAboutDialog();
          },
        ),
        _buildSettingsItem(
          'Bewerten',
          Icons.star,
          Colors.amber,
          onTap: () {
            // Diese Funktion würde normalerweise zum App Store / Play Store führen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Öffne Store zum Bewerten')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.secondaryTextColor,
                      size: 16,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Heute';
    } else if (difference == 1) {
      return 'Gestern';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return '$day.$month.$year';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute Uhr';
  }

  String _getMostPopularDrink(CoffeeProvider provider) {
    final drinks = provider.drinks;
    if (drinks.isEmpty) return 'Keine Daten';

    final Map<String, int> drinkCounts = {};
    for (final drink in drinks) {
      drinkCounts[drink.name] = (drinkCounts[drink.name] ?? 0) + 1;
    }

    String mostPopular = '';
    int highestCount = 0;
    drinkCounts.forEach((drink, count) {
      if (count > highestCount) {
        mostPopular = drink;
        highestCount = count;
      }
    });

    return mostPopular;
  }

  String _getWeekdayWithMostCoffee(CoffeeProvider provider) {
    final drinks = provider.drinks;
    if (drinks.isEmpty) return 'Keine Daten';

    final Map<int, int> weekdayCounts = {};
    for (final drink in drinks) {
      final weekday = drink.timestamp.weekday;
      weekdayCounts[weekday] = (weekdayCounts[weekday] ?? 0) + 1;
    }

    int mostPopularWeekday = 1;
    int highestCount = 0;
    weekdayCounts.forEach((weekday, count) {
      if (count > highestCount) {
        mostPopularWeekday = weekday;
        highestCount = count;
      }
    });

    const weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag'
    ];

    return weekdays[mostPopularWeekday - 1];
  }

  void _showProfileImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profilbild ändern',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.photo_camera,
                  title: 'Kamera',
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.photo_library,
                  title: 'Galerie',
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.gallery);
                  },
                ),
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.delete,
                  title: 'Entfernen',
                  onTap: () {
                    Navigator.pop(context);
                    _saveProfileImage(null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profilbild wurde entfernt'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (image != null) {
        await _saveProfileImage(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profilbild wurde aktualisiert'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden des Bildes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showProfileEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Dein Name',
              ),
              controller: TextEditingController(text: 'Kaffeeliebhaber'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Deine Email-Adresse',
              ),
              controller: TextEditingController(text: 'kaffee@beispiel.de'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil aktualisiert')),
              );
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool dailyReminder = true;
          bool weeklyStats = true;

          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Benachrichtigungen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Tägliche Erinnerung'),
                  subtitle: const Text(
                      'Erinnere mich täglich an meine Kaffeegewohnheiten'),
                  value: dailyReminder,
                  onChanged: (value) {
                    setState(() => dailyReminder = value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Wöchentliche Statistik'),
                  subtitle:
                      const Text('Erhalte wöchentlich eine Zusammenfassung'),
                  value: weeklyStats,
                  onChanged: (value) {
                    setState(() => weeklyStats = value);
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Benachrichtigungseinstellungen gespeichert')),
                      );
                    },
                    child: const Text('Speichern'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                'Datenschutzeinstellungen',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              const Text('Wir nehmen den Schutz deiner Daten ernst. '
                  'Alle Daten werden lokal auf deinem Gerät gespeichert und nicht geteilt.'),
              const SizedBox(height: 16),
              _buildPrivacyOption('Lokale Datenspeicherung', true),
              _buildPrivacyOption('Anonyme Nutzungsstatistiken', false),
              _buildPrivacyOption('Personalisierte Vorschläge', false),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Datenschutzeinstellungen gespeichert')),
                  );
                },
                child: const Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyOption(String title, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool value = initialValue;
        return SwitchListTile(
          title: Text(title),
          value: value,
          onChanged: (newValue) {
            setState(() => value = newValue);
          },
        );
      },
    );
  }

  void _showUnitsSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Einheiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Milligramm (mg)'),
              value: 'mg',
              groupValue: 'mg', // Aktuell ausgewählter Wert
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Gramm (g)'),
              value: 'g',
              groupValue: 'mg',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Einheiten aktualisiert')),
              );
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _showCaffeineLimitDialog() {
    double caffeineLimit = 400.0; // Standard-Wert

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Koffeinlimit anpassen'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Setze dein tägliches Koffeinlimit (in mg):',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  '${caffeineLimit.toStringAsFixed(0)} mg',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Slider(
                  value: caffeineLimit,
                  min: 100,
                  max: 800,
                  divisions: 14,
                  label: caffeineLimit.toStringAsFixed(0),
                  onChanged: (value) {
                    setState(() {
                      caffeineLimit = value;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Empfohlen: 400 mg pro Tag',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Abbrechen'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Koffeinlimit auf ${caffeineLimit.toStringAsFixed(0)} mg gesetzt')),
                  );
                },
                child: const Text('Speichern'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.coffee,
              color: AppTheme.primaryColor,
              size: 36,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Coffely'),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Coffely ist deine persönliche Kaffee-Tracking-App, die dir hilft, '
                  'deinen Kaffeekonsum zu überwachen und zu optimieren.'),
              const SizedBox(height: 12),
              const Text(
                  'Mit Coffely kannst du deine tägliche Koffeinaufnahme verfolgen, '
                  'deinen Konsum visualisieren und ein gesundes Gleichgewicht finden. '
                  'Die App bietet dir personalisierte Einblicke und hilft dir, deine Kaffeegewohnheiten besser zu verstehen.'),
              const SizedBox(height: 12),
              const Text('Features:\n'
                  '• Tracking von Kaffeegetränken und Koffeingehalt\n'
                  '• Persönliche Statistiken und Trends\n'
                  '• Visualisierung deines Kaffeekonsums\n'
                  '• Erinnerungen und Benachrichtigungen\n'
                  '• Empfehlungen für einen ausgewogenen Koffeinkonsum'),
              const SizedBox(height: 16),
              const Text('Entwickelt mit ♥ und viel Kaffee in Deutschland'),
              const SizedBox(height: 12),
              Text(
                '©2024 Coffely Team',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }
}
