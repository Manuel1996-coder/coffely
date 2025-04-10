import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stamp_card.dart';

class StampProvider extends ChangeNotifier {
  List<StampCard> _stampCards = [];
  bool _isLoading = true;
  bool _hasNewReward = false;

  StampProvider() {
    _loadStampCards();
  }

  // Getter für die Stempelkarten
  List<StampCard> get stampCards => _stampCards;
  bool get isLoading => _isLoading;
  bool get hasNewReward => _hasNewReward;

  // Lade Stempelkarten aus dem lokalen Speicher
  Future<void> _loadStampCards() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      final String? stampCardsJson = prefs.getString('stamp_cards');
      
      debugPrint('Lade Stempelkarten: $stampCardsJson');
      
      if (stampCardsJson != null && stampCardsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(stampCardsJson) as List<dynamic>;
        _stampCards = decoded.map((item) => StampCard.fromJson(item as Map<String, dynamic>)).toList();
        debugPrint('${_stampCards.length} Stempelkarten geladen');
      } else {
        debugPrint('Keine gespeicherten Stempelkarten gefunden');
        _stampCards = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Fehler beim Laden der Stempelkarten: $e');
      // Bei Fehler leere Liste verwenden
      _stampCards = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  // Speichere Stempelkarten im lokalen Speicher
  Future<void> _saveStampCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_stampCards.map((card) => card.toJson()).toList());
      await prefs.setString('stamp_cards', encoded);
      debugPrint('Stempelkarten gespeichert: ${_stampCards.length} Karten');
      debugPrint('Gespeicherte Daten: $encoded');
    } catch (e) {
      debugPrint('Fehler beim Speichern der Stempelkarten: $e');
    }
  }

  // Debug-Methode zum Zurücksetzen der Stempelkarten
  Future<void> resetStampCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('stamp_cards');
      _stampCards = [];
      notifyListeners();
      debugPrint('Stempelkarten zurückgesetzt');
    } catch (e) {
      debugPrint('Fehler beim Zurücksetzen der Stempelkarten: $e');
    }
  }

  // Verarbeite gescannten QR-Code
  Future<StampCard?> processQrCode(String qrData) async {
    debugPrint('Verarbeite QR Code: $qrData');
    // Für MVP nur cafeId "cafe_bla" akzeptieren
    if (qrData != 'cafe_bla_test_qr') {
      debugPrint('Ungültiger QR-Code: $qrData');
      return null;
    }

    final String cafeId = 'cafe_bla';
    final String cafeName = 'Café Blá';
    
    // Suche nach existierender Stempelkarte
    int existingIndex = _stampCards.indexWhere((card) => card.cafeId == cafeId && !card.rewardReady && !card.rewardClaimed);
    debugPrint('Existierende aktive Karte gefunden: ${existingIndex != -1}');
    
    if (existingIndex != -1) {
      // Existierende aktive Karte gefunden
      StampCard existingCard = _stampCards[existingIndex];
      
      // Prüfe, ob Karte schon voll ist (sollte nicht vorkommen, aber zur Sicherheit)
      if (existingCard.currentStamps >= 10) {
        debugPrint('Karte bereits voll, erstelle neue Karte');
        return _createNewCard(cafeId, cafeName);
      }
      
      // Prüfe, ob Scan erlaubt ist
      if (!existingCard.canScan()) {
        debugPrint('Scan nicht erlaubt: Limit erreicht');
        throw Exception('Du hast bereits 2 Stempel in den letzten 2 Stunden gesammelt.');
      }
      
      // Füge Stempel hinzu
      final updatedCard = existingCard.addStamp();
      _stampCards[existingIndex] = updatedCard;
      debugPrint('Stempel hinzugefügt. Neue Anzahl: ${updatedCard.currentStamps}');
      
      // Prüfe, ob Reward neu erreicht wurde
      if (updatedCard.rewardReady && !existingCard.rewardReady) {
        _hasNewReward = true;
        debugPrint('Neuer Reward erreicht!');
        
        // Erstelle direkt eine neue Karte für weitere Stempel
        _createNewCard(cafeId, cafeName);
      }
      
      await _saveStampCards();
      notifyListeners();
      return updatedCard;
    } else {
      // Suche nach bereits voller Karte
      int fullCardIndex = _stampCards.indexWhere((card) => card.cafeId == cafeId && (card.rewardReady || card.rewardClaimed));
      
      if (fullCardIndex != -1) {
        debugPrint('Karte bereits voll oder eingelöst, erstelle neue Karte');
        return _createNewCard(cafeId, cafeName);
      } else {
        // Keine Karte gefunden, erstelle neue
        return _createNewCard(cafeId, cafeName);
      }
    }
  }
  
  // Hilfsmethode zum Erstellen einer neuen Karte
  Future<StampCard> _createNewCard(String cafeId, String cafeName) async {
    final newCard = StampCard(
      cafeId: cafeId,
      cafeName: cafeName,
      currentStamps: 1,
      lastScanned: DateTime.now(),
      stampHistory: [DateTime.now()],
    );
    
    _stampCards.add(newCard);
    debugPrint('Neue Karte erstellt mit 1 Stempel');
    await _saveStampCards();
    notifyListeners();
    return newCard;
  }

  // Hole eine bestimmte Stempelkarte anhand der ID
  StampCard? getStampCardById(String cafeId) {
    try {
      return _stampCards.firstWhere((card) => card.cafeId == cafeId);
    } catch (e) {
      return null;
    }
  }

  // Reward als eingelöst markieren
  Future<void> claimReward(String cafeId) async {
    int index = _stampCards.indexWhere((card) => card.cafeId == cafeId);
    
    if (index != -1) {
      StampCard card = _stampCards[index];
      if (card.rewardReady && !card.rewardClaimed) {
        _stampCards[index] = card.claimReward();
        _hasNewReward = false;
        await _saveStampCards();
        notifyListeners();
      }
    }
  }

  // Aktuelle Stempelkarte auf NULL setzen und Benachrichtigung entfernen
  void clearNewRewardFlag() {
    _hasNewReward = false;
    notifyListeners();
  }

  // Hole alle Karten mit verfügbaren Rewards
  List<StampCard> getCardsWithRewards() {
    return _stampCards.where((card) => card.rewardReady && !card.rewardClaimed).toList();
  }

  // Hole alle eingelösten Rewards
  List<StampCard> getClaimedRewards() {
    return _stampCards.where((card) => card.rewardClaimed).toList();
  }

  // Hole alle aktiven Stempelkarten (unvollständig)
  List<StampCard> getActiveCards() {
    return _stampCards.where((card) => !card.rewardReady && !card.rewardClaimed).toList();
  }
  
  // Debug-Info für den aktuellen Zustand aller Karten
  String getDebugInfo() {
    final active = getActiveCards();
    final withRewards = getCardsWithRewards();
    final claimed = getClaimedRewards();
    
    return 'Aktive Karten: ${active.length}, Volle Karten: ${withRewards.length}, Eingelöste: ${claimed.length}';
  }
} 