import 'package:flutter/foundation.dart';

class StampCard {
  final String cafeId;
  final String cafeName;
  final int currentStamps;
  final DateTime lastScanned;
  final List<DateTime> stampHistory;
  final bool rewardReady;
  final bool rewardClaimed;
  final DateTime? rewardClaimedDate;
  final DateTime? rewardExpiryDate;

  StampCard({
    required this.cafeId,
    required this.cafeName,
    this.currentStamps = 0,
    required this.lastScanned,
    this.stampHistory = const [],
    this.rewardReady = false,
    this.rewardClaimed = false,
    this.rewardClaimedDate,
    this.rewardExpiryDate,
  });

  StampCard copyWith({
    String? cafeId,
    String? cafeName,
    int? currentStamps,
    DateTime? lastScanned,
    List<DateTime>? stampHistory,
    bool? rewardReady,
    bool? rewardClaimed,
    DateTime? rewardClaimedDate,
    DateTime? rewardExpiryDate,
  }) {
    return StampCard(
      cafeId: cafeId ?? this.cafeId,
      cafeName: cafeName ?? this.cafeName,
      currentStamps: currentStamps ?? this.currentStamps,
      lastScanned: lastScanned ?? this.lastScanned,
      stampHistory: stampHistory ?? this.stampHistory,
      rewardReady: rewardReady ?? this.rewardReady,
      rewardClaimed: rewardClaimed ?? this.rewardClaimed,
      rewardClaimedDate: rewardClaimedDate ?? this.rewardClaimedDate,
      rewardExpiryDate: rewardExpiryDate ?? this.rewardExpiryDate,
    );
  }

  // Methode zum Hinzufügen eines Stempels
  StampCard addStamp() {
    final now = DateTime.now();
    final newStampHistory = List<DateTime>.from(stampHistory)..add(now);
    final newStampCount = currentStamps + 1;
    
    // Prüfe, ob 10 Stempel erreicht wurden
    final newRewardReady = newStampCount >= 10;
    
    // Begrenze die Stempelanzahl auf 10
    final limitedStampCount = newStampCount > 10 ? 10 : newStampCount;
    
    return copyWith(
      currentStamps: limitedStampCount,
      lastScanned: now,
      stampHistory: newStampHistory,
      rewardReady: newRewardReady,
      // Setze Ablaufdatum für Reward, wenn er neu erreicht wurde
      rewardExpiryDate: newRewardReady && !rewardReady 
          ? DateTime.now().add(const Duration(days: 30))
          : rewardExpiryDate,
    );
  }

  // Methode zum Einlösen des Rewards
  StampCard claimReward() {
    if (!rewardReady || rewardClaimed) {
      return this;
    }
    
    return copyWith(
      rewardClaimed: true,
      rewardClaimedDate: DateTime.now(),
      // Setze Stempel zurück
      currentStamps: currentStamps - 10,
      rewardReady: false,
    );
  }

  // Prüfe, ob ein neuer Scan erlaubt ist (max. 2 pro 2 Stunden)
  bool canScan() {
    final now = DateTime.now();
    // Filtere Stempel der letzten 2 Stunden
    final recentStamps = stampHistory.where((stamp) {
      final difference = now.difference(stamp);
      return difference.inHours < 2;
    }).toList();
    
    // Erlaube maximal 2 Stempel alle 2 Stunden
    return recentStamps.length < 2; // Korrigiert von 100 auf 2
  }

  // Konvertiere zu Map für die Speicherung
  Map<String, dynamic> toJson() {
    return {
      'cafeId': cafeId,
      'cafeName': cafeName,
      'currentStamps': currentStamps,
      'lastScanned': lastScanned.toIso8601String(),
      'stampHistory': stampHistory.map((date) => date.toIso8601String()).toList(),
      'rewardReady': rewardReady,
      'rewardClaimed': rewardClaimed,
      'rewardClaimedDate': rewardClaimedDate?.toIso8601String(),
      'rewardExpiryDate': rewardExpiryDate?.toIso8601String(),
    };
  }

  // Erstelle aus Map
  factory StampCard.fromJson(Map<String, dynamic> json) {
    try {
      return StampCard(
        cafeId: json['cafeId'] as String,
        cafeName: json['cafeName'] as String,
        currentStamps: json['currentStamps'] as int,
        lastScanned: DateTime.parse(json['lastScanned'] as String),
        stampHistory: ((json['stampHistory'] as List<dynamic>?) ?? [])
            .map((date) => DateTime.parse(date as String))
            .toList(),
        rewardReady: json['rewardReady'] as bool? ?? false,
        rewardClaimed: json['rewardClaimed'] as bool? ?? false,
        rewardClaimedDate: json['rewardClaimedDate'] != null
            ? DateTime.parse(json['rewardClaimedDate'] as String)
            : null,
        rewardExpiryDate: json['rewardExpiryDate'] != null
            ? DateTime.parse(json['rewardExpiryDate'] as String)
            : null,
      );
    } catch (e) {
      // Bei Fehlern einen Debug-Eintrag und eine leere Standardkarte zurückgeben
      debugPrint('Fehler beim Parsen einer StampCard: $e');
      return StampCard(
        cafeId: 'error',
        cafeName: 'Fehlerhafte Karte',
        currentStamps: 0,
        lastScanned: DateTime.now(),
      );
    }
  }
} 