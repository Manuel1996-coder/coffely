import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coffee_provider.dart';
import '../models/coffee_drink.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
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
                        padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
                        child: Text(
                          'Schnell hinzufügen',
                          style: Theme.of(context).textTheme.headlineMedium,
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
                  bottom: 100,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_showTooltip)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: MascotTooltip(
                            message: _mascotMessage,
                            isVisible: _showTooltip,
                            onDismiss: () {
                              setState(() {
                                _showTooltip = false;
                              });
                            },
                          ),
                        ),
                      BouncingMascot(
                        child: CoffeeMascot(
                          state: _mascotState,
                          size: 80,
                          onTap: _handleMascotTap,
                          animationPath:
                              MascotManager.getAnimationForState(_mascotState),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCustomDrinkModal(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Zeit für Kaffee?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            shape: BoxShape.circle,
            boxShadow: AppTheme.cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Hier später zum Profil navigieren
              },
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  Icons.person_outline,
                  size: 26,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
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

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Heute',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  DateFormat('dd.MM.yyyy').format(DateTime.now()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  context,
                  '${todayDrinks.length}',
                  'Getränke',
                  Icons.coffee,
                ),
                _buildStatItem(
                  context,
                  '${totalCaffeine.toStringAsFixed(0)} mg',
                  'Koffein',
                  Icons.bolt_outlined,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                    _getCaffeineColor(percentage)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0 mg',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '400 mg',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
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
      width: 140,
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
                  ),
                  child: Center(
                    child: _buildDrinkIcon(option),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  option.drink.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${option.drink.caffeineAmount.toInt()} mg',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
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
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (recentDrinks.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  // Später: Alle Getränke anzeigen
                },
                icon: const Icon(Icons.history, size: 16),
                label: const Text('Alle anzeigen'),
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
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.coffee,
                                color: AppTheme.primaryColor,
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${drink.caffeineAmount} mg Koffein',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                coffeeProvider.formatTime(drink.timestamp),
                                style: Theme.of(context).textTheme.bodySmall,
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
