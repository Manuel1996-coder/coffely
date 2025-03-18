import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coffee_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  _buildProfileInfo(context),
                  const SizedBox(height: 24),
                  _buildAchievements(context),
                  const SizedBox(height: 24),
                  _buildSettings(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dein Profil 👤',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        IconButton(
          onPressed: () {
            // TODO: Implement edit profile
          },
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              'Max Mustermann',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Kaffee-Liebhaber seit 2024',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Getränke',
                  '42',
                  Icons.local_cafe,
                ),
                _buildStatItem(
                  context,
                  'Challenges',
                  '3',
                  Icons.emoji_events,
                ),
                _buildStatItem(
                  context,
                  'Tage',
                  '30',
                  Icons.calendar_today,
                ),
              ],
            ),
          ],
        ),
      ),
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
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildAchievements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deine Erfolge 🏆',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildAchievementItem(
              context,
              'Erster Kaffee',
              Icons.local_cafe,
              true,
            ),
            _buildAchievementItem(
              context,
              'Kaffee-Detox',
              Icons.no_drinks,
              true,
            ),
            _buildAchievementItem(
              context,
              'Kaffee-Vielfalt',
              Icons.local_cafe,
              true,
            ),
            _buildAchievementItem(
              context,
              'Koffein-Reduzierung',
              Icons.trending_down,
              false,
            ),
            _buildAchievementItem(
              context,
              'Wochen-Challenge',
              Icons.emoji_events,
              false,
            ),
            _buildAchievementItem(
              context,
              'Monats-Challenge',
              Icons.emoji_events,
              false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementItem(
    BuildContext context,
    String title,
    IconData icon,
    bool unlocked,
  ) {
    return Card(
      color: unlocked
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: unlocked
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: unlocked ? null : Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Einstellungen ⚙️',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Benachrichtigungen'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notifications toggle
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: Implement dark mode toggle
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Sprache'),
                trailing: const Text('Deutsch'),
                onTap: () {
                  // TODO: Implement language selection
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Über die App'),
                onTap: () {
                  // TODO: Show about dialog
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
