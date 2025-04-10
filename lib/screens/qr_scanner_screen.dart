import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/stamp_provider.dart';
import '../theme/app_theme.dart';
import 'stamp_success_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _initializeScannerController();
  }
  
  void _initializeScannerController() {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      
      // Clear any previous errors
      if (_hasError) {
        setState(() {
          _hasError = false;
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Kamerazugriff fehlgeschlagen: $e';
      });
      debugPrint('Fehler beim Initialisieren der Kamera: $e');
    }
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR-Code scannen',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller?.torchState ?? ValueNotifier(TorchState.off),
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on ? Icons.flashlight_on : Icons.flashlight_off,
                  color: AppTheme.primaryColor,
                );
              },
            ),
            onPressed: _controller != null ? () => _controller?.toggleTorch() : null,
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller?.cameraFacingState ?? ValueNotifier(CameraFacing.back),
              builder: (context, state, child) {
                return Icon(
                  state == CameraFacing.front ? Icons.camera_front : Icons.camera_rear,
                  color: AppTheme.primaryColor,
                );
              },
            ),
            onPressed: _controller != null ? () => _controller?.switchCamera() : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: _hasError 
                ? _buildErrorView() 
                : Stack(
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: _onDetect,
                        errorBuilder: (context, error, child) {
                          setState(() {
                            _hasError = true;
                            _errorMessage = 'Kamera konnte nicht initialisiert werden. Bitte prüfe die App-Berechtigungen.';
                          });
                          return _buildErrorView();
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          backgroundBlendMode: BlendMode.darken,
                        ),
                      ),
                      Center(
                        child: Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 3,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Scanne den QR-Code am Tresen',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Der QR-Code ist 2× alle 2 Stunden scanbar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Für Testzwecke: Simulierter Scan
                    _processQrCode('cafe_bla_test_qr');
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
                    'Test-QR scannen',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Kamerazugriff nicht möglich',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage.isEmpty
                  ? 'Bitte prüfe die App-Berechtigungen in den Einstellungen deines Geräts.'
                  : _errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeScannerController,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: const Text(
                'Erneut versuchen',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    if (capture.barcodes.isEmpty) return;
    
    final String? qrData = capture.barcodes.first.rawValue;
    if (qrData == null) return;
    
    // QR Code wurde erkannt, pausiere Scanner
    _controller?.stop();
    _processQrCode(qrData);
  }
  
  Future<void> _processQrCode(String qrData) async {
    setState(() {
      _isProcessing = true;
    });
    
    final stampProvider = Provider.of<StampProvider>(context, listen: false);
    
    try {
      final stampCard = await stampProvider.processQrCode(qrData);
      
      if (stampCard == null) {
        // QR-Code nicht erkannt
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR-Code nicht erkannt.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Erfolgreich gescannt, zeige Erfolgsseite
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => StampSuccessScreen(stampCard: stampCard),
            ),
          );
        }
      }
    } catch (e) {
      // Fehler beim Scannen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
      
      // Starte Scanner wieder, wenn wir nicht zur Erfolgsseite navigiert sind
      if (mounted) {
        _controller?.start();
      }
    }
  }
} 