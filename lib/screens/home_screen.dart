import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coffee_provider.dart';
import '../models/coffee_drink.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widgets/coffee_mascot.dart';
import '../widgets/mascot_tooltip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MascotState _mascotState = MascotState.greeting;
  bool _showTooltip = false;
  String _mascotMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialisiere die Lokalisierungsdaten für Deutsch
    initializeDateFormatting('de_DE', null);
    
    // Zeige das Mascot mit Nachricht nach einer kurzen Verzögerung
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showTooltip = true;
        _mascotMessage =
            MascotManager.getMessage(MascotState.greeting, context);
      });
    });
  }

  void _updateMascotState(CoffeeProvider provider) {
    final currentCaffeine = provider.predictCaffeineLevel();

    // Kein Kaffee heute = müde
    if (provider.getTodayDrinks().isEmpty) {
      _mascotState = MascotState.sleepy;
    }
    // Zu viel Kaffee = übermunter
    else if (currentCaffeine > 300) {
      _mascotState = MascotState.excited;
    }
    // Normaler Kaffeekonsum = glücklich
    else if (currentCaffeine > 0) {
      _mascotState = MascotState.happy;
    }
    // Standard = Begrüßung
    else {
      _mascotState = MascotState.greeting;
    }
  }

  void _handleMascotTap() {
    setState(() {
      _showTooltip = !_showTooltip;
      if (_showTooltip) {
        _mascotMessage = MascotManager.getMessage(_mascotState, context);
      }
    });
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

            // Aktualisiere den Mascot-Zustand basierend auf den Daten
            _updateMascotState(coffeeProvider);

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: _buildHeader(context),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: _buildTodaySection(context, coffeeProvider),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Schnell hinzufügen',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildQuickAddSection(context, coffeeProvider),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                      sliver: SliverToBoxAdapter(
                        child:
                            _buildRecentDrinksSection(context, coffeeProvider),
                      ),
                    ),
                  ],
                ),
                // Position für das Mascot
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_showTooltip)
                        MascotTooltip(
                          message: _mascotMessage,
                          isVisible: _showTooltip,
                          onDismiss: () => setState(() => _showTooltip = false),
                        ),
                      const SizedBox(height: 8),
                      CoffeeMascot(
                        state: _mascotState,
                        size: 80,
                        animationPath: MascotManager.getAnimationForState(_mascotState),
                        onTap: _handleMascotTap,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddCustomDrinkModal(context);
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Getränk hinzufügen', style: TextStyle(color: Colors.white)),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    String greeting;

    if (now.hour < 12) {
      greeting = 'Guten Morgen';
    } else if (now.hour < 18) {
      greeting = 'Guten Tag';
    } else {
      greeting = 'Guten Abend';
    }
    
    // Ermittle den Wochentag
    final dayOfWeek = DateFormat('EEEE', 'de_DE').format(now);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.wb_sunny,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          'Heute ist $dayOfWeek',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.coffee,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Zeit für Kaffee?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Hier später zum Profil navigieren
                },
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.person_outline,
                    size: 30,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection(
      BuildContext context, CoffeeProvider coffeeProvider) {
    final todayDrinks = coffeeProvider.getTodayDrinks();
    final totalCaffeine = todayDrinks.fold<double>(
      0,
      (sum, drink) => sum + drink.caffeineAmount,
    );

    // Max Koffein für einen durchschnittlichen Erwachsenen
    const maxCaffeine = 400.0;
    final percentage = (totalCaffeine / maxCaffeine).clamp(0.0, 1.0);
    
    // Status Text basierend auf Koffeinkonsum
    String statusText;
    Color statusColor;
    IconData statusIcon;
    
    if (percentage < 0.25) {
      statusText = 'Niedriger Koffeinkonsum';
      statusColor = Colors.green[600]!;
      statusIcon = Icons.sentiment_satisfied_alt;
    } else if (percentage < 0.5) {
      statusText = 'Optimaler Koffeinkonsum';
      statusColor = Colors.blue[600]!;
      statusIcon = Icons.sentiment_very_satisfied;
    } else if (percentage < 0.75) {
      statusText = 'Erhöhter Koffeinkonsum';
      statusColor = Colors.orange[600]!;
      statusIcon = Icons.sentiment_neutral;
    } else {
      statusText = 'Hoher Koffeinkonsum';
      statusColor = Colors.red[600]!;
      statusIcon = percentage >= 1.0 ? Icons.sentiment_very_dissatisfied : Icons.sentiment_dissatisfied;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header der Karte
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Heute',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    DateFormat('dd.MM.yyyy').format(DateTime.now()),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Hauptinhalt der Karte
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistik-Boxen
                Row(
                  children: [
                    Expanded(
                      child: _buildEnhancedStatItem(
                        context,
                        '${todayDrinks.length}',
                        'Getränke heute',
                        Icons.coffee,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEnhancedStatItem(
                        context,
                        '${totalCaffeine.toStringAsFixed(0)} mg',
                        'Koffein heute',
                        Icons.bolt_outlined,
                        statusColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Status-Anzeige
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusText,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(percentage * 100).toStringAsFixed(0)}% des täglichen Limits',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Fortschrittsbalken
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 16,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '400 mg',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: percentage > 0.7 ? Colors.white : Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Kaffeekonsum-Tipps
                if (percentage > 0.75)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red[100]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.red[400],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Vielleicht eine Pause vom Kaffee einlegen?',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                if (todayDrinks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue[100]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[400],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Noch keinen Kaffee heute? Zeit für eine Tasse!',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildEnhancedStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddSection(
      BuildContext context, CoffeeProvider coffeeProvider) {
    final drinkOptions = [
      _QuickAddOption(
        drink: CoffeeDrink.espresso,
        icon: Icons.coffee,
        fallbackIcon: Icons.coffee,
      ),
      _QuickAddOption(
        drink: CoffeeDrink.cappuccino,
        icon: Icons.coffee_maker,
        fallbackIcon: Icons.coffee_maker,
      ),
      _QuickAddOption(
        drink: CoffeeDrink.latteMacchiato,
        icon: Icons.local_cafe,
        fallbackIcon: Icons.local_cafe,
      ),
      _QuickAddOption(
        drink: CoffeeDrink.filterCoffee,
        icon: Icons.coffee_outlined,
        fallbackIcon: Icons.coffee_outlined,
      ),
      _QuickAddOption(
        drink: CoffeeDrink.instantCoffee,
        icon: Icons.coffee,
        fallbackIcon: Icons.coffee,
      ),
      _QuickAddOption(
        drink: CoffeeDrink.cremaCoffee,
        icon: Icons.coffee_outlined,
        fallbackIcon: Icons.coffee_outlined,
      ),
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        scrollDirection: Axis.horizontal,
        itemCount: drinkOptions.length,
        itemBuilder: (context, index) {
          final option = drinkOptions[index];
          return _buildQuickAddCard(
            context,
            coffeeProvider,
            option,
          );
        },
      ),
    );
  }

  Widget _buildQuickAddCard(
    BuildContext context,
    CoffeeProvider coffeeProvider,
    _QuickAddOption option,
  ) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            coffeeProvider.addDrink(option.drink.copyWith(
              timestamp: DateTime.now(),
            ));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${option.drink.name} hinzugefügt'),
                backgroundColor: AppTheme.primaryColor,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _buildDrinkIcon(option),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  option.drink.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${option.drink.caffeineAmount.toInt()} mg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrinkIcon(_QuickAddOption option) {
    return Icon(
      option.icon,
      size: 32,
      color: AppTheme.primaryColor,
    );
  }

  Widget _buildRecentDrinksSection(
      BuildContext context, CoffeeProvider coffeeProvider) {
    final recentDrinks = coffeeProvider.getRecentDrinks();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kürzlich getrunken',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (recentDrinks.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    // Später: Alle Getränke anzeigen
                  },
                  icon: Icon(
                    Icons.history, 
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  label: Text(
                    'Alle anzeigen',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentDrinks.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.coffee_outlined,
                    size: 48,
                    color: AppTheme.secondaryTextColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kein Kaffee getrunken',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deine Kaffees werden hier angezeigt',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.tertiaryTextColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: recentDrinks.take(3).map((drink) {
              // Bestimme Farbe basierend auf Koffeinmenge
              Color accentColor;
              if (drink.caffeineAmount <= 30) {
                accentColor = Colors.green[600]!;
              } else if (drink.caffeineAmount <= 60) {
                accentColor = Colors.blue[600]!;
              } else {
                accentColor = Colors.orange[600]!;
              }
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Später: Details anzeigen oder Aktionen ermöglichen
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.coffee,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  drink.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${drink.caffeineAmount.toInt()} mg',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (drink.note != null) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          drink.note!,
                                          style: Theme.of(context).textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  coffeeProvider.formatTime(drink.timestamp),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showAddCustomDrinkModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomDrinkBottomSheet(),
    );
  }
}

class _QuickAddOption {
  final CoffeeDrink drink;
  final IconData icon;
  final IconData fallbackIcon;

  _QuickAddOption({
    required this.drink,
    required this.icon,
    required this.fallbackIcon,
  });
}

class _CustomDrinkBottomSheet extends StatefulWidget {
  @override
  _CustomDrinkBottomSheetState createState() => _CustomDrinkBottomSheetState();
}

class _CustomDrinkBottomSheetState extends State<_CustomDrinkBottomSheet> {
  String name = '';
  double caffeineAmount = 80;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Eigenes Getränk hinzufügen',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Name des Getränks',
              hintText: 'z.B. Doppelter Espresso',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Koffeingehalt: ${caffeineAmount.toInt()} mg',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Slider(
            value: caffeineAmount,
            min: 10,
            max: 200,
            divisions: 19,
            label: '${caffeineAmount.toInt()} mg',
            onChanged: (value) {
              setState(() {
                caffeineAmount = value;
              });
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: name.trim().isEmpty
                  ? null
                  : () {
                      final provider =
                          Provider.of<CoffeeProvider>(context, listen: false);
                      final newDrink = CoffeeDrink(
                        name: name,
                        caffeineAmount: caffeineAmount,
                        timestamp: DateTime.now(),
                      );
                      provider.addDrink(newDrink);
                      Navigator.pop(context);
                    },
              child: const Text('Hinzufügen'),
            ),
          ),
        ],
      ),
    );
  }
}
