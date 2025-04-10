import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stamp_provider.dart';
import '../models/stamp_card.dart';
import '../theme/app_theme.dart';
import 'voucher_qr_screen.dart';

class RewardScreen extends StatefulWidget {
  final StampCard stampCard;

  const RewardScreen({
    super.key,
    required this.stampCard,
  });

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _redeemNow() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VoucherQRScreen(
          stampCard: widget.stampCard,
        ),
      ),
    );
  }

  void _redeemLater() {
    // Speichert den Gutschein für später
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dein Gratiskaffee wurde gespeichert.'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    
    // Zurück zum Hauptbildschirm navigieren (ggf. bis zur ersten Route)
    Navigator.of(context).popUntil((route) => route.isFirst);
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
              AppTheme.primaryColor.withOpacity(0.3),
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
                  _buildRewardIcon(),
                  const SizedBox(height: 40),
                  Text(
                    'Karte voll – hol dir deinen Gratiskaffee!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Du hast 10 Stempel bei ${widget.stampCard.cafeName} gesammelt.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildRedeemOptions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardIcon() {
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
                'assets/leo/leo_freecoffee.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRedeemOptions() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _redeemNow,
          icon: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size(double.infinity, 54),
          ),
          label: const Text(
            'Jetzt einlösen',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _redeemLater,
          icon: const Icon(
            Icons.bookmark_border,
            color: AppTheme.primaryColor,
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.primaryColor),
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size(double.infinity, 54),
          ),
          label: const Text(
            'Für später speichern',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
} 