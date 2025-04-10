import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/coffee_provider.dart';
import '../providers/stamp_provider.dart';
import '../models/stamp_card.dart';
import '../theme/app_theme.dart';
import 'qr_scanner_screen.dart';
import 'reward_history_screen.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Kaffeefarben - weichere, pastellige Töne
  static const Color accentColor = Color(0xFF8D6E63); // Sanftes Braun als Hauptfarbe
  static const Color lightAccentColor = Color(0xFFBCAAA4); // Helles Braun
  static const Color darkAccentColor = Color(0xFF5D4037); // Dunkles Braun
  static const Color warningColor = Color(0xFFE6A278); // Warmes Orange als Warnfarbe
  static const Color successColor = Color(0xFF81C784); // Sanftes Grün für Erfolg

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Herausforderungen',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: darkAccentColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Verbessere deinen Kaffeekonsum und sammle Auszeichnungen',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  _buildStampCards(),
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
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: accentColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: accentColor,
        labelStyle: Theme.of(context).textTheme.labelLarge,
        unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'Tägliche Aufgaben'),
          Tab(text: 'Auszeichnungen'),
          Tab(text: 'Stempelkarten'),
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
                    accentColor.withOpacity(0.9),
                    darkAccentColor.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
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
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Erstelle deine eigene Kaffee-Challenge',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
      progressColor = successColor;
    } else if (progressPercent > 0) {
      progressColor = accentColor;
    } else {
      progressColor = Colors.grey[400]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
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
            progressColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                        ? successColor.withOpacity(0.15)
                        : accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isCompleted ? Icons.check : icon,
                      color: isCompleted
                          ? successColor
                          : accentColor,
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: darkAccentColor,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? successColor.withOpacity(0.15)
                        : accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reward,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isCompleted
                          ? successColor
                          : accentColor,
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
            achievement.isUnlocked
                ? accentColor.withOpacity(0.05)
                : Colors.grey[100]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                    ? accentColor.withOpacity(0.15)
                    : Colors.grey[200],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: achievement.isUnlocked
                        ? accentColor.withOpacity(0.2)
                        : Colors.grey[300]!,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  achievement.icon,
                  size: 40,
                  color: achievement.isUnlocked
                      ? accentColor
                      : Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: achievement.isUnlocked
                    ? darkAccentColor
                    : Colors.grey[400],
                fontWeight: FontWeight.bold,
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

  Widget _buildStampCards() {
    return Consumer<StampProvider>(
      builder: (context, stampProvider, _) {
        if (stampProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        final activeCards = stampProvider.stampCards.where((card) => !card.rewardClaimed).toList();
        
        if (activeCards.isEmpty) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (stampProvider.hasNewReward)
                _buildRewardBanner(),
              const SizedBox(height: 16),
              ...activeCards.map((card) => _buildStampCard(card)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: Image.asset(
              'assets/leo/leo_empty.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Noch keine Stempelkarten',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Scanne QR-Codes im Café und sammle Stempel!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const QRScannerScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            label: const Text(
              'QR-Code scannen',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          // Debug-Button zum Testen
          TextButton.icon(
            onPressed: () {
              _createTestStampCard();
            },
            icon: const Icon(
              Icons.bug_report,
              size: 18,
            ),
            label: const Text('Debug: Test-Stempelkarte erstellen'),
          ),
        ],
      ),
    );
  }

  // Debug-Methode zum Erstellen einer Test-Stempelkarte
  Future<void> _createTestStampCard() async {
    final stampProvider = Provider.of<StampProvider>(context, listen: false);
    try {
      // Reset für sauberen Test (optional)
      await stampProvider.resetStampCards();
      
      // Test-QR-Code scannen
      final result = await stampProvider.processQrCode('cafe_bla_test_qr');
      
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test-Stempelkarte erfolgreich erstellt'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Erstellen der Test-Stempelkarte'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildRewardBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Du hast einen Gratiskaffee!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gehe zu deinen Rewards, um ihn einzulösen.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RewardHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStampCard(StampCard card) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.coffee_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.cafeName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Letzter Besuch: ${_formatDate(card.lastScanned)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${card.currentStamps}/10',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStampGrid(card),
            if (card.rewardReady) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: successColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: successColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Belohnung verfügbar! Gehe zu deinen Rewards.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStampGrid(StampCard card) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        bool isStamped = index < card.currentStamps;
        
        return Container(
          decoration: BoxDecoration(
            color: isStamped 
                ? AppTheme.primaryColor.withOpacity(0.8)
                : Colors.grey[200],
            shape: BoxShape.circle,
            boxShadow: isStamped ? [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ] : null,
          ),
          child: isStamped 
              ? const Icon(
                  Icons.coffee,
                  color: Colors.white,
                )
              : null,
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
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
