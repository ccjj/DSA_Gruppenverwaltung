import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Ein Widget, das einen Button zur Steuerung der Spracherkennung bereitstellt.
/// Beim Drücken des Buttons wird die Spracherkennung gestartet oder gestoppt,
/// und die erkannten Wörter werden in einem [TextEditingController] aktualisiert.
/// Während der Verarbeitung wird eine Ladeanimation angezeigt.
class SpeechButtonWidget extends StatefulWidget {
  /// Der [TextEditingController], der die erkannten Wörter speichert.
  final TextEditingController textController;

  /// Optional: Die Locale ID für die Spracherkennung (z.B. 'de_DE').
  final String localeId;

  final Function(String)? callback;

  /// Konstruktor für [SpeechButtonWidget].
  const SpeechButtonWidget({
    Key? key,
    required this.textController,
    this.localeId = 'de_DE',
    this.callback
  }) : super(key: key);

  @override
  _SpeechButtonWidgetState createState() => _SpeechButtonWidgetState();
}

class _SpeechButtonWidgetState extends State<SpeechButtonWidget> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _manualStop = false; // Flag zur Verfolgung manueller Stops

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  /// Initialisiert die Spracherkennung.
  Future<bool> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );
    return available;
  }

  /// Startet die Spracherkennung.
  Future<void> _startListening() async {
    bool available = await _initSpeech();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spracherkennung nicht verfügbar')),
      );
      return;
    }

    print("_startListening");

    setState(() {
      _isListening = true;
      _manualStop = false; // Reset des manuellen Stop Flags
    });

    _speech.listen(
      onResult: _onResult,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 2),
      localeId: widget.localeId,
      cancelOnError: true,
      partialResults: true,
    );
  }

  /// Stoppt die Spracherkennung.
  void _stopListening() {
    print("_stopListening");
    _speech.stop();
    setState(() {
      _isListening = false;
      _manualStop = true; // Markiert, dass das Stoppen manuell erfolgt ist
    });
  }

  /// Behandelt die Ergebnisse der Spracherkennung.
  void _onResult(SpeechRecognitionResult result) {
    // Überprüft, ob das Stoppen manuell erfolgt ist
    if (!_manualStop) {
      widget.textController.text = result.recognizedWords;
      print("_onResult");
      setState(() {
      // Verarbeitung abgeschlossen
      });

    } else {
      // Wenn das Stoppen manuell war, keine weitere Verarbeitung
      print("_onResult ignoriert aufgrund manuellen Stopps");
    }
  }

  /// Behandelt Statusänderungen der Spracherkennung.
  void _onStatus(String status) {
    print("_onStatus: $status");

    if (mounted && (status == 'done' || status == 'notListening')) {
      setState(() {
        _isListening = false;
      });
      if(status == 'notListening' && widget.callback != null){
        print("call callback");
        widget.callback!(widget.textController.text);
      }
    }
  }

  /// Behandelt Fehler der Spracherkennung.
  void _onError(dynamic error) {
    setState(() {
      _isListening = false;
      _manualStop = false; // Reset des manuellen Stop Flags bei Fehler
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fehler: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isListening ? _stopListening : _startListening,
      icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
      // Entfernen des 'style' Parameters, da IconButton keinen 'styleFrom' unterstützt
      // Stattdessen kannst du andere Anpassungen vornehmen, falls nötig
    );
  }
}
