import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';

class CaffeineExplainerPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final UserProfile userProfile;

  const CaffeineExplainerPage({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Dein persönliches Koffeinlimit',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Coffee bean illustration
            Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.coffee_outlined,
                      size: 100,
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                    Icon(
                      Icons.coffee,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Explainer text
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wusstest du, dass dein Körpergewicht beeinflusst, wie viel Koffein du sicher verträgst?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Die EFSA (Europäische Behörde für Lebensmittelsicherheit) empfiehlt maximal 3–5 mg Koffein pro kg Körpergewicht. Wir verwenden 3 mg als konservativen Richtwert.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Deine Formel',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${userProfile.weight?.toStringAsFixed(0) ?? '??'} kg',
                                    ),
                                    const TextSpan(
                                      text: ' × ',
                                    ),
                                    const TextSpan(
                                      text: '3 mg',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Examples
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beispiele',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildCoffeineExample(
                    context,
                    title: 'Espresso',
                    amount: '60-80 mg',
                    icon: Icons.coffee,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildCoffeineExample(
                    context,
                    title: 'Filterkaffee',
                    amount: '80-120 mg',
                    icon: Icons.coffee_maker,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildCoffeineExample(
                    context,
                    title: 'Cappuccino',
                    amount: '60-120 mg',
                    icon: Icons.coffee,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Zurück'),
                ),
                
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Berechne mein Limit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoffeineExample(
    BuildContext context, {
    required String title,
    required String amount,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 