import 'package:audioplayers/audioplayers.dart';

class AmbientSound {
  final String id;
  final String name;
  final String filename;
  final String icon;
  final String description;

  const AmbientSound({
    required this.id,
    required this.name,
    required this.filename,
    required this.icon,
    required this.description,
  });
}

class AudioService {
  static final AudioService instance = AudioService._internal();

  AudioPlayer? _ambientPlayer;
  AudioPlayer? _sfxPlayer;

  bool isSoundEnabled = true;
  double ambientVolume = 0.65;
  AmbientSound? currentSound;
  bool isPlayingAmbient = false;

  final List<AmbientSound> availableSounds = const [
    AmbientSound(
      id: 'rain',
      name: 'Rain Shower',
      filename: 'rain.wav',
      icon: 'drop_fill',
      description: 'Gentle raindrops & soothing distant ambient rumble',
    ),
    AmbientSound(
      id: 'forest',
      name: 'Forest Sanctuary',
      filename: 'forest.wav',
      icon: 'leaf_arrow_circlepath',
      description: 'Pine breeze rustle and harmonic bird song',
    ),
    AmbientSound(
      id: 'ocean',
      name: 'Ocean Swell',
      filename: 'ocean_waves.wav',
      icon: 'wind',
      description: 'Rhythmic rolling waves for deep continuous focus',
    ),
    AmbientSound(
      id: 'binaural',
      name: 'Alpha Flow 10Hz',
      filename: 'binaural_alpha.wav',
      icon: 'bolt_fill',
      description: 'Binaural beats engineered for peak concentration',
    ),
    AmbientSound(
      id: 'white_noise',
      name: 'Cosmic Noise',
      filename: 'white_noise.wav',
      icon: 'moon_stars_fill',
      description: 'Warm brown/pink noise masking external noise',
    ),
  ];

  AudioService._internal() {
    _ambientPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _ambientPlayer?.setReleaseMode(ReleaseMode.loop);
    _ambientPlayer?.setVolume(ambientVolume);
    _sfxPlayer?.setReleaseMode(ReleaseMode.release);
  }

  Future<void> playAmbient(AmbientSound sound) async {
    if (!isSoundEnabled) return;
    try {
      currentSound = sound;
      await _ambientPlayer?.stop();
      await _ambientPlayer?.setSource(AssetSource('sounds/${sound.filename}'));
      await _ambientPlayer?.setVolume(ambientVolume);
      await _ambientPlayer?.resume();
      isPlayingAmbient = true;
    } catch (_) {}
  }

  Future<void> stopAmbient() async {
    try {
      await _ambientPlayer?.stop();
      isPlayingAmbient = false;
    } catch (_) {}
  }

  Future<void> toggleAmbient(AmbientSound? sound) async {
    if (isPlayingAmbient) {
      await stopAmbient();
    } else {
      final toPlay = sound ?? currentSound ?? availableSounds.first;
      await playAmbient(toPlay);
    }
  }

  Future<void> setVolume(double volume) async {
    ambientVolume = volume.clamp(0.0, 1.0);
    if (_ambientPlayer != null) {
      await _ambientPlayer?.setVolume(ambientVolume);
    }
  }

  Future<void> playZenBell() async {
    if (!isSoundEnabled) return;
    try {
      await _sfxPlayer?.stop();
      await _sfxPlayer?.play(AssetSource('sounds/zen_bell.wav'));
    } catch (_) {}
  }

  Future<void> playCompletionChime() async {
    if (!isSoundEnabled) return;
    try {
      await _sfxPlayer?.stop();
      await _sfxPlayer?.play(AssetSource('sounds/completion_chime.wav'));
    } catch (_) {}
  }

  Future<void> playClickTick() async {
    if (!isSoundEnabled) return;
    try {
      await _sfxPlayer?.stop();
      await _sfxPlayer?.play(AssetSource('sounds/click_tick.wav'));
    } catch (_) {}
  }

  void dispose() {
    _ambientPlayer?.dispose();
    _sfxPlayer?.dispose();
  }
}
