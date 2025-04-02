import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/coffee_provider.dart';
import '../models/coffee_drink.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Kaffeefarben - weichere, pastellige Töne
const Color accentColor = Color(0xFF8D6E63); // Sanftes Braun als Hauptfarbe
const Color lightAccentColor = Color(0xFFBCAAA4); // Helles Braun
const Color darkAccentColor = Color(0xFF5D4037); // Dunkles Braun
const Color warningColor = Color(0xFFE6A278); // Warmes Orange als Warnfarbe
const Color successColor = Color(0xFF81C784); // Sanftes Grün für Erfolg

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
  String _userName = 'Kaffeeliebhaber';
  String _userEmail = 'kaffee@beispiel.de';
  DateTime _joinDate = DateTime(2024, 3, 1);

  // Separate Controller für die Tab-Inhalte
  final _overviewScrollController = ScrollController();
  final _historyScrollController = ScrollController();
  final _settingsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
      _userName = prefs.getString('user_name') ?? 'Kaffeeliebhaber';
      _userEmail = prefs.getString('user_email') ?? 'kaffee@beispiel.de';
      final joinDateStr = prefs.getString('join_date');
      if (joinDateStr != null) {
        _joinDate = DateTime.parse(joinDateStr);
      }
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    await prefs.setString('user_email', _userEmail);
    await prefs.setString('join_date', _joinDate.toIso8601String());
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
                  backgroundColor: accentColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: AnimatedOpacity(
                      opacity: _showAppBarTitle ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Text('Dein Profil'),
                    ),
                    titlePadding: const EdgeInsets.only(bottom: 52),
                    background: _buildProfileHeader(),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      color: accentColor,
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
                SafeArea(
                  top: false,
                  bottom: true,
                  child: _buildOverviewTab(provider),
                ),
                SafeArea(
                  top: false,
                  bottom: true,
                  child: _buildHistoryTab(provider),
                ),
                SafeArea(
                  top: false,
                  bottom: true,
                  child: _buildSettingsTab(provider),
                ),
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
            accentColor.withOpacity(0.8),
            accentColor,
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
                                  color: accentColor,
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
                            color: accentColor,
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
                _userName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Seit dem ${_formatDate(_joinDate)} dabei',
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
    final averageConsumption = provider.getAverageDailyConsumption();
    final caffeineLimit = provider.caffeineLimit;

    return ListView(
      controller: _overviewScrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      children: [
        Text(
          'Deine Kaffeegewohnheiten',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: darkAccentColor,
                fontWeight: FontWeight.bold,
              ),
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
                accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Koffein',
                '${totalCaffeine.toStringAsFixed(0)} mg',
                Icons.bolt,
                warningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Chart section
        Text(
          'Monatsübersicht',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: darkAccentColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildMonthlyChart(provider),
        const SizedBox(height: 24),

        // Insights
        Text(
          'Interessante Fakten',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: darkAccentColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          context,
          'Lieblingsgetränk',
          mostPopularDrink,
          'Du hast dieses Getränk am häufigsten getrunken',
          Icons.favorite,
          accentColor,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          context,
          'Kaffee-Wochentag',
          weekdayWithMostCoffee,
          'An diesem Tag trinkst du am meisten Kaffee',
          Icons.date_range,
          lightAccentColor,
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          context,
          'Deine Koffein-Bilanz',
          averageConsumption > caffeineLimit ? 'Über dem Limit' : 'Moderat',
          'Durchschnittlich ${averageConsumption.toStringAsFixed(0)} mg pro Tag',
          Icons.check_circle,
          averageConsumption > caffeineLimit ? warningColor : successColor,
        ),
        const SizedBox(height: 24),

        // Achievements
        Text(
          'Deine Erfolge',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: darkAccentColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildAchievementProgress(
          context,
          'Kaffee-Enthusiast',
          'Trinke 100 Tassen Kaffee',
          totalDrinks / 100,
        ),
        const SizedBox(height: 12),
        _buildAchievementProgress(
          context,
          'Vielfältiger Geschmack',
          'Probiere 10 verschiedene Kaffeesorten',
          provider.getFavoriteDrinks().length / 10,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
              const Spacer(),
              const Icon(
                Icons.trending_up,
                color: successColor,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '+12%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: successColor,
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
                  color: darkAccentColor,
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
      final date = DateTime.now().subtract(Duration(days: 29 - index));
      final drinks = provider.getDrinksForDay(date);
      final totalCaffeine = drinks.fold<double>(
        0,
        (sum, drink) => sum + drink.caffeineAmount,
      );
      return FlSpot(index.toDouble(), totalCaffeine);
    });

    return AspectRatio(
      aspectRatio: 1.7,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(8, 24, 20, 24),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 100,
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
                    final date = DateTime.now().subtract(Duration(days: 29 - value.toInt()));
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        '${date.day}.${date.month}',
                        style: const TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 100,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    );
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
            maxY: provider.caffeineLimit,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: accentColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: accentColor.withOpacity(0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: accentColor.withOpacity(0.8),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toInt()} mg',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: darkAccentColor,
                        fontWeight: FontWeight.bold,
                      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: darkAccentColor,
                            fontWeight: FontWeight.bold,
                          ),
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
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.coffee_outlined,
              size: 64,
              color: accentColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Noch keine Kaffees getrunken',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
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
                      color: darkAccentColor,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.coffee,
              color: accentColor,
            ),
          ),
        ),
        title: Text(
          drink.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: darkAccentColor,
                fontWeight: FontWeight.bold,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          time,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
        ),
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
                      color: accentColor,
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

  Widget _buildSettingsTab(CoffeeProvider provider) {
    return ListView(
      controller: _settingsScrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      children: [
        _buildSettingsCategory('Account'),
        _buildSettingsItem(
          'Profil bearbeiten',
          Icons.person,
          accentColor,
          onTap: () {
            _showProfileEditDialog();
          },
        ),
        _buildSettingsItem(
          'Benachrichtigungen',
          Icons.notifications,
          lightAccentColor,
          onTap: () {
            _showNotificationsSettings();
          },
        ),
        _buildSettingsItem(
          'Datenschutz',
          Icons.lock,
          darkAccentColor,
          onTap: () {
            _showPrivacySettings();
          },
        ),
        _buildSettingsCategory('Präferenzen'),
        _buildSettingsItem(
          'Einheiten',
          Icons.straighten,
          accentColor,
          onTap: () {
            _showUnitsSettings();
          },
        ),
        _buildSettingsItem(
          'Koffeinlimit anpassen',
          Icons.warning,
          warningColor,
          onTap: () {
            _showCaffeineLimitDialog();
          },
        ),
        _buildSettingsCategory('App'),
        _buildSettingsItem(
          'Über uns',
          Icons.info,
          accentColor,
          onTap: () {
            _showAboutDialog();
          },
        ),
        _buildSettingsItem(
          'Bewerten',
          Icons.star,
          accentColor,
          onTap: () {
            // Diese Funktion würde normalerweise zum App Store / Play Store führen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Öffne Store zum Bewerten'),
                backgroundColor: accentColor,
              ),
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
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: darkAccentColor,
              fontWeight: FontWeight.bold,
            ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: darkAccentColor,
                          fontWeight: FontWeight.bold,
                        ),
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
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Dein Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Deine Email-Adresse',
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
              setState(() {
                _userName = nameController.text;
                _userEmail = emailController.text;
              });
              _saveUserData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil aktualisiert'),
                  backgroundColor: accentColor,
                ),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: darkAccentColor,
                        fontWeight: FontWeight.bold,
                      ),
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
                              'Benachrichtigungseinstellungen gespeichert'),
                          backgroundColor: accentColor,
                        ),
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: darkAccentColor,
                      fontWeight: FontWeight.bold,
                    ),
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
                      content: Text(
                          'Datenschutzeinstellungen gespeichert'),
                      backgroundColor: accentColor,
                    ),
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
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: darkAccentColor,
                ),
          ),
          value: value,
          onChanged: (newValue) {
            setState(() => value = newValue);
          },
        );
      },
    );
  }

  void _showUnitsSettings() {
    String selectedUnit = 'mg';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Einheiten',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: darkAccentColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Milligramm (mg)'),
                  value: 'mg',
                  groupValue: selectedUnit,
                  onChanged: (value) {
                    setState(() => selectedUnit = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Gramm (g)'),
                  value: 'g',
                  groupValue: selectedUnit,
                  onChanged: (value) {
                    setState(() => selectedUnit = value!);
                  },
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
                        'Einheit auf ${selectedUnit == 'mg' ? 'Milligramm' : 'Gramm'} geändert',
                      ),
                      backgroundColor: accentColor,
                    ),
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

  void _showCaffeineLimitDialog() {
    final coffeeProvider = Provider.of<CoffeeProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Verwende das aktuelle Limit aus dem Provider
    double caffeineLimit = coffeeProvider.caffeineLimit;
    
    // Prüfe, ob das Limit individuell berechnet wurde
    final userProfile = userProvider.userProfile;
    final bool isCustomCalculatedLimit = userProfile != null && 
                                        userProfile.weight != null && 
                                        userProfile.caffeineLimit == userProfile.weight! * 3;

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
                  activeColor: accentColor,
                ),
                const SizedBox(height: 8),
                isCustomCalculatedLimit
                  ? Text(
                      'Basierend auf deinem Gewicht (${userProfile!.weight!.toStringAsFixed(0)} kg)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                    )
                  : Text(
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
                  // Aktualisiere beide Provider
                  coffeeProvider.setCaffeineLimit(caffeineLimit);
                  if (userProfile != null) {
                    userProvider.updateCaffeineLimit(caffeineLimit);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Koffeinlimit auf ${caffeineLimit.toStringAsFixed(0)} mg gesetzt',
                      ),
                      backgroundColor: accentColor,
                    ),
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
        title: Text('Coffely'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.aboutCoffely,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.aboutDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.features,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.developedWith,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text('© 2025 Wizard Dynamics GmbH'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
