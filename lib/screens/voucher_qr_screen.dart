import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/stamp_provider.dart';
import '../models/stamp_card.dart';
import '../theme/app_theme.dart';

class VoucherQRScreen extends StatefulWidget {
  final StampCard stampCard;

  const VoucherQRScreen({
    super.key,
    required this.stampCard,
  });

  @override
  State<VoucherQRScreen> createState() => _VoucherQRScreenState();
}

class _VoucherQRScreenState extends State<VoucherQRScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  
  String get _qrData => 'COFFELY_REWARD_${widget.stampCard.cafeId}_${DateTime.now().millisecondsSinceEpoch}';
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    // Start animation after short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationController.forward();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _markAsRedeemed() {
    final stampProvider = Provider.of<StampProvider>(context, listen: false);
    stampProvider.claimReward(widget.stampCard.cafeId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gratiskaffee wurde eingelöst!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
    
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dein Gratiskaffee',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildQrCode(),
                    const SizedBox(height: 32),
                    Text(
                      'Zeige diesen QR-Code an der Kasse',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gültig bis: ${_formatDate(widget.stampCard.rewardExpiryDate)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildRewardDetails(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }
  
  Widget _buildQrCode() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: QrImageView(
                data: _qrData,
                version: QrVersions.auto,
                size: 250,
                backgroundColor: Colors.white,
                errorStateBuilder: (context, err) {
                  return const Center(
                    child: Text(
                      'Fehler beim Erstellen des QR-Codes',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                embeddedImage: const AssetImage('assets/logo/coffely_icon.png'),
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildRewardDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.coffee,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ein Gratiskaffee',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'bei ${widget.stampCard.cafeName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dieser Gutschein ist nur einmal einlösbar. Nach dem Einlösen wird er aus deiner Sammlung entfernt.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _markAsRedeemed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.successColor,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Als eingelöst markieren',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'Unbekannt';
    return '${date.day}.${date.month}.${date.year}';
  }
} 