import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/coffee_provider.dart';
import '../theme/app_theme.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Herausforderungen',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verbessere deinen Kaffeekonsum und sammle Auszeichnungen',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildTabBar(),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDailyChallenges(),
                  _buildAchievements(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: AppTheme.primaryColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.primaryColor,
        labelStyle: Theme.of(context).textTheme.labelLarge,
        unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'Tägliche Aufgaben'),
          Tab(text: 'Auszeichnungen'),
        ],
      ),
    );
  }

  Widget _buildDailyChallenges() {
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildDailyChallenge(
              title: 'Moderater Konsum',
              description: 'Bleibe heute unter 200mg Koffein',
              icon: Icons.emoji_emotions_outlined,
              progressPercent: _calculateKoffeinProgress(provider, 200),
              reward: '10 Punkte',
            ),
            _buildDailyChallenge(
              title: 'Neue Erfahrung',
              description: 'Probiere eine neue Kaffeesorte',
              icon: Icons.new_releases_outlined,
              progressPercent: _calculateNewCoffeeProgress(provider),
              reward: '20 Punkte',
            ),
            _buildDailyChallenge(
              title: 'Früher Vogel',
              description: 'Trinke deinen Kaffee vor 10 Uhr',
              icon: Icons.wb_sunny_outlined,
              progressPercent: _calculateMorningCoffeeProgress(provider),
              reward: '15 Punkte',
            ),
            _buildDailyChallenge(
              title: 'Perfekter Rhythmus',
              description: 'Halte 4 Stunden zwischen Kaffees ein',
              icon: Icons.timer_outlined,
              progressPercent: _calculateTimingProgress(provider),
              reward: '25 Punkte',
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.9),
                    AppTheme.secondaryColor.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Öffne Challenge-Einstellungen
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add_outlined,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mehr Herausforderungen',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                              Text(
                                'Erstelle deine eigene Kaffee-Challenge',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _calculateKoffeinProgress(CoffeeProvider provider, int targetAmount) {
    final todayDrinks = provider.getTodayDrinks();
    final totalCaffeine = todayDrinks.fold<double>(
      0,
      (sum, drink) => sum + drink.caffeineAmount,
    );

    if (totalCaffeine <= targetAmount) {
      return totalCaffeine / targetAmount;
    } else {
      return 0; // Fehlgeschlagen, wenn über dem Limit
    }
  }

  double _calculateNewCoffeeProgress(CoffeeProvider provider) {
    // Simuliere, ob heute ein neuer Kaffee probiert wurde
    // In der echten App könnte man prüfen, ob heute ein Kaffeetyp getrunken wurde,
    // der bisher noch nicht oder selten getrunken wurde
    final todayDrinks = provider.getTodayDrinks();
    return todayDrinks.isEmpty ? 0 : 1.0;
  }

  double _calculateMorningCoffeeProgress(CoffeeProvider provider) {
    // Hier prüfen, ob Kaffee vor 10 Uhr getrunken wurde
    final todayDrinks = provider.getTodayDrinks();
    final morningCoffee = todayDrinks.any((drink) => drink.timestamp.hour < 10);

    return morningCoffee ? 1.0 : 0.0;
  }

  double _calculateTimingProgress(CoffeeProvider provider) {
    // In einer echten App würde man überprüfen, ob die Abstände eingehalten wurden
    // Hier für Demo-Zwecke zufällig
    return 0.65;
  }

  Widget _buildDailyChallenge({
    required String title,
    required String description,
    required IconData icon,
    required double progressPercent,
    required String reward,
  }) {
    final isCompleted = progressPercent >= 1.0;
    Color progressColor;

    if (isCompleted) {
      progressColor = AppTheme.successColor;
    } else if (progressPercent > 0) {
      progressColor = AppTheme.primaryColor;
    } else {
      progressColor = Colors.grey[400]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isCompleted ? Icons.check : icon,
                      color: isCompleted
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                      size: 28,
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reward,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCompleted
                              ? AppTheme.successColor
                              : AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 12,
              percent: progressPercent,
              padding: EdgeInsets.zero,
              barRadius: const Radius.circular(6),
              backgroundColor: Colors.grey[200],
              progressColor: progressColor,
              animation: true,
              animationDuration: 1000,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(_Achievement achievement) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  achievement.icon,
                  size: 40,
                  color: achievement.isUnlocked
                      ? AppTheme.primaryColor
                      : Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: achievement.isUnlocked
                        ? AppTheme.textColor
                        : Colors.grey[400],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.isUnlocked
                  ? achievement.description
                  : 'Noch nicht freigeschaltet',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: achievement.isUnlocked
                        ? AppTheme.secondaryTextColor
                        : Colors.grey[400],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  final List<_Achievement> _achievements = [
    _Achievement(
      title: 'Kaffee-Enthusiast',
      description: '10 verschiedene Sorten probiert',
      icon: Icons.coffee,
      isUnlocked: true,
    ),
    _Achievement(
      title: 'Früh-Aufsteher',
      description: '5 Tage vor 7 Uhr Kaffee getrunken',
      icon: Icons.wb_sunny,
      isUnlocked: true,
    ),
    _Achievement(
      title: 'Balance-Meister',
      description: '7 Tage unter 300mg Koffein geblieben',
      icon: Icons.balance,
      isUnlocked: false,
    ),
    _Achievement(
      title: 'Experimentierfreudig',
      description: 'Alle Zubereitungsarten ausprobiert',
      icon: Icons.science,
      isUnlocked: false,
    ),
    _Achievement(
      title: 'Barista',
      description: '30 Tage die App benutzt',
      icon: Icons.local_cafe,
      isUnlocked: false,
    ),
    _Achievement(
      title: 'Perfektionist',
      description: '5 Herausforderungen in einer Woche abgeschlossen',
      icon: Icons.emoji_events,
      isUnlocked: false,
    ),
  ];
}

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}
