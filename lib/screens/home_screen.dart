import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coffee_provider.dart';
import '../models/coffee_drink.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widgets/leo_mascot.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Extension für einfachen Zugriff auf lokalisierte Strings
extension LocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

// Hilfsfunktion für lokalisierte Texte mit Platzhaltern
String _formatLocalizedText(String text, Map<String, String> replacements) {
  String result = text;
  replacements.forEach((key, value) {
    result = result.replaceAll('{$key}', value);
  });
  return result;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LeoState _leoState = LeoState.happy;
  bool _showTooltip = false;
  String _leoMessage = '';
  bool _challengeCompleted = false; // Beispiel-Flag für Challenge-Abschluss

  @override
  void initState() {
    super.initState();
    // Initialisiere die Lokalisierungsdaten basierend auf der aktuellen Sprache
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    initializeDateFormatting(locale.languageCode, null);
    
    // Zeige Leo mit Nachricht nach einer kurzen Verzögerung
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showTooltip = true;
        _leoMessage = LeoManager.getRandomMessage(LeoState.happy);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Context an LeoManager übergeben
    LeoManager.setContext(context);
    
    // Update Leo's Zustand außerhalb des Build-Prozesses
    final coffeeProvider = Provider.of<CoffeeProvider>(context);
    if (!coffeeProvider.isLoading) {
      final todayDrinks = coffeeProvider.getTodayDrinks().length;
      final currentCaffeine = coffeeProvider.predictCaffeineLevel();
      final caffeineLimit = coffeeProvider.caffeineLimit;
      
      final newLeoState = LeoManager.getLeoState(
        todayDrinks,
        currentCaffeine, 
        caffeineLimit,
        _challengeCompleted
      );
      
      if (newLeoState != _leoState) {
        setState(() {
          _leoState = newLeoState;
        });
      }
    }
  }

  void _handleLeoTap() {
    setState(() {
      _showTooltip = !_showTooltip;
      if (_showTooltip) {
        _leoMessage = LeoManager.getRandomMessage(_leoState);
      }
    });
  }

  // Optional: Funktion, um Leo in den Add-Coffee-Modus zu versetzen
  void _setLeoToAddCoffee() {
    setState(() {
      _leoState = LeoState.addCoffee;
      _showTooltip = true;
      _leoMessage = LeoManager.getRandomMessage(LeoState.addCoffee);
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

            // Leo-Zustand wird nicht mehr hier aktualisiert, sondern in didChangeDependencies
            // _updateLeoState(coffeeProvider);

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
                            const Icon(
                              Icons.add_circle,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.quickAdd,
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
                // Position für Leo
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_showTooltip)
                        LeoTooltip(
                          message: _leoMessage,
                          isVisible: _showTooltip,
                          onDismiss: () => setState(() => _showTooltip = false),
                        ),
                      const SizedBox(height: 8),
                      LeoMascot(
                        state: _leoState,
                        size: 80,
                        onTap: _handleLeoTap,
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
          _setLeoToAddCoffee(); // Ändere Leo zum AddCoffee-Modus
          _showAddCustomDrinkModal(context);
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(context.l10n.addDrink, style: const TextStyle(color: Colors.white)),
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
      greeting = context.l10n.goodMorning;
    } else if (now.hour < 18) {
      greeting = context.l10n.goodDay;
    } else {
      greeting = context.l10n.goodEvening;
    }
    
    // Ermittle den Wochentag
    final dayOfWeek = DateFormat('EEEE', Localizations.localeOf(context).languageCode).format(now);
    
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
                      child: const Icon(
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
                          "Heute ist $dayOfWeek",
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
                      const Icon(
                        Icons.coffee,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.timeForCoffee,
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

    // Individuelles Koffein-Limit aus dem CoffeeProvider
    final maxCaffeine = coffeeProvider.caffeineLimit;
    final percentage = (totalCaffeine / maxCaffeine).clamp(0.0, 1.0);
    
    // Status Text basierend auf Koffeinkonsum
    String statusText;
    Color statusColor;
    IconData statusIcon;
    
    if (percentage < 0.25) {
      statusText = context.l10n.lowCaffeineConsumption;
      statusColor = Colors.green[600]!;
      statusIcon = Icons.sentiment_satisfied_alt;
    } else if (percentage < 0.5) {
      statusText = context.l10n.optimalCaffeineConsumption;
      statusColor = Colors.blue[600]!;
      statusIcon = Icons.sentiment_very_satisfied;
    } else if (percentage < 0.75) {
      statusText = context.l10n.elevatedCaffeineConsumption;
      statusColor = Colors.orange[600]!;
      statusIcon = Icons.sentiment_neutral;
    } else {
      statusText = context.l10n.highCaffeineConsumption;
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
                  context.l10n.today,
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
                        context.l10n.drinksToday,
                        Icons.coffee,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEnhancedStatItem(
                        context,
                        '${totalCaffeine.toStringAsFixed(0)} mg',
                        context.l10n.caffeineToday,
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
                              "${(percentage * 100).toStringAsFixed(0)}% des täglichen Limits",
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
                            '${maxCaffeine.toInt()} mg',
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
                              context.l10n.coffeeBreakTip,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Nachricht anzeigen, wenn noch kein Kaffee getrunken wurde
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
                            Icons.coffee_outlined,
                            color: Colors.blue[400],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.noCaffeineYet,
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
              context.l10n.recentlyConsumed,
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
                  icon: const Icon(
                    Icons.history, 
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  label: Text(
                    context.l10n.showAll,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
          ],
        ),
        
        if (recentDrinks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.coffee_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.noCoffeeConsumed,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.yourCoffeesShownHere,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: recentDrinks.map((drink) {
              Color accentColor;
              if (drink.caffeineAmount <= 30) {
                accentColor = Colors.green;
              } else if (drink.caffeineAmount <= 60) {
                accentColor = Colors.blue;
              } else {
                accentColor = Colors.orange;
              }
              
              return Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Details anzeigen
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.coffee,
                                color: accentColor,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
            context.l10n.addCustomDrink,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
            decoration: InputDecoration(
              labelText: context.l10n.drinkName,
              hintText: context.l10n.drinkNameHint,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Koffeingehalt: ${caffeineAmount.toInt()} mg",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Slider(
            value: caffeineAmount,
            min: 20,
            max: 400,
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
              child: Text(context.l10n.add),
            ),
          ),
        ],
      ),
    );
  }
}
