import 'dart:async';

enum VoiceIntent {
  none,
  focus,
  rest,
  breakTime,
  leaving,
  arriving;

  String get label {
    switch (this) {
      case VoiceIntent.none:
        return 'No Voice Intent';
      case VoiceIntent.focus:
        return 'Focus Mode';
      case VoiceIntent.rest:
        return 'Rest Mode';
      case VoiceIntent.breakTime:
        return 'Take a Break';
      case VoiceIntent.leaving:
        return 'I am Leaving';
      case VoiceIntent.arriving:
        return 'I am Back';
    }
  }
}

class VoiceIntentSnapshot {
  final VoiceIntent intent;
  final String rawPhrase;
  final double confidence;
  final DateTime timestamp;
  final bool isLocalModel;

  const VoiceIntentSnapshot({
    required this.intent,
    required this.rawPhrase,
    required this.confidence,
    required this.timestamp,
    this.isLocalModel = true,
  });

  factory VoiceIntentSnapshot.idle() {
    return VoiceIntentSnapshot(
      intent: VoiceIntent.none,
      rawPhrase: '',
      confidence: 0.0,
      timestamp: DateTime.now(),
      isLocalModel: true,
    );
  }
}

abstract class VoiceIntentProvider {
  Stream<VoiceIntentSnapshot> get intentStream;
  VoiceIntentSnapshot get currentSnapshot;
  bool get isListening;
  Future<void> startListening();
  Future<void> stopListening();
  void triggerIntent(VoiceIntent intent, [String? phrase]);
  void dispose();
}

/// Voice integration boundary. No microphone recognizer is bundled yet, so it
/// remains inactive in production. Tests and demo controls can inject intents.
class RealVoiceIntentProvider implements VoiceIntentProvider {
  final StreamController<VoiceIntentSnapshot> _controller =
      StreamController<VoiceIntentSnapshot>.broadcast();

  VoiceIntentSnapshot _current = VoiceIntentSnapshot.idle();
  bool _isListening = false;
  Timer? _clearTimer;

  @override
  Stream<VoiceIntentSnapshot> get intentStream => _controller.stream;

  @override
  VoiceIntentSnapshot get currentSnapshot => _current;

  @override
  bool get isListening => _isListening;

  @override
  Future<void> startListening() async {
    // No recognizer is wired yet; never claim that microphone capture is active
    // and never request microphone permission as a side effect.
    _isListening = false;
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    _clearTimer?.cancel();
  }

  @override
  void triggerIntent(VoiceIntent intent, [String? phrase]) {
    _current = VoiceIntentSnapshot(
      intent: intent,
      rawPhrase: phrase ?? intent.label,
      confidence: 0.95,
      timestamp: DateTime.now(),
      isLocalModel: true,
    );
    _controller.add(_current);
    _clearTimer?.cancel();
    _clearTimer = Timer(const Duration(seconds: 15), () {
      _current = VoiceIntentSnapshot.idle();
      _controller.add(_current);
    });
  }

  @override
  void dispose() {
    _isListening = false;
    _clearTimer?.cancel();
    _controller.close();
  }
}
