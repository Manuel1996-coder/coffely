import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/coffee_provider.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, coffeeProvider, child) {
        if (coffeeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildActiveChallenge(context),
                  const SizedBox(height: 24),
                  _buildAvailableChallenges(context),
                  const SizedBox(height: 24),
                  _buildCompletedChallenges(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Deine Kaffee-Challenges 🏆',
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }

  Widget _buildActiveChallenge(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktive Challenge',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: CircularPercentIndicator(
                radius: 60,
                lineWidth: 10,
                percent: 0.7,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '7/10',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Tage',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                progressColor: Theme.of(context).colorScheme.primary,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '10 Tage ohne Kaffee',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Noch 3 Tage übrig',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableChallenges(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verfügbare Challenges',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        _buildChallengeCard(
          context,
          'Kaffee-Detox',
          '10 Tage ohne Kaffee',
          'Verzichte 10 Tage lang auf Kaffee und andere koffeinhaltige Getränke.',
          Icons.no_drinks,
        ),
        const SizedBox(height: 12),
        _buildChallengeCard(
          context,
          'Kaffee-Vielfalt',
          '5 verschiedene Getränke',
          'Probiere 5 verschiedene Kaffeegetränke in einer Woche.',
          Icons.local_cafe,
        ),
        const SizedBox(height: 12),
        _buildChallengeCard(
          context,
          'Koffein-Reduzierung',
          'Weniger Koffein',
          'Reduziere deine tägliche Koffeinaufnahme um 50% für eine Woche.',
          Icons.trending_down,
        ),
      ],
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    String title,
    String subtitle,
    String description,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: () {
            // TODO: Implement challenge start
          },
          child: const Text('Start'),
        ),
      ),
    );
  }

  Widget _buildCompletedChallenges(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Abgeschlossene Challenges',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        _buildCompletedChallengeCard(
          context,
          'Kaffee-Detox',
          '10 Tage ohne Kaffee',
          'Abgeschlossen am 15. März 2024',
          Icons.check_circle,
        ),
        const SizedBox(height: 12),
        _buildCompletedChallengeCard(
          context,
          'Kaffee-Vielfalt',
          '5 verschiedene Getränke',
          'Abgeschlossen am 10. März 2024',
          Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildCompletedChallengeCard(
    BuildContext context,
    String title,
    String subtitle,
    String date,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          date,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
