import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stamp_provider.dart';
import '../models/stamp_card.dart';
import '../theme/app_theme.dart';
import 'reward_screen.dart';

class StampSuccessScreen extends StatefulWidget {
  final StampCard stampCard;

  const StampSuccessScreen({
    super.key,
    required this.stampCard,
  });

  @override
  State<StampSuccessScreen> createState() => _StampSuccessScreenState();
}

class _StampSuccessScreenState extends State<StampSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Starte Animation nach kurzem Delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });

    // Prüfe, ob Reward erreicht wurde und navigiere zur Reward-Seite
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkReward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkReward() {
    final stampProvider = Provider.of<StampProvider>(context, listen: false);
    
    if (widget.stampCard.rewardReady && stampProvider.hasNewReward) {
      // Navigation nach Verzögerung zur Belohnungsseite
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RewardScreen(
                stampCard: widget.stampCard,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSuccessIcon(),
                  const SizedBox(height: 40),
                  Text(
                    'Stempel erfolgreich gesammelt!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'bei ${widget.stampCard.cafeName}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildStampProgress(),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Zurück zur Übersicht',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: SizedBox(
              height: 200,
              width: 200,
              child: Image.asset(
                'assets/leo/leo_addcoffee.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStampProgress() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stempelkarte',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.stampCard.currentStamps} / 10',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStampGrid(),
        ],
      ),
    );
  }

  Widget _buildStampGrid() {
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
        bool isStamped = index < widget.stampCard.currentStamps;
        bool isNew = index == widget.stampCard.currentStamps - 1;
        
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            double scale = isNew ? (_scaleAnimation.value * 0.3) + 0.7 : 1.0;
            
            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  color: isStamped 
                      ? AppTheme.primaryColor.withOpacity(isNew ? 0.9 : 0.7)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                  boxShadow: isStamped ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 5,
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
              ),
            );
          },
        );
      },
    );
  }
} 