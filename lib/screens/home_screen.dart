import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coffee_provider.dart';
import '../models/coffee_drink.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildTodaySection(context),
              const SizedBox(height: 24),
              _buildQuickAddSection(context),
              const SizedBox(height: 24),
              _buildRecentDrinksSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Willkommen zurück!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Wie geht es dir heute?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTodaySection(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, coffeeProvider, child) {
        final todayDrinks = coffeeProvider.getTodayDrinks();
        final totalCaffeine = todayDrinks.fold<double>(
          0,
          (sum, drink) => sum + drink.caffeineAmount,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heute',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      context,
                      'Getränke',
                      todayDrinks.length.toString(),
                      Icons.coffee,
                    ),
                    _buildStatItem(
                      context,
                      'Koffein',
                      '${totalCaffeine.toStringAsFixed(1)} mg',
                      Icons.battery_charging_full,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildQuickAddSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schnell hinzufügen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildQuickAddCard(
                context,
                'Espresso',
                Icons.coffee,
                CoffeeDrink.espresso,
              ),
              _buildQuickAddCard(
                context,
                'Cappuccino',
                Icons.coffee_maker,
                CoffeeDrink.cappuccino,
              ),
              _buildQuickAddCard(
                context,
                'Latte Macchiato',
                Icons.local_cafe,
                CoffeeDrink.latteMacchiato,
              ),
              _buildQuickAddCard(
                context,
                'Filterkaffee',
                Icons.coffee_outlined,
                CoffeeDrink.filterCoffee,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddCard(
    BuildContext context,
    String title,
    IconData icon,
    CoffeeDrink drink,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<CoffeeProvider>().addDrink(drink);
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDrinksSection(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, coffeeProvider, child) {
        final recentDrinks = coffeeProvider.getRecentDrinks();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kürzlich getrunken',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentDrinks.length,
              itemBuilder: (context, index) {
                final drink = recentDrinks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.coffee,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(drink.name),
                    subtitle: Text(
                      '${drink.caffeineAmount} mg Koffein',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: Text(
                      coffeeProvider.formatTime(drink.timestamp),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
