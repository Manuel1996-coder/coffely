import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stamp_provider.dart';
import '../models/stamp_card.dart';
import '../theme/app_theme.dart';
import 'voucher_qr_screen.dart';

class RewardHistoryScreen extends StatelessWidget {
  const RewardHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meine Rewards',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<StampProvider>(
        builder: (context, stampProvider, _) {
          if (stampProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            );
          }

          final activeRewards = stampProvider.getCardsWithRewards();
          final claimedRewards = stampProvider.getClaimedRewards();

          if (activeRewards.isEmpty && claimedRewards.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeRewards.isNotEmpty) ...[
                  Text(
                    'Verfügbare Rewards',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...activeRewards.map(
                    (card) => _buildRewardCard(
                      context, 
                      card, 
                      isActive: true,
                      onTap: () => _showReward(context, card),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (claimedRewards.isNotEmpty) ...[
                  Text(
                    'Eingelöste Rewards',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...claimedRewards.map(
                    (card) => _buildRewardCard(
                      context, 
                      card, 
                      isActive: false,
                      onTap: null,
                    ),
                  ),
                ],
                // Debug-Informationen
                if (false) ... [
                  const SizedBox(height: 24),
                  const Divider(),
                  Text(
                    'Debug-Info:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(stampProvider.getDebugInfo()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            'Noch keine Rewards',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Sammle Stempel und sichere dir deinen Gratiskaffee!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(
    BuildContext context, 
    StampCard card, 
    {required bool isActive, 
    VoidCallback? onTap}
  ) {
    final textColor = isActive ? AppTheme.textColor : AppTheme.secondaryTextColor;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isActive ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive 
              ? AppTheme.accentColor.withOpacity(0.3) 
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? Icons.coffee : Icons.coffee_outlined,
                  color: isActive ? AppTheme.primaryColor : Colors.grey,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gratiskaffee',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'bei ${card.cafeName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive
                          ? 'Gültig bis: ${_formatDate(card.rewardExpiryDate)}'
                          : 'Eingelöst am: ${_formatDate(card.rewardClaimedDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isActive ? AppTheme.accentColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReward(BuildContext context, StampCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VoucherQRScreen(
          stampCard: card,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unbekannt';
    return '${date.day}.${date.month}.${date.year}';
  }
} 