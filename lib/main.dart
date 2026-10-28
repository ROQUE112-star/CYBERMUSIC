import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui' show ImageFilter, PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_lib;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await Window.initialize();
  await Window.setEffect(effect: WindowEffect.transparent);

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(260, 260),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'CYBERMUSIC',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    ChangeNotifierProvider(
      create: (_) => LibreSYProvider(),
      child: const LibreSYApp(),
    ),
  );
}

// ==========================================
// SPICETIFY THEMES & ESTILOS VISUALES DINÁMICOS
// Glassmorphism, Paletas y Ajustes de Apariencia
// ==========================================
enum VisualizerStyle { normal, circular }
enum VisualizerShape { bars, waves }

class AppTheme {
  final String key;
  final String name;
  final Color primary;
  final Color primaryDark;
  final Color background;
  final Color card;
  final Color cardHover;
  final Color darkGray;
  final Color lightGray;
  final Color accentGlow;

  const AppTheme({
    required this.key,
    required this.name,
    required this.primary,
    required this.primaryDark,
    required this.background,
    required this.card,
    required this.cardHover,
    required this.darkGray,
    required this.lightGray,
    required this.accentGlow,
  });

  static final Map<String, AppTheme> themes = {
    'sleek': const AppTheme(
      key: 'sleek',
      name: 'Spicetify Sleek',
      primary: Color(0xFF1DB954),
      primaryDark: Color(0xFF14833B),
      background: Color(0xFF0F1210),
      card: Color(0xFF161B17),
      cardHover: Color(0xFF202721),
      darkGray: Color(0xFF242C26),
      lightGray: Color(0xFFB3B3B3),
      accentGlow: Color(0xFF1DB954),
    ),
    'cyberpunk': const AppTheme(
      key: 'cyberpunk',
      name: 'Cyberpunk Neon',
      primary: Color(0xFF00F0FF),
      primaryDark: Color(0xFF0098A6),
      background: Color(0xFF0D0B18),
      card: Color(0xFF161226),
      cardHover: Color(0xFF231C3D),
      darkGray: Color(0xFF2A2247),
      lightGray: Color(0xFFC4B8EB),
      accentGlow: Color(0xFFFF0055),
    ),
    'amethyst': const AppTheme(
      key: 'amethyst',
      name: 'Midnight Amethyst',
      primary: Color(0xFF9D4EDD),
      primaryDark: Color(0xFF7B2CBF),
      background: Color(0xFF100B1A),
      card: Color(0xFF1A1329),
      cardHover: Color(0xFF291E42),
      darkGray: Color(0xFF332552),
      lightGray: Color(0xFFD4C2FC),
      accentGlow: Color(0xFFC77DFF),
    ),
    'crimson': const AppTheme(
      key: 'crimson',
      name: 'Crimson Velvet',
      primary: Color(0xFFFF2A55),
      primaryDark: Color(0xFFC71D3E),
      background: Color(0xFF140B0E),
      card: Color(0xFF1F1116),
      cardHover: Color(0xFF311A22),
      darkGray: Color(0xFF3B1E29),
      lightGray: Color(0xFFE5B8C3),
      accentGlow: Color(0xFFFF2A55),
    ),
    'oled': const AppTheme(
      key: 'oled',
      name: 'OLED Minimalist',
      primary: Color(0xFFFFFFFF),
      primaryDark: Color(0xFFCCCCCC),
      background: Color(0xFF000000),
      card: Color(0xFF101010),
      cardHover: Color(0xFF1C1C1C),
      darkGray: Color(0xFF242424),
      lightGray: Color(0xFFAAAAAA),
      accentGlow: Color(0xFFFFFFFF),
    ),
    'sunset': const AppTheme(
      key: 'sunset',
      name: 'Sunset Amber',
      primary: Color(0xFFFF9E00),
      primaryDark: Color(0xFFCC7E00),
      background: Color(0xFF14100A),
      card: Color(0xFF1F190F),
      cardHover: Color(0xFF332817),
      darkGray: Color(0xFF40321D),
      lightGray: Color(0xFFE0CDB2),
      accentGlow: Color(0xFFFF5400),
    ),
  };

  static AppTheme getTheme(String key) => themes[key] ?? themes['sleek']!;
}

class SpotifyTheme {
  static Color primary = const Color(0xFF1DB954);
  static Color primaryDark = const Color(0xFF178A3F);
  static Color background = const Color(0xFF121212);
  static Color card = const Color(0xFF181818);
  static Color cardHover = const Color(0xFF282828);
  static Color darkGray = const Color(0xFF242424);
  static Color lightGray = const Color(0xFFB3B3B3);
  static Color accentGlow = const Color(0xFF1DB954);
  static const Color white = Colors.white;

  static void applyTheme(AppTheme theme) {
    primary = theme.primary;
    primaryDark = theme.primaryDark;
    background = theme.background;
    card = theme.card;
    cardHover = theme.cardHover;
    darkGray = theme.darkGray;
    lightGray = theme.lightGray;
    accentGlow = theme.accentGlow;
  }

  static void applyCustomAccent(Color accent) {
    primary = accent;
    primaryDark = accent.withValues(alpha: 0.8);
    accentGlow = accent;
  }
}

// ==========================================
// COMPONENTE DE CRISTAL (GLASSMORPHISM PANEL)
// Fondos translúcidos con desenfoque de sistema y borde sutil
// ==========================================
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double? opacity;
  final Color? tintColor;
  final Border? border;
  final BoxConstraints? constraints;

  const GlassPanel({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 20.0,
    this.opacity,
    this.tintColor,
    this.border,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final effectiveOpacity = (opacity ?? provider.glassOpacity).clamp(0.0, 1.0);
    final effectiveBlur = blur > 0 ? blur : provider.blurAmount;
    final radius = borderRadius ?? BorderRadius.circular(16);
    return Container(
      width: width,
      height: height,
      margin: margin,
      constraints: constraints,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (tintColor ?? SpotifyTheme.card).withValues(alpha: effectiveOpacity),
              borderRadius: radius,
              border: border ??
                  Border.all(
                    color: effectiveOpacity < 0.25
                        ? SpotifyTheme.primary.withValues(alpha: 0.28)
                        : Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
              boxShadow: effectiveOpacity > 0.08
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28 * effectiveOpacity),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// MODELO DE PERFIL DE USUARIO
// ==========================================
class UserProfile {
  final String displayName;
  final String username;
  final String? avatarPath;
  final String bio;

  UserProfile({
    required this.displayName,
    required this.username,
    this.avatarPath,
    this.bio = 'Melómano en CYBERMUSIC',
  });

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'username': username,
        'avatarPath': avatarPath,
        'bio': bio,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      displayName: json['displayName']?.toString() ?? 'Melómano',
      username: json['username']?.toString() ?? 'usuario_${Random().nextInt(9999)}',
      avatarPath: json['avatarPath'] as String?,
      bio: json['bio']?.toString() ?? 'Melómano en CYBERMUSIC',
    );
  }

  factory UserProfile.random() {
    final rand = Random();
    final names = ['Alex Vance', 'Luna Star', 'Diego Rivera', 'Sofia Nova', 'Mateo Fox', 'Cami Beat', 'Neo Wave'];
    final selectedName = names[rand.nextInt(names.length)];
    final userTag = selectedName.toLowerCase().replaceAll(' ', '_') + rand.nextInt(999).toString();
    return UserProfile(
      displayName: selectedName,
      username: userTag,
      avatarPath: null,
      bio: 'Disfrutando de la música sin límites en CYBERMUSIC',
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? username,
    String? avatarPath,
    String? bio,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarPath: avatarPath ?? this.avatarPath,
      bio: bio ?? this.bio,
    );
  }
}

// ==========================================
// MODELO DE LETRA SINCRONIZADA
// ==========================================
class LyricLine {
  final Duration timestamp;
  final String text;

  LyricLine({required this.timestamp, required this.text});
}

// ==========================================
// MODELO DE PISTA
// ==========================================
class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? artworkUrl;
  final String audioUrl;
  final String? previewFallbackUrl;
  final String? youtubeVideoId;
  final bool isLocal;
  final Duration duration;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.artworkUrl,
    required this.audioUrl,
    this.previewFallbackUrl,
    this.youtubeVideoId,
    required this.isLocal,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'artworkUrl': artworkUrl,
        'audioUrl': audioUrl,
        'previewFallbackUrl': previewFallbackUrl,
        'youtubeVideoId': youtubeVideoId,
        'isLocal': isLocal,
        'durationMs': duration.inMilliseconds,
      };

  factory Track.fromSavedJson(Map<String, dynamic> json) {
    return Track(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Sin título',
      artist: json['artist']?.toString() ?? 'Artista desconocido',
      album: json['album']?.toString() ?? 'Álbum',
      artworkUrl: json['artworkUrl'] as String?,
      audioUrl: json['audioUrl']?.toString() ?? '',
      previewFallbackUrl: json['previewFallbackUrl'] as String?,
      youtubeVideoId: json['youtubeVideoId'] as String?,
      isLocal: json['isLocal'] == true,
      duration: Duration(milliseconds: (json['durationMs'] is int) ? json['durationMs'] : 200000),
    );
  }

  factory Track.fromCatalogJson(Map<String, dynamic> json) {
    String? artwork = json['artworkUrl100'] as String?;
    if (artwork != null) {
      artwork = artwork.replaceAll('100x100bb.jpg', '600x600bb.jpg');
    }
    return Track(
      id: 'cat_${json['trackId'] ?? DateTime.now().microsecondsSinceEpoch}',
      title: json['trackName'] ?? 'Sin título',
      artist: json['artistName'] ?? 'Artista desconocido',
      album: json['collectionName'] ?? 'Álbum',
      artworkUrl: artwork,
      audioUrl: '',
      previewFallbackUrl: json['previewUrl'] as String?,
      isLocal: false,
      duration: Duration(milliseconds: json['trackTimeMillis'] ?? 200000),
    );
  }

  factory Track.fromYoutubeVideo(yt_lib.Video video) {
    return Track(
      id: 'yt_${video.id.value}',
      title: video.title,
      artist: video.author,
      album: 'Pista Completa Online',
      artworkUrl: video.thumbnails.highResUrl,
      audioUrl: '',
      youtubeVideoId: video.id.value,
      isLocal: false,
      duration: video.duration ?? const Duration(minutes: 3, seconds: 30),
    );
  }
}

// ==========================================
// ELEMENTO DESTACADO PARA EL HOME
// ==========================================
class HomeHighlightItem {
  final String title;
  final String subtitle;
  final String query;
  final String imageUrl;

  const HomeHighlightItem({
    required this.title,
    required this.subtitle,
    required this.query,
    required this.imageUrl,
  });
}

enum RepeatMode { off, all, one }

// ==========================================
// GESTOR DE ESTADO GLOBAL (PROVIDER)
// ==========================================
class LibreSYProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final yt_lib.YoutubeExplode _yt = yt_lib.YoutubeExplode();
  final Random _random = Random();

  // Navegación: 0=Inicio, 1=Buscar, 2=Tu biblioteca, 3=Favoritos, 4=Letra en vivo, 5=Perfil
  int _currentTab = 0;
  int _previousTab = 0;
  int get currentTab => _currentTab;

  // Perfil del Usuario
  UserProfile _userProfile = UserProfile.random();
  UserProfile get userProfile => _userProfile;

  // Reproducción y Modos
  Track? _currentTrack;
  bool _isPlaying = false;
  bool _isBufferingTrack = false;
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.75;
  double _volumeBeforeMute = 0.75;

  // Listas de canciones y caché
  final List<Track> _localTracks = [];
  final List<Track> _onlineSearchResults = [];
  final Set<String> _favoriteTrackIds = {};
  final List<Track> _favoriteTracks = [];
  final List<Track> _recentlyPlayed = [];
  final List<Track> _popularTracks = [];
  final List<Track> _recommendedTracks = [];
  final Set<String> _downloadingTrackIds = {};
  final Set<String> _backgroundCachingTrackIds = {};
  final Map<String, String> _cachedFullAudioPaths = {};
  final List<String> _savedCustomFolders = [];
  List<Track> _activeQueue = [];

  // Perfil del Artista & Discografía
  String? _currentArtistName;
  String? _currentArtistAvatar;
  final List<Track> _artistTopTracks = [];
  bool _isLoadingArtist = false;
  Set<String> _followedArtists = {};
  int _artistMonthlyListeners = 0;

  bool _isSearching = false;
  bool _isLoadingPopular = false;
  bool _isLoadingRecommendations = false;

  // Color adaptativo según la portada del álbum / canción
  Color _lyricsPrimaryColor = const Color(0xFF1E3A2F);
  Color _lyricsSecondaryColor = const Color(0xFF101914);

  // Letras sincronizadas
  List<LyricLine> _currentLyrics = [];
  bool _isLoadingLyrics = false;

  // --- SPICETIFY STUDIO & PERSONALIZACIÓN ---
  bool _isRightSidebarOpen = false;
  bool _isVisualizerEnabled = true;
  VisualizerStyle _visualizerStyle = VisualizerStyle.normal;
  VisualizerShape _visualizerShape = VisualizerShape.bars;
  double _visualizerSensitivity = 1.0;
  bool _showVisualizerInBottomBar = true;

  bool _isDynamicBgEnabled = true;
  double _blurAmount = 24.0;
  double _glassOpacity = 0.45;
  bool _bgReactivity = true;

  String _activeThemeKey = 'sleek';
  bool _adBlockerEnabled = true;
  bool _ultraPerformanceMode = false;
  int _lyricOffsetMs = 0;
  bool _lyricsSplitMode = true;

  // --- FONDO CINEMÁTICO, VIDEO & LLUVIA DE COMETAS ---
  bool _isCometShowerEnabled = true;
  String? _customVideoPath;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  String _backgroundMode = 'space'; // 'space', 'nebula', 'cyberpunk', 'aurora', 'custom_video'
  bool _adaptiveColorFromBackground = true;
  Color _adaptiveDominantColor = const Color(0xFF00E5FF);

  // --- MODO BURBUJA FLOTANTE (MINI PLAYER ALWAYS-ON-TOP) ---
  bool _isMiniBubbleMode = false;
  bool _minimizeToBubbleEnabled = true;
  bool _wasMaximizedBeforeBubble = false;
  Size? _normalWindowSize;
  Offset? _normalWindowPosition;

  // Getters
  Track? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  bool get isBufferingTrack => _isBufferingTrack;
  bool get isShuffleEnabled => _isShuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  List<Track> get localTracks => _localTracks;
  List<Track> get onlineSearchResults => _onlineSearchResults;
  List<Track> get favoriteTracks => _favoriteTracks;
  List<Track> get recentlyPlayed => _recentlyPlayed;
  List<Track> get popularTracks => _popularTracks;
  List<Track> get recommendedTracks => _recommendedTracks;
  bool get isSearching => _isSearching;
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingRecommendations => _isLoadingRecommendations;
  Color get lyricsPrimaryColor => _lyricsPrimaryColor;
  Color get lyricsSecondaryColor => _lyricsSecondaryColor;
  List<LyricLine> get currentLyrics => _currentLyrics;
  bool get isLoadingLyrics => _isLoadingLyrics;

  // Getters Perfil del Artista
  String? get currentArtistName => _currentArtistName;
  String? get currentArtistAvatar => _currentArtistAvatar;
  List<Track> get artistTopTracks => _artistTopTracks;
  bool get isLoadingArtist => _isLoadingArtist;
  int get artistMonthlyListeners => _artistMonthlyListeners;
  bool isFollowingArtist(String? artist) =>
      artist != null && _followedArtists.contains(artist.trim().toLowerCase());

  String get artistMonthlyListenersFormatted {
    final str = _artistMonthlyListeners.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (m) => '${m[1]},');
  }

  // Getters Spicetify Studio
  bool get isRightSidebarOpen => _isRightSidebarOpen;
  bool get isVisualizerEnabled => _isVisualizerEnabled;
  VisualizerStyle get visualizerStyle => _visualizerStyle;
  VisualizerShape get visualizerShape => _visualizerShape;
  double get visualizerSensitivity => _visualizerSensitivity;
  bool get showVisualizerInBottomBar => _showVisualizerInBottomBar;

  bool get isDynamicBgEnabled => _isDynamicBgEnabled;
  double get blurAmount => _blurAmount;
  double get glassOpacity => _glassOpacity;
  bool get bgReactivity => _bgReactivity;

  bool get isCometShowerEnabled => _isCometShowerEnabled;
  String? get customVideoPath => _customVideoPath;
  VideoPlayerController? get videoController => _videoController;
  bool get isVideoInitialized => _isVideoInitialized;
  String get backgroundMode => _backgroundMode;
  bool get adaptiveColorFromBackground => _adaptiveColorFromBackground;
  Color get adaptiveDominantColor => _adaptiveDominantColor;

  bool get isMiniBubbleMode => _isMiniBubbleMode;
  bool get minimizeToBubbleEnabled => _minimizeToBubbleEnabled;

  String get activeThemeKey => _activeThemeKey;
  bool get adBlockerEnabled => _adBlockerEnabled;
  bool get ultraPerformanceMode => _ultraPerformanceMode;
  int get lyricOffsetMs => _lyricOffsetMs;
  bool get lyricsSplitMode => _lyricsSplitMode;
  List<Track> get effectiveQueue => _getEffectiveQueue();
  List<String> get savedCustomFolders => _savedCustomFolders;

  List<Track> get allLibraryTracks {
    final Map<String, Track> map = {};
    for (final t in _favoriteTracks) {
      map[t.id] = t;
    }
    for (final t in _localTracks) {
      map[t.id] = t;
    }
    return map.values.toList();
  }

  bool isDownloading(String trackId) => _downloadingTrackIds.contains(trackId);

  LibreSYProvider() {
    _initAudioStreams();
    _loadPersistentState().then((_) {
      fetchDailyPopularTracks();
      fetchRecommendedTracks();
    });
  }

  void setTab(int index) {
    if (_currentTab != index) {
      if (index == 4 || index == 6) {
        _previousTab = _currentTab;
      } else {
        _previousTab = index;
      }
      _currentTab = index;
      notifyListeners();
    }
  }

  void toggleLyricsView() {
    if (_currentTab == 4) {
      _currentTab = _previousTab;
    } else {
      _previousTab = _currentTab;
      _currentTab = 4;
    }
    notifyListeners();
  }

  void goBackFromLyrics() {
    _currentTab = _previousTab;
    notifyListeners();
  }

  // --- PERFIL DE ARTISTA & DISCOGRAFÍA ---
  void openArtistProfile(String artistName, {String? avatarUrl}) {
    final clean = artistName.trim();
    if (clean.isEmpty || clean == 'Archivo de tu PC' || clean == 'Artista desconocido') return;
    if (_currentTab != 6) {
      _previousTab = _currentTab;
    }
    _currentTab = 6;
    _currentArtistName = clean;
    _currentArtistAvatar = avatarUrl;
    final hash = clean.toLowerCase().hashCode.abs();
    _artistMonthlyListeners = (hash % 14500000) + 650000;
    notifyListeners();
    fetchArtistDiscography(clean, preferredArtwork: avatarUrl);
  }

  void goBackFromArtistProfile() {
    _currentTab = _previousTab == 6 ? 0 : _previousTab;
    notifyListeners();
  }

  void toggleFollowArtist(String artistName) {
    final key = artistName.trim().toLowerCase();
    if (key.isEmpty) return;
    if (_followedArtists.contains(key)) {
      _followedArtists.remove(key);
    } else {
      _followedArtists.add(key);
    }
    _savePersistentState();
    notifyListeners();
  }

  Future<void> fetchArtistDiscography(String artistName, {String? preferredArtwork}) async {
    _isLoadingArtist = true;
    _artistTopTracks.clear();
    notifyListeners();

    try {
      final clean = artistName.split('&').first.split(',').first.split('feat').first.trim();
      final url = Uri.parse(
        'https://itunes.apple.com/search?term=${Uri.encodeComponent(clean)}&media=music&entity=song&attribute=artistTerm&limit=50',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List results = data['results'] ?? [];
        final Set<String> seen = {};
        for (var item in results) {
          final t = Track.fromCatalogJson(item);
          final norm = t.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          if (!seen.contains(norm)) {
            seen.add(norm);
            _artistTopTracks.add(t);
          }
        }
      }

      // Si no hubo resultados con attribute=artistTerm, intentar búsqueda estándar
      if (_artistTopTracks.isEmpty) {
        final broadUrl = Uri.parse(
          'https://itunes.apple.com/search?term=${Uri.encodeComponent(clean)}&media=music&entity=song&limit=40',
        );
        final broadRes = await http.get(broadUrl).timeout(const Duration(seconds: 8));
        if (broadRes.statusCode == 200) {
          final data = json.decode(broadRes.body);
          final List results = data['results'] ?? [];
          final Set<String> seen = {};
          for (var item in results) {
            final t = Track.fromCatalogJson(item);
            final norm = t.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
            if (!seen.contains(norm)) {
              seen.add(norm);
              _artistTopTracks.add(t);
            }
          }
        }
      }

      // Fallback a YouTube si iTunes no devolvió canciones
      if (_artistTopTracks.isEmpty) {
        final ytResults = await _yt.search.search('$clean canciones');
        for (final video in ytResults.take(20)) {
          _artistTopTracks.add(Track.fromYoutubeVideo(video));
        }
      }

      if ((_currentArtistAvatar == null || _currentArtistAvatar!.isEmpty) && _artistTopTracks.isNotEmpty) {
        _currentArtistAvatar = _artistTopTracks.first.artworkUrl;
      }
    } catch (e) {
      debugPrint("Error obteniendo canciones de $artistName: $e");
    } finally {
      _isLoadingArtist = false;
      notifyListeners();
    }
  }

  void playArtistAll({bool shuffle = false}) {
    if (_artistTopTracks.isEmpty) return;
    _activeQueue = List<Track>.from(_artistTopTracks);
    if (shuffle) {
      _activeQueue.shuffle();
    }
    playTrack(_activeQueue.first);
  }

  // --- GESTIÓN DEL PERFIL DE USUARIO ---
  Future<void> updateProfile({String? displayName, String? username, String? avatarPath, String? bio}) async {
    _userProfile = _userProfile.copyWith(
      displayName: displayName,
      username: username,
      avatarPath: avatarPath,
      bio: bio,
    );
    await _savePersistentState();
    notifyListeners();
  }

  Future<void> pickAvatarImage() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'webp'],
    );
    if (file != null && file.path != null) {
      await updateProfile(avatarPath: file.path!);
    }
  }

  // --- SPICETIFY STUDIO & CUSTOMIZATION SETTERS ---
  void toggleRightSidebar() {
    _isRightSidebarOpen = !_isRightSidebarOpen;
    notifyListeners();
  }

  void setVisualizerEnabled(bool val) {
    _isVisualizerEnabled = val;
    _savePersistentState();
    notifyListeners();
  }

  void setVisualizerStyle(VisualizerStyle style) {
    _visualizerStyle = style;
    _savePersistentState();
    notifyListeners();
  }

  void setVisualizerShape(VisualizerShape shape) {
    _visualizerShape = shape;
    _savePersistentState();
    notifyListeners();
  }

  void setVisualizerSensitivity(double val) {
    _visualizerSensitivity = val;
    _savePersistentState();
    notifyListeners();
  }

  void setShowVisualizerInBottomBar(bool val) {
    _showVisualizerInBottomBar = val;
    _savePersistentState();
    notifyListeners();
  }

  void setDynamicBgEnabled(bool val) {
    _isDynamicBgEnabled = val;
    _savePersistentState();
    notifyListeners();
  }

  void setBlurAmount(double val) {
    _blurAmount = val;
    _savePersistentState();
    notifyListeners();
  }

  void setGlassOpacity(double val) {
    _glassOpacity = val.clamp(0.0, 1.0);
    _savePersistentState();
    notifyListeners();
  }

  void setBgReactivity(bool val) {
    _bgReactivity = val;
    _savePersistentState();
    notifyListeners();
  }

  Future<void> initCustomVideo(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return;

      final prev = _videoController;
      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0.0);
      await _videoController!.play();
      prev?.dispose();

      _customVideoPath = path;
      _backgroundMode = 'custom_video';
      _isVideoInitialized = true;
      _syncAdaptiveColors();
      _savePersistentState();
      notifyListeners();
    } catch (e) {
      debugPrint('Error inicializando video: $e');
    }
  }

  Future<void> pickAndSetCustomVideo() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mkv', 'mov', 'avi', 'webm', 'wmv'],
      );
      if (file != null && file.path != null) {
        await initCustomVideo(file.path!);
      }
    } catch (e) {
      debugPrint('Error seleccionando video: $e');
    }
  }

  Future<void> restoreSpaceBackground() async {
    await _videoController?.pause();
    await _videoController?.dispose();
    _videoController = null;
    _customVideoPath = null;
    _isVideoInitialized = false;
    _backgroundMode = 'space';
    _syncAdaptiveColors();
    _savePersistentState();
    notifyListeners();
  }

  void setBackgroundMode(String mode) {
    _backgroundMode = mode;
    if (mode != 'custom_video') {
      _videoController?.pause();
    } else {
      _videoController?.play();
    }
    _syncAdaptiveColors();
    _savePersistentState();
    notifyListeners();
  }

  void setCometShowerEnabled(bool val) {
    _isCometShowerEnabled = val;
    _savePersistentState();
    notifyListeners();
  }

  void setAdaptiveColorMode(bool val) {
    _adaptiveColorFromBackground = val;
    _syncAdaptiveColors();
    _savePersistentState();
    notifyListeners();
  }

  void _syncAdaptiveColors() {
    if (!_adaptiveColorFromBackground) {
      if (_currentTrack != null) {
        SpotifyTheme.applyCustomAccent(_lyricsPrimaryColor);
      }
      return;
    }

    Color dominantAccent;
    if (_backgroundMode == 'space') {
      dominantAccent = const Color(0xFF00E5FF); // Azul estelar / Cyan cósmico
    } else if (_backgroundMode == 'nebula') {
      dominantAccent = const Color(0xFFD050FF); // Violeta / Magenta nebulosa
    } else if (_backgroundMode == 'cyberpunk') {
      dominantAccent = const Color(0xFF00FFA3); // Verde neón cyberpunk
    } else if (_backgroundMode == 'aurora') {
      dominantAccent = const Color(0xFF00FF87); // Aurora esmeralda
    } else if (_backgroundMode == 'custom_video') {
      dominantAccent = const Color(0xFF00F0FF); // Neón cian vibrante para video
    } else {
      dominantAccent = const Color(0xFF1DB954);
    }

    _adaptiveDominantColor = dominantAccent;
    SpotifyTheme.applyCustomAccent(dominantAccent);
    notifyListeners();
  }

  bool _isTransitioningBubbleMode = false;

  Future<void> enterMiniBubbleMode() async {
    if (_isTransitioningBubbleMode || _isMiniBubbleMode) return;
    _isTransitioningBubbleMode = true;
    try {
      final isMax = await windowManager.isMaximized();
      _wasMaximizedBeforeBubble = isMax;

      if (!isMax) {
        final curSize = await windowManager.getSize();
        final curPos = await windowManager.getPosition();
        // Guardar tamaño normal válido (mínimo 900x600 para evitar capturar tamaños corruptos o residuales)
        if (curSize.width >= 900 && curSize.height >= 600) {
          _normalWindowSize = curSize;
          _normalWindowPosition = curPos;
        } else if (_normalWindowSize == null || _normalWindowSize!.width < 900) {
          _normalWindowSize = const Size(1280, 800);
        }
      } else {
        await windowManager.unmaximize();
        await Future.delayed(const Duration(milliseconds: 60));
      }

      _isMiniBubbleMode = true;
      notifyListeners();

      await windowManager.setAlwaysOnTop(true);
      await windowManager.setAsFrameless();
      await windowManager.setHasShadow(false);
      await Window.setEffect(effect: WindowEffect.transparent);
      await windowManager.setSize(const Size(260, 260));
      await windowManager.focus();
    } catch (e) {
      debugPrint('Error entrando en modo burbuja flotante: $e');
    } finally {
      _isTransitioningBubbleMode = false;
    }
  }

  Future<void> exitMiniBubbleMode() async {
    if (_isTransitioningBubbleMode || !_isMiniBubbleMode) return;
    _isTransitioningBubbleMode = true;
    try {
      await windowManager.setAlwaysOnTop(false);
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await windowManager.setHasShadow(true);

      if (_wasMaximizedBeforeBubble) {
        await windowManager.maximize();
      } else {
        final targetSize = (_normalWindowSize != null &&
                _normalWindowSize!.width >= 900 &&
                _normalWindowSize!.height >= 600)
            ? _normalWindowSize!
            : const Size(1280, 800);
        await windowManager.setSize(targetSize);
        if (_normalWindowPosition != null) {
          await windowManager.setPosition(_normalWindowPosition!);
        } else {
          await windowManager.center();
        }
      }

      _isMiniBubbleMode = false;
      notifyListeners();
      await windowManager.focus();
    } catch (e) {
      debugPrint('Error saliendo del modo burbuja flotante: $e');
      _isMiniBubbleMode = false;
      notifyListeners();
    } finally {
      _isTransitioningBubbleMode = false;
    }
  }

  void setMinimizeToBubbleEnabled(bool val) {
    _minimizeToBubbleEnabled = val;
    _savePersistentState();
    notifyListeners();
  }

  void setTheme(String key) {
    _activeThemeKey = key;
    final theme = AppTheme.getTheme(key);
    SpotifyTheme.applyTheme(theme);
    _savePersistentState();
    notifyListeners();
  }

  void setAdBlockerEnabled(bool val) {
    _adBlockerEnabled = val;
    _savePersistentState();
    notifyListeners();
  }

  void setUltraPerformanceMode(bool val) {
    _ultraPerformanceMode = val;
    _savePersistentState();
    notifyListeners();
  }

  void setLyricOffsetMs(int val) {
    _lyricOffsetMs = val;
    _savePersistentState();
    notifyListeners();
  }

  void toggleLyricsSplitMode() {
    _lyricsSplitMode = !_lyricsSplitMode;
    _savePersistentState();
    notifyListeners();
  }

  void resetCustomizationToDefaults() {
    _isVisualizerEnabled = true;
    _visualizerStyle = VisualizerStyle.normal;
    _visualizerShape = VisualizerShape.bars;
    _visualizerSensitivity = 1.0;
    _showVisualizerInBottomBar = true;
    _isDynamicBgEnabled = true;
    _blurAmount = 24.0;
    _glassOpacity = 0.58;
    _bgReactivity = true;
    _activeThemeKey = 'sleek';
    _adBlockerEnabled = true;
    _ultraPerformanceMode = false;
    _lyricOffsetMs = 0;
    _lyricsSplitMode = true;
    SpotifyTheme.applyTheme(AppTheme.getTheme('sleek'));
    _savePersistentState();
    notifyListeners();
  }

  // --- GUARDADO Y CARGA EN DISCO (JSON) ---
  File _getPersistentDataFile() {
    final base = _getMusicFolder();
    return File('${base.path}\\user_library.json');
  }

  Future<void> _savePersistentState() async {
    try {
      final file = _getPersistentDataFile();
      final payload = {
        'volume': _volume,
        'isShuffleEnabled': _isShuffleEnabled,
        'repeatMode': _repeatMode.index,
        'userProfile': _userProfile.toJson(),
        'favorites': _favoriteTracks.map((t) => t.toJson()).toList(),
        'recentlyPlayed': _recentlyPlayed.take(20).map((t) => t.toJson()).toList(),
        'customFolders': _savedCustomFolders,
        'visualizerEnabled': _isVisualizerEnabled,
        'visualizerStyle': _visualizerStyle.index,
        'visualizerShape': _visualizerShape.index,
        'visualizerSensitivity': _visualizerSensitivity,
        'showVisualizerInBottomBar': _showVisualizerInBottomBar,
        'isDynamicBgEnabled': _isDynamicBgEnabled,
        'blurAmount': _blurAmount,
        'glassOpacity': _glassOpacity,
        'bgReactivity': _bgReactivity,
        'activeThemeKey': _activeThemeKey,
        'adBlockerEnabled': _adBlockerEnabled,
        'ultraPerformanceMode': _ultraPerformanceMode,
        'lyricOffsetMs': _lyricOffsetMs,
        'lyricsSplitMode': _lyricsSplitMode,
        'isCometShowerEnabled': _isCometShowerEnabled,
        'backgroundMode': _backgroundMode,
        'adaptiveColorFromBackground': _adaptiveColorFromBackground,
        'customVideoPath': _customVideoPath,
        'minimizeToBubbleEnabled': _minimizeToBubbleEnabled,
        'followedArtists': _followedArtists.toList(),
      };
      await file.writeAsString(json.encode(payload));
    } catch (e) {
      debugPrint("Error guardando estado: $e");
    }
  }

  Future<void> _loadPersistentState() async {
    final defaultDir = _getMusicFolder();
    if (defaultDir.existsSync()) {
      scanFolder(defaultDir.path, clearPrevious: true, persistFolder: false);
    }

    try {
      final file = _getPersistentDataFile();
      if (file.existsSync()) {
        final raw = await file.readAsString();
        final data = json.decode(raw) as Map<String, dynamic>;

        if (data['volume'] is num) {
          _volume = (data['volume'] as num).toDouble().clamp(0.0, 1.0);
          _audioPlayer.setVolume(_volume);
        }
        if (data['isShuffleEnabled'] is bool) {
          _isShuffleEnabled = data['isShuffleEnabled'] as bool;
        }
        if (data['repeatMode'] is int) {
          final idx = (data['repeatMode'] as int).clamp(0, RepeatMode.values.length - 1);
          _repeatMode = RepeatMode.values[idx];
        }
        if (data['userProfile'] is Map<String, dynamic>) {
          _userProfile = UserProfile.fromJson(data['userProfile'] as Map<String, dynamic>);
        }

        if (data['visualizerEnabled'] is bool) {
          _isVisualizerEnabled = data['visualizerEnabled'] as bool;
        }
        if (data['visualizerStyle'] is int) {
          final idx = (data['visualizerStyle'] as int).clamp(0, VisualizerStyle.values.length - 1);
          _visualizerStyle = VisualizerStyle.values[idx];
        }
        if (data['visualizerShape'] is int) {
          final idx = (data['visualizerShape'] as int).clamp(0, VisualizerShape.values.length - 1);
          _visualizerShape = VisualizerShape.values[idx];
        }
        if (data['visualizerSensitivity'] is num) {
          _visualizerSensitivity = (data['visualizerSensitivity'] as num).toDouble().clamp(0.5, 2.5);
        }
        if (data['showVisualizerInBottomBar'] is bool) {
          _showVisualizerInBottomBar = data['showVisualizerInBottomBar'] as bool;
        }
        if (data['isDynamicBgEnabled'] is bool) {
          _isDynamicBgEnabled = data['isDynamicBgEnabled'] as bool;
        }
        if (data['blurAmount'] is num) {
          _blurAmount = (data['blurAmount'] as num).toDouble().clamp(0.0, 50.0);
        }
        if (data['glassOpacity'] is num) {
          _glassOpacity = (data['glassOpacity'] as num).toDouble().clamp(0.0, 1.0);
        }
        if (data['bgReactivity'] is bool) {
          _bgReactivity = data['bgReactivity'] as bool;
        }
        if (data['isCometShowerEnabled'] is bool) {
          _isCometShowerEnabled = data['isCometShowerEnabled'] as bool;
        }
        if (data['backgroundMode'] is String) {
          _backgroundMode = data['backgroundMode'] as String;
        }
        if (data['adaptiveColorFromBackground'] is bool) {
          _adaptiveColorFromBackground = data['adaptiveColorFromBackground'] as bool;
        }
        if (data['customVideoPath'] is String && (data['customVideoPath'] as String).isNotEmpty) {
          final savedPath = data['customVideoPath'] as String;
          if (File(savedPath).existsSync()) {
            initCustomVideo(savedPath);
          }
        }
        _syncAdaptiveColors();
        if (data['activeThemeKey'] is String) {
          _activeThemeKey = data['activeThemeKey'] as String;
          SpotifyTheme.applyTheme(AppTheme.getTheme(_activeThemeKey));
        }
        if (data['adBlockerEnabled'] is bool) {
          _adBlockerEnabled = data['adBlockerEnabled'] as bool;
        }
        if (data['ultraPerformanceMode'] is bool) {
          _ultraPerformanceMode = data['ultraPerformanceMode'] as bool;
        }
        if (data['lyricOffsetMs'] is int) {
          _lyricOffsetMs = (data['lyricOffsetMs'] as int).clamp(-1000, 1000);
        }
        if (data['lyricsSplitMode'] is bool) {
          _lyricsSplitMode = data['lyricsSplitMode'] as bool;
        }

        if (data['minimizeToBubbleEnabled'] is bool) {
          _minimizeToBubbleEnabled = data['minimizeToBubbleEnabled'] as bool;
        }
        if (data['favorites'] is List) {
          _favoriteTracks.clear();
          _favoriteTrackIds.clear();
          for (final item in (data['favorites'] as List)) {
            if (item is Map<String, dynamic>) {
              final track = Track.fromSavedJson(item);
              if (track.id.isNotEmpty) {
                _favoriteTracks.add(track);
                _favoriteTrackIds.add(track.id);
              }
            }
          }
        }

        if (data['recentlyPlayed'] is List) {
          _recentlyPlayed.clear();
          for (final item in (data['recentlyPlayed'] as List)) {
            if (item is Map<String, dynamic>) {
              final track = Track.fromSavedJson(item);
              if (track.id.isNotEmpty) {
                _recentlyPlayed.add(track);
              }
            }
          }
        }

        if (data['customFolders'] is List) {
          _savedCustomFolders.clear();
          for (final folder in (data['customFolders'] as List)) {
            final folderPath = folder.toString();
            if (Directory(folderPath).existsSync()) {
              _savedCustomFolders.add(folderPath);
              scanFolder(folderPath, clearPrevious: false, persistFolder: false);
            }
          }
        }

        if (data['followedArtists'] is List) {
          _followedArtists = (data['followedArtists'] as List).map((e) => e.toString().toLowerCase()).toSet();
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error cargando biblioteca persistente: $e");
    }
  }

  void _initAudioStreams() {
    _audioPlayer.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _audioPlayer.onDurationChanged.listen((dur) {
      if (dur.inSeconds > 0) {
        _duration = dur;
        notifyListeners();
      }
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      _handleTrackCompletion();
    });
    _audioPlayer.setVolume(_volume);
  }

  void _handleTrackCompletion() {
    if (_currentTrack == null) return;

    if (_repeatMode == RepeatMode.one) {
      playTrack(_currentTrack!);
      return;
    }

    final queue = _getEffectiveQueue();
    if (queue.isEmpty) return;

    if (_isShuffleEnabled && queue.length > 1) {
      final others = queue.where((t) => t.id != _currentTrack!.id).toList();
      final nextTrack = others[_random.nextInt(others.length)];
      playTrack(nextTrack);
      return;
    }

    final currentIdx = queue.indexWhere((t) => t.id == _currentTrack!.id);
    if (currentIdx >= 0 && currentIdx + 1 < queue.length) {
      playTrack(queue[currentIdx + 1]);
    } else if (_repeatMode == RepeatMode.all && queue.isNotEmpty) {
      playTrack(queue.first);
    }
  }

  List<Track> _getEffectiveQueue() {
    if (_activeQueue.isNotEmpty) return _activeQueue;
    if (_currentTab == 6 && _artistTopTracks.isNotEmpty) return _artistTopTracks;
    if (_currentTab == 1 && _onlineSearchResults.isNotEmpty) return _onlineSearchResults;
    if (_currentTab == 3 && _favoriteTracks.isNotEmpty) return _favoriteTracks;
    if (allLibraryTracks.isNotEmpty) return allLibraryTracks;
    return _onlineSearchResults;
  }

  void _updateActiveQueueFromContext() {
    if (_currentTab == 6 && _artistTopTracks.isNotEmpty) {
      _activeQueue = List<Track>.from(_artistTopTracks);
    } else if (_currentTab == 1 && _onlineSearchResults.isNotEmpty) {
      _activeQueue = List<Track>.from(_onlineSearchResults);
    } else if (_currentTab == 3 && _favoriteTracks.isNotEmpty) {
      _activeQueue = List<Track>.from(_favoriteTracks);
    } else if (_currentTab == 2 && allLibraryTracks.isNotEmpty) {
      _activeQueue = List<Track>.from(allLibraryTracks);
    } else if (_activeQueue.isEmpty) {
      _activeQueue = allLibraryTracks.isNotEmpty
          ? List<Track>.from(allLibraryTracks)
          : List<Track>.from(_onlineSearchResults);
    }
  }

  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    _savePersistentState();
    notifyListeners();
  }

  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    _savePersistentState();
    notifyListeners();
  }

  void playNext() {
    final queue = _getEffectiveQueue();
    if (queue.isEmpty) return;

    if (_currentTrack == null) {
      playTrack(queue.first);
      return;
    }

    if (_isShuffleEnabled && queue.length > 1) {
      final others = queue.where((t) => t.id != _currentTrack!.id).toList();
      final nextTrack = others[_random.nextInt(others.length)];
      playTrack(nextTrack, keepQueue: true);
      return;
    }

    final currentIdx = queue.indexWhere((t) => t.id == _currentTrack!.id);
    if (currentIdx >= 0 && currentIdx + 1 < queue.length) {
      playTrack(queue[currentIdx + 1], keepQueue: true);
    } else {
      playTrack(queue.first, keepQueue: true);
    }
  }

  void playPrevious() {
    if (_position.inSeconds > 3) {
      seek(Duration.zero);
      return;
    }

    final queue = _getEffectiveQueue();
    if (queue.isEmpty) {
      seek(Duration.zero);
      return;
    }

    if (_currentTrack == null) {
      playTrack(queue.first);
      return;
    }

    final currentIdx = queue.indexWhere((t) => t.id == _currentTrack!.id);
    if (currentIdx > 0) {
      playTrack(queue[currentIdx - 1], keepQueue: true);
    } else {
      playTrack(queue.last, keepQueue: true);
    }
  }

  void toggleMute() {
    if (_volume > 0) {
      _volumeBeforeMute = _volume;
      setVolume(0.0);
    } else {
      setVolume(_volumeBeforeMute > 0.05 ? _volumeBeforeMute : 0.75);
    }
  }

  Directory _getMusicFolder() {
    final userProfile = Platform.environment['USERPROFILE'] ?? 'C:\\Users\\Public';
    final dir = Directory('$userProfile\\Music\\LIBRE-SY');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Directory _getCacheFolder() {
    final base = _getMusicFolder();
    final cacheDir = Directory('${base.path}\\.cache');
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }
    return cacheDir;
  }

  String _cleanSongSearchQuery(String artist, String title) {
    String cleanTitle = title
        .replaceAll(RegExp(r'\((feat\.|ft\.|official|video|audio|remastered|deluxe|version).*?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[(feat\.|ft\.|official|video|audio|remastered|deluxe|version).*?\]', caseSensitive: false), '')
        .trim();
    String cleanArtist = artist
        .replaceAll('Archivos locales', '')
        .replaceAll('Artista desconocido', '')
        .trim();
    if (cleanArtist.isNotEmpty) {
      return '$cleanArtist - $cleanTitle';
    }
    return cleanTitle;
  }

  Future<String?> _resolveYoutubeVideoId(Track track) async {
    if (track.youtubeVideoId != null && track.youtubeVideoId!.isNotEmpty) {
      return track.youtubeVideoId;
    }
    try {
      final queryBase = _cleanSongSearchQuery(track.artist, track.title);
      final searchQueries = [
        '$queryBase official audio',
        '$queryBase audio',
        queryBase,
        '${track.artist} - ${track.title}',
      ];

      for (final query in searchQueries) {
        try {
          final results = await _yt.search.search(query).timeout(const Duration(seconds: 6));
          if (results.isNotEmpty) {
            return results.first.id.value;
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error buscando video en YouTube: $e');
    }
    return null;
  }

  void _cacheStreamInBackground(
    Track track,
    yt_lib.AudioOnlyStreamInfo audioStream,
    File destinationFile,
  ) {
    if (destinationFile.existsSync() && destinationFile.lengthSync() > 100000) {
      return;
    }
    if (_backgroundCachingTrackIds.contains(track.id)) return;
    _backgroundCachingTrackIds.add(track.id);

    Future.microtask(() async {
      final tempFile = File('${destinationFile.path}.tmp');
      try {
        if (tempFile.existsSync()) {
          try {
            tempFile.deleteSync();
          } catch (_) {}
        }
        final stream = _yt.videos.streamsClient.get(audioStream);
        final sink = tempFile.openWrite();
        await stream.pipe(sink);
        await sink.flush();
        await sink.close();

        if (tempFile.existsSync() && tempFile.lengthSync() > 100000) {
          if (destinationFile.existsSync()) {
            try {
              destinationFile.deleteSync();
            } catch (_) {}
          }
          tempFile.renameSync(destinationFile.path);
          _cachedFullAudioPaths[track.id] = destinationFile.path;
          debugPrint('Pista cacheada en segundo plano con éxito: ${destinationFile.path}');
        }
      } catch (e) {
        debugPrint('Error en caché en segundo plano: $e');
        if (tempFile.existsSync()) {
          try {
            tempFile.deleteSync();
          } catch (_) {}
        }
      } finally {
        _backgroundCachingTrackIds.remove(track.id);
      }
    });
  }

  String? _findExecutable(String name) {
    // 1. Directorio donde está instalado CYBERMUSIC.exe (estándar para instalador y amigos)
    try {
      final appDir = File(Platform.resolvedExecutable).parent.path;
      final exeInApp = File('$appDir\\$name');
      if (exeInApp.existsSync()) return exeInApp.path;
      final exeInData = File('$appDir\\data\\$name');
      if (exeInData.existsSync()) return exeInData.path;
    } catch (_) {}

    // 2. Carpeta de música del usuario (C:\Users\<user>\Music\LIBRE-SY)
    try {
      final baseDir = _getMusicFolder();
      final exeInMusic = File('${baseDir.path}\\$name');
      if (exeInMusic.existsSync()) return exeInMusic.path;
    } catch (_) {}

    // 3. Directorio de trabajo actual
    try {
      final exeInCurrent = File('.\\$name');
      if (exeInCurrent.existsSync()) return exeInCurrent.path;
    } catch (_) {}

    return null;
  }

  Future<String?> _resolveAndCacheFullAudioYtDlp(Track track, File cachedFile) async {
    final ytDlpPath = _findExecutable('yt-dlp.exe');
    final ffmpegPath = _findExecutable('ffmpeg.exe');
    if (ytDlpPath == null) {
      debugPrint('yt-dlp.exe no encontrado en ninguna ruta del sistema');
      return null;
    }

    try {
      final queryTarget = (track.youtubeVideoId != null && track.youtubeVideoId!.isNotEmpty)
          ? 'https://www.youtube.com/watch?v=${track.youtubeVideoId}'
          : 'ytsearch1:${track.artist} - ${track.title} Official Audio';

      const nodePath = 'C:\\Program Files\\nodejs\\node.exe';
      final hasNode = File(nodePath).existsSync();

      final args = <String>[
        if (hasNode) ...[
          '--js-runtimes',
          'node:$nodePath',
        ],
        if (ffmpegPath != null) ...[
          '--ffmpeg-location',
          ffmpegPath,
        ],
        '--concurrent-fragments',
        '4',
        '-f',
        '140/bestaudio[ext=m4a]/bestaudio',
        '-o',
        cachedFile.path,
        '--no-playlist',
        '--quiet',
        '--no-warnings',
        queryTarget,
      ];

      final proc = await Process.run(ytDlpPath, args);
      if (proc.exitCode != 0) {
        debugPrint('yt-dlp proceso código de salida ${proc.exitCode}: ${proc.stderr}');
      }

      if (cachedFile.existsSync() && cachedFile.lengthSync() > 100000) {
        _cachedFullAudioPaths[track.id] = cachedFile.path;
        return cachedFile.path;
      }
    } catch (e) {
      debugPrint("Error ejecutando yt-dlp: $e");
    }
    return null;
  }

  Future<String?> _resolveAndCacheFullAudio(Track track) async {
    if (track.isLocal && File(track.audioUrl).existsSync()) {
      return track.audioUrl;
    }
    if (_cachedFullAudioPaths.containsKey(track.id)) {
      final cachedPath = _cachedFullAudioPaths[track.id]!;
      final f = File(cachedPath);
      if (f.existsSync() && f.lengthSync() > 100000) {
        return cachedPath;
      }
    }

    final cacheDir = _getCacheFolder();
    final safeId = track.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final cachedFile = File('${cacheDir.path}\\$safeId.m4a');

    if (cachedFile.existsSync()) {
      if (cachedFile.lengthSync() > 100000) {
        _cachedFullAudioPaths[track.id] = cachedFile.path;
        return cachedFile.path;
      } else {
        try {
          cachedFile.deleteSync();
        } catch (_) {}
      }
    }

    // 1. Descarga completa vía yt-dlp empaquetado (garantizado, rápido ~1s y sin cortes)
    final ytDlpResult = await _resolveAndCacheFullAudioYtDlp(track, cachedFile);
    if (ytDlpResult != null && File(ytDlpResult).existsSync() && File(ytDlpResult).lengthSync() > 100000) {
      _cachedFullAudioPaths[track.id] = ytDlpResult;
      return ytDlpResult;
    }

    // 2. Fallback pure Dart con YoutubeExplode
    try {
      final videoId = await _resolveYoutubeVideoId(track);
      if (videoId != null && videoId.isNotEmpty) {
        final manifest = await _yt.videos.streamsClient.getManifest(videoId).timeout(const Duration(seconds: 8));
        yt_lib.AudioOnlyStreamInfo? audioStream;
        try {
          audioStream = manifest.audioOnly.firstWhere(
            (s) => s.container.name.toLowerCase() == 'mp4' || s.container == yt_lib.StreamContainer.mp4,
          );
        } catch (_) {
          audioStream = manifest.audioOnly.withHighestBitrate();
        }

        if (audioStream != null) {
          final tempFile = File('${cachedFile.path}.tmp');
          if (tempFile.existsSync()) {
            try {
              tempFile.deleteSync();
            } catch (_) {}
          }
          final stream = _yt.videos.streamsClient.get(audioStream);
          final sink = tempFile.openWrite();
          await stream.pipe(sink).timeout(const Duration(seconds: 15));
          await sink.flush();
          await sink.close();

          if (tempFile.existsSync() && tempFile.lengthSync() > 100000) {
            if (cachedFile.existsSync()) {
              try {
                cachedFile.deleteSync();
              } catch (_) {}
            }
            tempFile.renameSync(cachedFile.path);
            _cachedFullAudioPaths[track.id] = cachedFile.path;
            return cachedFile.path;
          }
        }
      }
    } catch (e) {
      debugPrint('Error resolviendo audio con YoutubeExplode: $e');
    }

    return null;
  }

  Future<Source?> _resolvePlayableSource(Track track) async {
    // 1. Archivo local de la computadora
    if (track.isLocal && File(track.audioUrl).existsSync()) {
      return DeviceFileSource(track.audioUrl);
    }

    // 2. Archivo completo en caché local existente
    final cacheDir = _getCacheFolder();
    final safeId = track.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final cachedFile = File('${cacheDir.path}\\$safeId.m4a');

    if (cachedFile.existsSync() && cachedFile.lengthSync() > 100000) {
      _cachedFullAudioPaths[track.id] = cachedFile.path;
      return DeviceFileSource(cachedFile.path);
    }

    if (_cachedFullAudioPaths.containsKey(track.id)) {
      final p = _cachedFullAudioPaths[track.id]!;
      if (File(p).existsSync() && File(p).lengthSync() > 100000) {
        return DeviceFileSource(p);
      }
    }

    // 3. Resolver y descargar la canción completa a la caché local con yt-dlp empaquetado
    try {
      final cachedPath = await _resolveAndCacheFullAudio(track);
      if (cachedPath != null && File(cachedPath).existsSync() && File(cachedPath).lengthSync() > 100000) {
        return DeviceFileSource(cachedPath);
      }
    } catch (e) {
      debugPrint('Error resolviendo audio completo: $e');
    }

    // 4. Último recurso absoluto: Preview de 30s de iTunes (solo si no hay internet o falló todo)
    if (track.previewFallbackUrl != null && track.previewFallbackUrl!.isNotEmpty) {
      debugPrint('Aviso: Reproduciendo preview fallback de 30s como último recurso');
      return UrlSource(track.previewFallbackUrl!);
    }

    return null;
  }

  Future<void> playTrack(Track track, {bool keepQueue = false}) async {
    if (!keepQueue) {
      _updateActiveQueueFromContext();
    }
    _currentTrack = track;
    _position = Duration.zero;
    _duration = track.duration;
    _isBufferingTrack = true;

    // Agregar a reproducidos recientemente
    _recentlyPlayed.removeWhere((t) => t.id == track.id);
    _recentlyPlayed.insert(0, track);
    _savePersistentState();
    notifyListeners();

    fetchSyncedLyrics(track);
    _extractPaletteFromTrack(track);

    try {
      await _audioPlayer.stop();
      final audioSource = await _resolvePlayableSource(track);

      _isBufferingTrack = false;
      notifyListeners();

      if (_currentTrack?.id != track.id) return;

      if (audioSource != null) {
        await _audioPlayer.play(audioSource);
      }
    } catch (e) {
      _isBufferingTrack = false;
      notifyListeners();
      debugPrint("Error reproduciendo: $e");
    }
  }

  void togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else if (_currentTrack != null) {
      await _audioPlayer.resume();
    } else {
      playNext();
    }
  }

  void seek(Duration pos) => _audioPlayer.seek(pos);

  void setVolume(double val) {
    _volume = val;
    _audioPlayer.setVolume(val);
    _savePersistentState();
    notifyListeners();
  }

  bool isFavorite(Track track) => _favoriteTrackIds.contains(track.id);

  void toggleFavorite(Track track) {
    if (_favoriteTrackIds.contains(track.id)) {
      _favoriteTrackIds.remove(track.id);
      _favoriteTracks.removeWhere((t) => t.id == track.id);
    } else {
      _favoriteTrackIds.add(track.id);
      _favoriteTracks.insert(0, track);
    }
    _savePersistentState();
    notifyListeners();
  }

  Future<void> _extractPaletteFromTrack(Track track) async {
    try {
      ImageProvider? imgProvider;
      if (track.isLocal && File(track.audioUrl).existsSync()) {
        imgProvider = null;
      } else if (track.artworkUrl != null && track.artworkUrl!.isNotEmpty) {
        imgProvider = NetworkImage(track.artworkUrl!);
      }

      if (imgProvider != null) {
        final palette = await PaletteGenerator.fromImageProvider(
          imgProvider,
          maximumColorCount: 16,
          timeout: const Duration(seconds: 4),
        );

        final dominant = palette.dominantColor?.color ??
            palette.vibrantColor?.color ??
            palette.darkVibrantColor?.color ??
            const Color(0xFF1E3A2F);

        // Crear versión oscurecida profunda para el degradado estilo Spotify / Jellify
        final hsl = HSLColor.fromColor(dominant);
        final color1 = hsl.withLightness((hsl.lightness * 0.45).clamp(0.12, 0.35)).toColor();
        final color2 = hsl.withLightness((hsl.lightness * 0.20).clamp(0.05, 0.18)).toColor();

        _lyricsPrimaryColor = color1;
        _lyricsSecondaryColor = color2;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint("Error extrayendo paleta de colores: $e");
    }

    _lyricsPrimaryColor = const Color(0xFF1E3A2F);
    _lyricsSecondaryColor = const Color(0xFF101914);
    notifyListeners();
  }

  // --- ALGORITMO DE RECOMENDACIONES DIARIAS Y BASADAS EN TUS GUSTOS ---
  Future<void> fetchDailyPopularTracks() async {
    _isLoadingPopular = true;
    notifyListeners();

    try {
      // 1. Obtener Top Songs de iTunes RSS Feed
      final rssUrl = Uri.parse('https://itunes.apple.com/us/rss/topsongs/limit=16/json');
      final res = await http.get(rssUrl).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List entries = data['feed']?['entry'] ?? [];
        _popularTracks.clear();
        for (var e in entries) {
          final title = e['im:name']?['label'] ?? 'Top Song';
          final artist = e['im:artist']?['label'] ?? 'Artista';
          final album = e['im:collection']?['im:name']?['label'] ?? 'Top Hits';
          String? image = e['im:image'] is List && (e['im:image'] as List).isNotEmpty
              ? (e['im:image'] as List).last['label']
              : null;
          if (image != null) {
            image = image.replaceAll('170x170bb.png', '600x600bb.jpg');
          }
          final id = e['id']?['attributes']?['im:id'] ?? 'pop_${DateTime.now().microsecondsSinceEpoch}';
          String? previewUrl;
          if (e['link'] is List && (e['link'] as List).length > 1) {
            final attrs = (e['link'] as List)[1]['attributes'];
            if (attrs is Map) previewUrl = attrs['href']?.toString();
          }

          _popularTracks.add(
            Track(
              id: 'rss_$id',
              title: title,
              artist: artist,
              album: album,
              artworkUrl: image,
              audioUrl: '',
              previewFallbackUrl: previewUrl,
              isLocal: false,
              duration: const Duration(minutes: 3, seconds: 20),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error cargando canciones populares del día: $e");
    }

    if (_popularTracks.isEmpty) {
      // Fallback con éxitos pop globales si la red falla
      await _fetchFallbackPopular();
    }

    _isLoadingPopular = false;
    notifyListeners();
  }

  Future<void> _fetchFallbackPopular() async {
    try {
      final url = Uri.parse('https://itunes.apple.com/search?term=Top+Hits+2026&media=music&entity=song&limit=15');
      final res = await http.get(url).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List results = data['results'] ?? [];
        for (var item in results) {
          _popularTracks.add(Track.fromCatalogJson(item));
        }
      }
    } catch (_) {}
  }

  Future<void> fetchRecommendedTracks() async {
    _isLoadingRecommendations = true;
    notifyListeners();

    try {
      // Identificar artistas de canciones que escuchas o tienes en favoritos / biblioteca
      final Set<String> seedArtists = {};
      for (final t in _favoriteTracks) {
        if (t.artist.isNotEmpty && t.artist != 'Archivo de tu PC') {
          seedArtists.add(t.artist);
        }
      }
      for (final t in _recentlyPlayed) {
        if (t.artist.isNotEmpty && t.artist != 'Archivo de tu PC') {
          seedArtists.add(t.artist);
        }
      }

      String query = 'Trending Hits';
      if (seedArtists.isNotEmpty) {
        final list = seedArtists.toList();
        final randomSeed = list[_random.nextInt(list.length)];
        final cleanSeed = randomSeed.split('&').first.split(',').first.split('feat').first.trim();
        query = cleanSeed;
      }

      final url = Uri.parse('https://itunes.apple.com/search?term=${Uri.encodeComponent(query)}&media=music&entity=song&limit=16');
      final res = await http.get(url).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List results = data['results'] ?? [];
        _recommendedTracks.clear();
        for (var item in results) {
          final t = Track.fromCatalogJson(item);
          // Filtrar duplicados con favoritos
          if (!_favoriteTrackIds.contains(t.id)) {
            _recommendedTracks.add(t);
          }
        }
      }
    } catch (e) {
      debugPrint("Error cargando recomendaciones personalizadas: $e");
    }

    _isLoadingRecommendations = false;
    notifyListeners();
  }

  Future<void> searchOnline(String query) async {
    if (query.trim().isEmpty) return;
    _isSearching = true;
    notifyListeners();

    _onlineSearchResults.clear();

    try {
      final itunesUrl = Uri.parse(
        'https://itunes.apple.com/search?term=${Uri.encodeComponent(query)}&media=music&entity=song&limit=24',
      );
      final itunesRes = await http.get(itunesUrl).timeout(const Duration(seconds: 7));
      if (itunesRes.statusCode == 200) {
        final data = json.decode(itunesRes.body);
        final List results = data['results'] ?? [];
        for (var item in results) {
          _onlineSearchResults.add(Track.fromCatalogJson(item));
        }
      }

      if (_onlineSearchResults.isEmpty) {
        final ytResults = await _yt.search.search(query);
        for (final video in ytResults.take(15)) {
          _onlineSearchResults.add(Track.fromYoutubeVideo(video));
        }
      }
    } catch (e) {
      debugPrint("Error buscando canciones: $e");
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> fetchSyncedLyrics(Track track) async {
    _isLoadingLyrics = true;
    _currentLyrics = [];
    notifyListeners();

    try {
      final cleanTitle = track.title.split('(').first.split('[').first.trim();
      final cleanArtist = track.artist == 'Archivo de tu PC'
          ? ''
          : track.artist.split('&').first.split(',').first.trim();

      final queryParams = cleanArtist.isNotEmpty
          ? 'track_name=${Uri.encodeComponent(cleanTitle)}&artist_name=${Uri.encodeComponent(cleanArtist)}'
          : 'q=${Uri.encodeComponent(cleanTitle)}';

      final url = Uri.parse('https://lrclib.net/api/search?$queryParams');
      final response = await http.get(url).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        if (results.isNotEmpty) {
          Map<String, dynamic>? bestMatch;
          for (final item in results) {
            if (item['syncedLyrics'] != null &&
                item['syncedLyrics'].toString().trim().isNotEmpty) {
              bestMatch = item;
              break;
            }
          }
          bestMatch ??= results.first;

          final String? synced = bestMatch!['syncedLyrics']?.toString();
          final String? plain = bestMatch['plainLyrics']?.toString();

          if (synced != null && synced.isNotEmpty) {
            _currentLyrics = _parseLrc(synced);
          } else if (plain != null && plain.isNotEmpty) {
            _currentLyrics = _generateTimedPlainLyrics(plain, track.duration);
          }
        }
      }
    } catch (e) {
      debugPrint("Error letras: $e");
    }

    if (_currentLyrics.isEmpty) {
      _currentLyrics = [
        LyricLine(timestamp: const Duration(seconds: 0), text: '♪ Reproduciendo: ${track.title} ♪'),
        LyricLine(timestamp: const Duration(seconds: 4), text: 'Artista: ${track.artist}'),
        LyricLine(timestamp: const Duration(seconds: 8), text: '••• Pista de audio completa en alta fidelidad •••'),
        LyricLine(timestamp: const Duration(seconds: 15), text: '♪ Disfruta de la música en CYBERMUSIC ♪'),
      ];
    }

    _isLoadingLyrics = false;
    notifyListeners();
  }

  List<LyricLine> _parseLrc(String lrcContent) {
    final List<LyricLine> lines = [];
    final regExp = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (final rawLine in lrcContent.split('\n')) {
      final match = regExp.firstMatch(rawLine);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final millisStr = match.group(3)!;
        final millis = millisStr.length == 2
            ? int.parse(millisStr) * 10
            : int.parse(millisStr);
        final text = match.group(4)!.trim();
        if (text.isNotEmpty) {
          lines.add(
            LyricLine(
              timestamp: Duration(
                minutes: minutes,
                seconds: seconds,
                milliseconds: millis,
              ),
              text: text,
            ),
          );
        }
      }
    }
    return lines;
  }

  List<LyricLine> _generateTimedPlainLyrics(String plain, Duration totalDuration) {
    final rawLines = plain
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (rawLines.isEmpty) return [];

    final totalSec = totalDuration.inSeconds > 30 ? totalDuration.inSeconds : 180;
    final step = totalSec / (rawLines.length + 1);

    final List<LyricLine> result = [];
    for (int i = 0; i < rawLines.length; i++) {
      result.add(
        LyricLine(
          timestamp: Duration(milliseconds: (i * step * 1000).round()),
          text: rawLines[i],
        ),
      );
    }
    return result;
  }

  int get activeLyricIndex {
    if (_currentLyrics.isEmpty) return -1;
    final adjustedPos = _position + Duration(milliseconds: _lyricOffsetMs);
    int active = 0;
    for (int i = 0; i < _currentLyrics.length; i++) {
      if (adjustedPos >= _currentLyrics[i].timestamp) {
        active = i;
      } else {
        break;
      }
    }
    return active;
  }

  Future<String?> downloadTrackAsMp3(Track track) async {
    if (track.isLocal) return track.audioUrl;
    if (_downloadingTrackIds.contains(track.id)) return null;

    _downloadingTrackIds.add(track.id);
    notifyListeners();

    try {
      final saveDir = _getMusicFolder();
      final ffmpegPath = _findExecutable('ffmpeg.exe');
      final hasFfmpeg = ffmpegPath != null && File(ffmpegPath).existsSync();
      final extension = hasFfmpeg ? 'mp3' : 'm4a';
      final safeTitle = track.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
      final safeArtist = track.artist.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
      final filePath = '${saveDir.path}\\$safeTitle - $safeArtist.$extension';

      final cachedSourcePath = await _resolveAndCacheFullAudio(track);
      if (cachedSourcePath != null && File(cachedSourcePath).existsSync()) {
        if (hasFfmpeg && ffmpegPath != null) {
          await Process.run(
            ffmpegPath,
            [
              '-y',
              '-i',
              cachedSourcePath,
              '-vn',
              '-ab',
              '192k',
              filePath,
            ],
          );
        } else {
          await File(cachedSourcePath).copy(filePath);
        }

        if (File(filePath).existsSync()) {
          final downloadedTrack = Track(
            id: filePath,
            title: track.title,
            artist: track.artist,
            album: hasFfmpeg ? 'Descargado en MP3' : 'Descargado en M4A',
            artworkUrl: track.artworkUrl,
            audioUrl: filePath,
            isLocal: true,
            duration: track.duration,
          );

          _localTracks.removeWhere((t) => t.id == filePath);
          _localTracks.insert(0, downloadedTrack);

          _downloadingTrackIds.remove(track.id);
          notifyListeners();
          return filePath;
        }
      }
    } catch (e) {
      debugPrint("Error descargando MP3: $e");
    }

    _downloadingTrackIds.remove(track.id);
    notifyListeners();
    return null;
  }

  Future<void> pickLocalFolder() async {
    String? selectedDirectory = await FilePicker.getDirectoryPath();
    if (selectedDirectory != null) {
      if (!_savedCustomFolders.contains(selectedDirectory)) {
        _savedCustomFolders.add(selectedDirectory);
        _savePersistentState();
      }
      scanFolder(selectedDirectory, clearPrevious: false, persistFolder: true);
    }
  }

  void scanFolder(String path, {bool clearPrevious = false, bool persistFolder = false}) {
    try {
      final dir = Directory(path);
      if (!dir.existsSync()) return;

      if (clearPrevious) {
        _localTracks.clear();
      }

      for (var file in dir.listSync(recursive: true)) {
        if (file is File) {
          if (file.path.contains('\\.cache\\') || file.path.contains('\\node_modules\\')) {
            continue;
          }

          final ext = file.path.split('.').last.toLowerCase();
          if (['mp3', 'wav', 'flac', 'm4a', 'ogg'].contains(ext)) {
            final fileName = file.uri.pathSegments.last;
            _localTracks.removeWhere((t) => t.id == file.path);
            _localTracks.add(
              Track(
                id: file.path,
                title: fileName.replaceAll('.$ext', ''),
                artist: 'Archivo de tu PC',
                album: 'Música Local',
                audioUrl: file.path,
                isLocal: true,
                duration: const Duration(minutes: 3, seconds: 30),
              ),
            );
          }
        }
      }
      if (persistFolder) {
        _savePersistentState();
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error escaneando carpeta: $e");
    }
  }

  @override
  void dispose() {
    _yt.close();
    _audioPlayer.dispose();
    super.dispose();
  }
}

// ==========================================
// APLICACIÓN PRINCIPAL (RESPONSIVE)
// ==========================================
class LibreSYApp extends StatefulWidget {
  const LibreSYApp({super.key});

  @override
  State<LibreSYApp> createState() => _LibreSYAppState();
}

class _LibreSYAppState extends State<LibreSYApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  bool _isHandlingWindowMinimize = false;

  @override
  void onWindowMinimize() async {
    if (_isHandlingWindowMinimize) return;
    _isHandlingWindowMinimize = true;
    try {
      final provider = Provider.of<LibreSYProvider>(context, listen: false);
      if (provider.minimizeToBubbleEnabled && !provider.isMiniBubbleMode) {
        await windowManager.restore();
        await Future.delayed(const Duration(milliseconds: 80));
        await provider.enterMiniBubbleMode();
      }
    } finally {
      _isHandlingWindowMinimize = false;
    }
  }

  @override
  void onWindowMaximize() {
    final provider = Provider.of<LibreSYProvider>(context, listen: false);
    if (provider.isMiniBubbleMode) {
      provider.exitMiniBubbleMode();
    }
  }

  @override
  void onWindowRestore() {
    final provider = Provider.of<LibreSYProvider>(context, listen: false);
    if (provider.isMiniBubbleMode) {
      provider.exitMiniBubbleMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);

    return MaterialApp(
      title: 'CYBERMUSIC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: provider.isMiniBubbleMode ? Colors.transparent : SpotifyTheme.background,
        colorScheme: ColorScheme.dark(
          primary: SpotifyTheme.primary,
          surface: SpotifyTheme.card,
        ),
      ),
      home: provider.isMiniBubbleMode
          ? const _MiniBubblePlayerView()
          : const MainLayoutScreen(),
    );
  }
}

// ==========================================
// MODO BURBUJA FLOTANTE (MINI PLAYER ALWAYS ON TOP)
// Arrastrable por el escritorio, sin bordes toscos, con aurora neón y controles en el disco
// ==========================================
class _MiniBubblePlayerView extends StatefulWidget {
  const _MiniBubblePlayerView();

  @override
  State<_MiniBubblePlayerView> createState() => _MiniBubblePlayerViewState();
}

class _MiniBubblePlayerViewState extends State<_MiniBubblePlayerView> with TickerProviderStateMixin {
  late AnimationController _vinylController;
  late AnimationController _auroraController;
  int _manualStyleOffset = 0;

  @override
  void initState() {
    super.initState();
    // Giro lento y elegante del vinilo (28 segundos por rotación)
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    );
    // Respiración pausada y fluida de la aurora (8 segundos por ciclo)
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _vinylController.dispose();
    _auroraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final track = provider.currentTrack;
    final isPlaying = provider.isPlaying;

    if (isPlaying) {
      if (!_vinylController.isAnimating) {
        _vinylController.repeat();
      }
    } else {
      if (_vinylController.isAnimating) {
        _vinylController.stop();
      }
    }

    // Selección de estilo de aurora y paleta multicolor viva
    final songStyle = (track != null ? track.id.hashCode : 0).abs();
    final currentAuroraStyle = (songStyle + _manualStyleOffset) % kAuroraPalettes.length;
    final activePalette = kAuroraPalettes[currentAuroraStyle];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              provider.exitMiniBubbleMode();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              provider.togglePlayPause();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              provider.playNext();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              provider.playPrevious();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Center(
          child: SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Efecto de Aurora Neón Circular Multicolor (6 estilos vivos de la imagen)
                AnimatedBuilder(
                  animation: _auroraController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(250, 250),
                      painter: _CircularAuroraPainter(
                        tick: _auroraController.value * 2 * pi,
                        isPlaying: isPlaying,
                        palette: activePalette,
                        radius: 74,
                        style: currentAuroraStyle,
                      ),
                    );
                  },
                ),

                // 2. Disco Vinilo con Carátula (Arrastrable con DragToMoveArea y doble clic para restaurar)
                DragToMoveArea(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onDoubleTap: () => provider.exitMiniBubbleMode(),
                    child: RotationTransition(
                      turns: _vinylController,
                      child: Container(
                        width: 148,
                        height: 148,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: activePalette.primary.withValues(alpha: 0.65),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: track != null && track.artworkUrl != null && track.artworkUrl!.isNotEmpty
                              ? (track.artworkUrl!.startsWith('http')
                                  ? Image.network(
                                      track.artworkUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildVinylFallback(),
                                    )
                                  : (File(track.artworkUrl!).existsSync()
                                      ? Image.file(
                                          File(track.artworkUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : _buildVinylFallback()))
                              : _buildVinylFallback(),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Capa de cristal translúcida interior con degradado oscuro (IgnorePointer para no interferir)
                IgnorePointer(
                  child: ClipOval(
                    child: Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.black.withValues(alpha: 0.65),
                            Colors.black.withValues(alpha: 0.90),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Botones de Control de Ventana (Restaurar, Selector de Estilo y Cerrar)
                // Botón Restaurar ventana: Icono claro con borde neón
                Positioned(
                  top: 52,
                  left: 56,
                  child: Tooltip(
                    message: 'Maximizar / Restaurar ventana (Esc o Doble clic)',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => provider.exitMiniBubbleMode(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.88),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00E5FF), width: 1.3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.75),
                                blurRadius: 5,
                              ),
                              const BoxShadow(
                                color: Color(0x6600E5FF),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.open_in_full_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

                // Botón central: Cambiador de estilo de aurora (1-6)
                Positioned(
                  top: 52,
                  child: Tooltip(
                    message: 'Estilo de Aurora: ${activePalette.name} (Clic para cambiar)',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _manualStyleOffset++;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: activePalette.primary.withValues(alpha: 0.8),
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.7),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 10, color: activePalette.primary),
                              const SizedBox(width: 3),
                              Text(
                                '${currentAuroraStyle + 1}/6',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Botón Cerrar ventana
                Positioned(
                  top: 52,
                  right: 56,
                  child: Tooltip(
                    message: 'Cerrar CYBERMUSIC',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => windowManager.close(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.shade700,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white38, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.75),
                                blurRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.redAccent.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

                // 5. Centro del vinilo con núcleo neón de color activo
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: activePalette.primary, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: activePalette.primary.withValues(alpha: 0.65),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 6. Título de la canción en cápsula oscura de alto contraste (visible en fondos blancos y oscuros)
                Positioned(
                  bottom: 47,
                  left: 36,
                  right: 36,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: activePalette.primary.withValues(alpha: 0.55),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.85),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          track != null ? track.title : 'CYBERMUSIC',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                // 7. Botones de Control ⏮️ ⏯️ ⏭️ en cápsulas de alto contraste para máxima visibilidad
                Positioned(
                  bottom: 12,
                  left: 48,
                  right: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Retroceder canción en cápsula oscura de vidrio
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: provider.playPrevious,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.90),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.40),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.skip_previous_rounded,
                              size: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Pausar / Reproducir con halo neón multicolor
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: provider.togglePlayPause,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [activePalette.primary, activePalette.secondary],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activePalette.primary.withValues(alpha: isPlaying ? 0.85 : 0.45),
                                  blurRadius: 10,
                                  spreadRadius: 1.5,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 19,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      // Siguiente canción en cápsula oscura de vidrio
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: provider.playNext,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.90),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.40),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.skip_next_rounded,
                              size: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVinylFallback() {
    return Container(
      color: const Color(0xFF181818),
      child: Center(
        child: Icon(Icons.music_note, size: 36, color: SpotifyTheme.primary),
      ),
    );
  }
}

// ==========================================
// PALETAS MULTICOLOR VIBRANTES PARA LA AURORA
// Inspiradas directamente en las ondas y ecualizadores de alta saturación
// ==========================================
class AuroraPalette {
  final String name;
  final List<Color> colors;
  final Color primary;
  final Color secondary;

  const AuroraPalette({
    required this.name,
    required this.colors,
    required this.primary,
    required this.secondary,
  });
}

Color _evalMultiColor(List<Color> colors, double t) {
  if (colors.isEmpty) return const Color(0xFF00E5FF);
  if (colors.length == 1) return colors.first;
  final clampedT = (t % 1.0 + 1.0) % 1.0;
  final scaled = clampedT * (colors.length - 1);
  final index = scaled.floor();
  final remainder = scaled - index;
  final nextIndex = (index + 1) % colors.length;
  return Color.lerp(colors[index], colors[nextIndex], remainder) ?? colors[index];
}

const List<AuroraPalette> kAuroraPalettes = [
  // 0. Espectro Arcoíris Neón (Multicolor completo)
  AuroraPalette(
    name: 'Rainbow Neon',
    primary: Color(0xFFFF007F),
    secondary: Color(0xFF00E5FF),
    colors: [
      Color(0xFFFF007F), // Magenta Eléctrico
      Color(0xFFFF5500), // Naranja Neón
      Color(0xFFFFD000), // Oro Solar
      Color(0xFF00FF88), // Verde Esmeralda
      Color(0xFF00E5FF), // Cyan Eléctrico
      Color(0xFF7000FF), // Violeta Brillante
      Color(0xFFFF007F), // Cierre cíclico 360°
    ],
  ),

  // 1. Cintas Armónicas Multicolor (Ondas fluidas cyan-amarillo-fucsia)
  AuroraPalette(
    name: 'Harmonic Flow',
    primary: Color(0xFF00E5FF),
    secondary: Color(0xFFFF00C8),
    colors: [
      Color(0xFF00E5FF), // Cyan
      Color(0xFF0088FF), // Azul Eléctrico
      Color(0xFFFF00C8), // Magenta
      Color(0xFFFF8800), // Naranja
      Color(0xFFFFEE00), // Amarillo Solar
      Color(0xFF00E5FF),
    ],
  ),

  // 2. Bloques Segmentados Cyan & Toxic Lime (Ecualizador digital)
  AuroraPalette(
    name: 'Cyber Matrix',
    primary: Color(0xFF00FF88),
    secondary: Color(0xFF00E5FF),
    colors: [
      Color(0xFF00E5FF), // Cyan
      Color(0xFF00FF88), // Verde Neón
      Color(0xFF76FF03), // Lima Eléctrica
      Color(0xFF00FFFF), // Turquesa
      Color(0xFF00E5FF),
    ],
  ),

  // 3. Vórtice Galáctico Deep Azure & Violet
  AuroraPalette(
    name: 'Cosmic Vortex',
    primary: Color(0xFF0055FF),
    secondary: Color(0xFFA855F7),
    colors: [
      Color(0xFF0055FF), // Azul Profundo
      Color(0xFF00E5FF), // Cyan
      Color(0xFFA855F7), // Púrpura Eléctrico
      Color(0xFFFF0080), // Rosa Neón
      Color(0xFF0055FF),
    ],
  ),

  // 4. Constelación de Puntos Synthwave
  AuroraPalette(
    name: 'Synthwave Dots',
    primary: Color(0xFFFF00AA),
    secondary: Color(0xFF00FFCC),
    colors: [
      Color(0xFFFF00AA), // Rosa Synth
      Color(0xFF00FFCC), // Menta Neón
      Color(0xFFFFD600), // Amarillo Neón
      Color(0xFF7000FF), // Violeta
      Color(0xFFFF00AA),
    ],
  ),

  // 5. Corona Solar & Bicolor de Alta Frecuencia
  AuroraPalette(
    name: 'Solar Flare',
    primary: Color(0xFFFF1744),
    secondary: Color(0xFFFF9100),
    colors: [
      Color(0xFFFF1744), // Rojo Fuego
      Color(0xFFFF5252), // Coral
      Color(0xFFFF9100), // Naranja Oro
      Color(0xFFFFD600), // Amarillo Fuego
      Color(0xFFFF1744),
    ],
  ),
];

class _CircularAuroraPainter extends CustomPainter {
  final double tick;
  final bool isPlaying;
  final AuroraPalette palette;
  final double radius;
  final int style; // 0 a 5 recreando cada estilo de las referencias

  _CircularAuroraPainter({
    required this.tick,
    required this.isPlaying,
    required this.palette,
    required this.radius,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 0. Sombra suave de contraste detrás de la aurora para que resalte intensamente sobre fondos blancos
    final backingPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center, radius + 22, backingPaint);

    // 1. Anillo Neón Central Multicolor brillante
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..shader = ui.Gradient.sweep(
        center,
        palette.colors,
        List.generate(palette.colors.length, (i) => i / (palette.colors.length - 1)),
      );
    canvas.drawCircle(center, radius, ringPaint);

    // Resplandor difuso del anillo
    final glowRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..shader = ui.Gradient.sweep(
        center,
        palette.colors.map((c) => c.withValues(alpha: isPlaying ? 0.45 : 0.25)).toList(),
        List.generate(palette.colors.length, (i) => i / (palette.colors.length - 1)),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius, glowRingPaint);

    switch (style % 6) {
      case 0:
        _paintClassicRays(canvas, center);
        break;
      case 1:
        _paintConcentricRibbons(canvas, center);
        break;
      case 2:
        _paintSegmentedBars(canvas, center);
        break;
      case 3:
        _paintVortexSpikes(canvas, center);
        break;
      case 4:
        _paintDottedOrbital(canvas, center);
        break;
      case 5:
        _paintDualToneCorona(canvas, center);
        break;
      default:
        _paintClassicRays(canvas, center);
    }
  }

  // Estilo 0: Rayos Solares Neón Multicolor con Partículas (Imagen 2 de referencia)
  void _paintClassicRays(Canvas canvas, Offset center) {
    const int barCount = 76;
    for (int i = 0; i < barCount; i++) {
      final t = i / barCount;
      final angle = i * (2 * pi / barCount);
      final cosA = cos(angle);
      final sinA = sin(angle);

      // Movimiento suave y fluido
      final freq = sin(i * 0.35 + tick * 1.5) * 0.5 + 0.5;
      final harmonic = cos(i * 0.7 - tick * 1.0) * 0.5 + 0.5;
      final combined = (freq * 0.65 + harmonic * 0.35);

      final rayLength = isPlaying ? (6.0 + combined * 26.0) : (4.0 + sin(i * 0.2 + tick) * 2.5);

      final startPos = center + Offset(cosA * (radius + 2), sinA * (radius + 2));
      final endPos = center + Offset(cosA * (radius + 2 + rayLength), sinA * (radius + 2 + rayLength));

      final barColor = _evalMultiColor(palette.colors, t);

      final rayPaint = Paint()
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          startPos,
          endPos,
          [barColor.withValues(alpha: 1.0), barColor.withValues(alpha: 0.30)],
        );

      canvas.drawLine(startPos, endPos, rayPaint);

      // Partículas flotantes suaves
      if (i % 2 == 0) {
        final particleDist = radius + rayLength + 4.5 + (sin(tick * 1.5 + i) * 2.5);
        final particlePos = center + Offset(cosA * particleDist, sinA * particleDist);
        final particleAlpha = (combined * 0.7 + 0.3).clamp(0.3, 0.95);

        canvas.drawCircle(
          particlePos,
          1.5,
          Paint()..color = barColor.withValues(alpha: particleAlpha),
        );
      }
    }
  }

  // Estilo 1: Cintas Armónicas Onduladas Multicolor (Imagen 2 - Ribbon Waves)
  void _paintConcentricRibbons(Canvas canvas, Offset center) {
    const int ribbonCount = 3;
    for (int r = 0; r < ribbonCount; r++) {
      final path = Path();
      const int steps = 90;
      final ribbonOffset = r * 8.0;
      final phase = tick * (0.8 + r * 0.3) + r * 1.2;

      for (int i = 0; i <= steps; i++) {
        final angle = i * (2 * pi / steps);
        final wave = sin(angle * 5 + phase) * cos(angle * 3 - phase * 0.6);
        final d = radius + 6.0 + ribbonOffset + (isPlaying ? (wave * 12.0) : (wave * 4.0));
        final pt = center + Offset(cos(angle) * d, sin(angle) * d);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();

      final ribbonColor = _evalMultiColor(palette.colors, r / ribbonCount);
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = ribbonColor.withValues(alpha: (0.90 - r * 0.15).clamp(0.4, 0.95))
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.0);
      canvas.drawPath(path, p);
    }
  }

  // Estilo 2: Ecualizador de Bloques / Segmentos Radiales (Imagen 2 - Segmented Dots)
  void _paintSegmentedBars(Canvas canvas, Offset center) {
    const int barCount = 44;
    const int segments = 5;

    for (int i = 0; i < barCount; i++) {
      final t = i / barCount;
      final angle = i * (2 * pi / barCount);
      final cosA = cos(angle);
      final sinA = sin(angle);

      final energy = isPlaying
          ? ((sin(i * 0.45 + tick * 1.8) * 0.5 + 0.5) * segments).ceil()
          : 2;

      for (int s = 0; s < segments; s++) {
        final dist = radius + 5.0 + (s * 5.2);
        final pt = center + Offset(cosA * dist, sinA * dist);
        final isActive = s < energy;

        final color = _evalMultiColor(palette.colors, (t + (s / segments) * 0.3) % 1.0);
        final alpha = isActive ? 1.0 : 0.22;

        canvas.drawCircle(
          pt,
          1.8,
          Paint()..color = color.withValues(alpha: alpha),
        );
      }
    }
  }

  // Estilo 3: Vórtice Curvado / Spiral Starburst (Imagen 2 - Vortex Spikes)
  void _paintVortexSpikes(Canvas canvas, Offset center) {
    const int barCount = 64;
    for (int i = 0; i < barCount; i++) {
      final t = i / barCount;
      final baseAngle = i * (2 * pi / barCount);
      final freq = sin(i * 0.3 + tick * 1.4) * 0.5 + 0.5;
      final rayLength = isPlaying ? (6.0 + freq * 24.0) : 5.0;

      final startPos = center + Offset(cos(baseAngle) * (radius + 2), sin(baseAngle) * (radius + 2));
      final curveAngle = baseAngle + 0.22 + (freq * 0.08);
      final endPos = center + Offset(cos(curveAngle) * (radius + 2 + rayLength), sin(curveAngle) * (radius + 2 + rayLength));

      final barColor = _evalMultiColor(palette.colors, t);
      final paint = Paint()
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          startPos,
          endPos,
          [barColor.withValues(alpha: 1.0), barColor.withValues(alpha: 0.25)],
        );
      canvas.drawLine(startPos, endPos, paint);
    }
  }

  // Estilo 4: Constelación de Micro-Puntos en Órbita (Imagen 2 - Dotted Orbital)
  void _paintDottedOrbital(Canvas canvas, Offset center) {
    const int dotCount = 80;
    final phase = tick * 1.2;

    for (int i = 0; i < dotCount; i++) {
      final t = i / dotCount;
      final angle = i * (2 * pi / dotCount);
      final wave1 = sin(angle * 4 + phase);
      final wave2 = cos(angle * 2 - phase * 0.7);
      final d = radius + 6.0 + (isPlaying ? (wave1 * 10.0 + wave2 * 6.0 + 8.0) : 7.0);

      final pt = center + Offset(cos(angle) * d, sin(angle) * d);
      final color = _evalMultiColor(palette.colors, (t + phase * 0.1) % 1.0);

      canvas.drawCircle(
        pt,
        2.0,
        Paint()..color = color.withValues(alpha: 0.95),
      );
    }
  }

  // Estilo 5: Corona de Espigas Bicolor (Imagen 2 - Dual-Tone Corona)
  void _paintDualToneCorona(Canvas canvas, Offset center) {
    const int barCount = 90;
    for (int i = 0; i < barCount; i++) {
      final t = i / barCount;
      final angle = i * (2 * pi / barCount);
      final isEven = i % 2 == 0;
      final freq = sin(i * 0.5 + tick * 1.6) * 0.5 + 0.5;

      final baseLen = isEven ? 16.0 : 7.0;
      final rayLength = isPlaying ? (baseLen + freq * 18.0) : baseLen;

      final startPos = center + Offset(cos(angle) * (radius + 2), sin(angle) * (radius + 2));
      final endPos = center + Offset(cos(angle) * (radius + 2 + rayLength), sin(angle) * (radius + 2 + rayLength));

      final color = isEven ? _evalMultiColor(palette.colors, t) : palette.secondary;
      final paint = Paint()
        ..strokeWidth = isEven ? 2.0 : 1.4
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          startPos,
          endPos,
          [color.withValues(alpha: 1.0), color.withValues(alpha: 0.25)],
        );

      canvas.drawLine(startPos, endPos, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularAuroraPainter oldDelegate) => true;
}

// ==========================================
// BARRA SUPERIOR DE VENTANA PERSONALIZADA (DARK SEAMLESS)
// Reemplaza la barra blanca de Windows para unificar la estética
// ==========================================
class _CustomAppTitleBar extends StatefulWidget {
  const _CustomAppTitleBar();

  @override
  State<_CustomAppTitleBar> createState() => _CustomAppTitleBarState();
}

class _CustomAppTitleBarState extends State<_CustomAppTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkMaximizedState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _checkMaximizedState() async {
    final max = await windowManager.isMaximized();
    if (mounted) setState(() => _isMaximized = max);
  }

  @override
  void onWindowMaximize() {
    if (mounted) setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    if (mounted) setState(() => _isMaximized = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: SpotifyTheme.background.withValues(alpha: 0.35),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo & Título de la app a la izquierda
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () async {
              if (await windowManager.isMaximized()) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 14),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF00FFA3), SpotifyTheme.primary],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: SpotifyTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.graphic_eq, color: Colors.black, size: 13),
                ),
                const SizedBox(width: 8),
                Text(
                  'CYBERMUSIC',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ),

          // Área arrastrable central para mover la ventana
          Expanded(
            child: DragToMoveArea(
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                child: provider.currentTrack != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            provider.isPlaying ? Icons.play_arrow : Icons.pause,
                            color: SpotifyTheme.primary.withValues(alpha: 0.6),
                            size: 13,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${provider.currentTrack!.artist} — ${provider.currentTrack!.title}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.expand(),
              ),
            ),
          ),

          // Botones de control de ventana de Windows integrados estéticamente
          _WindowActionButton(
            icon: const Icon(Icons.remove, size: 15, color: Colors.white70),
            tooltip: 'Minimizar',
            onTap: () {
              final provider = Provider.of<LibreSYProvider>(context, listen: false);
              if (provider.minimizeToBubbleEnabled) {
                provider.enterMiniBubbleMode();
              } else {
                windowManager.minimize();
              }
            },
          ),
          _WindowActionButton(
            icon: Icon(
              _isMaximized ? Icons.filter_none : Icons.crop_square,
              size: _isMaximized ? 12 : 14,
              color: Colors.white70,
            ),
            tooltip: _isMaximized ? 'Restaurar' : 'Maximizar',
            onTap: () async {
              if (await windowManager.isMaximized()) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
          ),
          _WindowActionButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.white70),
            tooltip: 'Cerrar',
            isClose: true,
            onTap: () => windowManager.close(),
          ),
        ],
      ),
    );
  }
}

class _WindowActionButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isClose;

  const _WindowActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.isClose = false,
  });

  @override
  State<_WindowActionButton> createState() => _WindowActionButtonState();
}

class _WindowActionButtonState extends State<_WindowActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 44,
            height: 38,
            color: _hovered
                ? (widget.isClose ? const Color(0xFFE81123) : Colors.white.withValues(alpha: 0.12))
                : Colors.transparent,
            alignment: Alignment.center,
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Fondo dinámico interactivo (Live Video / Mar de estrellas + Cometas fluidos)
          Positioned.fill(
            child: _DynamicLiveBackground(provider: provider),
          ),

          // 2. Estructura y Disposición (Layout) principal Glassmorphism
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompactWindow = constraints.maxWidth < 920;

                return Column(
                  children: [
                    const _CustomAppTitleBar(),
                    Expanded(
                      child: Row(
                        children: [
                          // Barra Lateral Izquierda (Sidebar Glass)
                          _SidebarWidget(isCompact: isCompactWindow),

                          // Panel Central Dinámico
                          Expanded(
                            child: IndexedStack(
                              index: provider.currentTab,
                              children: const [
                                _HomeView(),
                                _SearchView(),
                                _LibraryView(),
                                _FavoritesView(),
                                _LyricsSyncedView(),
                                _ProfileView(),
                                _ArtistProfileView(),
                              ],
                            ),
                          ),

                          // Panel Derecho de Reproducción (Right Sidebar)
                          if (provider.isRightSidebarOpen && !isCompactWindow)
                            const _RightNowPlayingSidebar(),
                        ],
                      ),
                    ),

                    // Barra Inferior de Controles Glass
                    const _BottomPlayerBar(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// FONDO DINÁMICO INTERACTIVO: MAR DE ESTRELLAS,
// LLUVIA DE COMETAS Y MOTOR DE VIDEO DE FONDO
// ==========================================
class _DynamicLiveBackground extends StatelessWidget {
  final LibreSYProvider provider;

  const _DynamicLiveBackground({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isCustomVideo = provider.backgroundMode == 'custom_video' &&
        provider.videoController != null &&
        provider.videoController!.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Capa base: Video en bucle O Mar de Estrellas en el espacio profundo
        if (isCustomVideo)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: provider.videoController!.value.size.width,
                height: provider.videoController!.value.size.height,
                child: VideoPlayer(provider.videoController!),
              ),
            ),
          )
        else
          _DeepSpaceCanvas(
            mode: provider.backgroundMode,
            bgReactivity: provider.bgReactivity,
            isPlaying: provider.isPlaying,
            primaryColor: provider.lyricsPrimaryColor,
            secondaryColor: provider.lyricsSecondaryColor,
          ),

        // 2. Capa activa: Lluvia fluida de cometas y estrellas fugaces a 60 FPS
        if (provider.isCometShowerEnabled)
          const Positioned.fill(
            child: _CometShowerWidget(),
          ),

        // 3. Aura ambiental reactiva a la música
        if (provider.isDynamicBgEnabled && provider.currentTrack != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.55, -0.45),
                    radius: 1.3,
                    colors: [
                      provider.lyricsPrimaryColor.withValues(
                        alpha: provider.bgReactivity ? 0.35 : 0.22,
                      ),
                      provider.lyricsSecondaryColor.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 4. Desenfoque (Blur) global ajustable del fondo
        if (provider.blurAmount > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: provider.blurAmount * 0.4,
                  sigmaY: provider.blurAmount * 0.4,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
      ],
    );
  }
}

class _DeepSpaceCanvas extends StatefulWidget {
  final String mode;
  final bool bgReactivity;
  final bool isPlaying;
  final Color primaryColor;
  final Color secondaryColor;

  const _DeepSpaceCanvas({
    required this.mode,
    required this.bgReactivity,
    required this.isPlaying,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<_DeepSpaceCanvas> createState() => _DeepSpaceCanvasState();
}

class _DeepSpaceCanvasState extends State<_DeepSpaceCanvas> with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  final List<_Star> _stars = [];
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 160; i++) {
      final depth = _random.nextDouble();
      _stars.add(_Star(
        u: _random.nextDouble(),
        v: _random.nextDouble(),
        radius: depth < 0.65 ? 0.75 + _random.nextDouble() * 0.8 : 1.6 + _random.nextDouble() * 1.4,
        baseAlpha: 0.35 + _random.nextDouble() * 0.55,
        twinkleSpeed: 1.2 + _random.nextDouble() * 2.8,
        twinkleOffset: _random.nextDouble() * 2 * pi,
        color: depth > 0.8
            ? (i % 3 == 0 ? const Color(0xFF80D8FF) : (i % 3 == 1 ? const Color(0xFFD1C4E9) : Colors.white))
            : Colors.white,
      ));
    }

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _DeepSpacePainter(
            stars: _stars,
            tick: _ticker.value * 2 * pi,
            mode: widget.mode,
            bgReactivity: widget.bgReactivity,
            isPlaying: widget.isPlaying,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
        );
      },
    );
  }
}

class _Star {
  final double u;
  final double v;
  final double radius;
  final double baseAlpha;
  final double twinkleSpeed;
  final double twinkleOffset;
  final Color color;

  _Star({
    required this.u,
    required this.v,
    required this.radius,
    required this.baseAlpha,
    required this.twinkleSpeed,
    required this.twinkleOffset,
    required this.color,
  });
}

class _DeepSpacePainter extends CustomPainter {
  final List<_Star> stars;
  final double tick;
  final String mode;
  final bool bgReactivity;
  final bool isPlaying;
  final Color primaryColor;
  final Color secondaryColor;

  _DeepSpacePainter({
    required this.stars,
    required this.tick,
    required this.mode,
    required this.bgReactivity,
    required this.isPlaying,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    List<Color> baseGradient;
    Alignment centerAlign;
    if (mode == 'nebula') {
      baseGradient = [
        const Color(0xFF240046),
        const Color(0xFF10002B),
        const Color(0xFF05010B),
      ];
      centerAlign = const Alignment(-0.3, -0.4);
    } else if (mode == 'cyberpunk') {
      baseGradient = [
        const Color(0xFF002B49),
        const Color(0xFF0F051D),
        const Color(0xFF030008),
      ];
      centerAlign = const Alignment(0.4, 0.3);
    } else if (mode == 'aurora') {
      baseGradient = [
        const Color(0xFF003822),
        const Color(0xFF021B14),
        const Color(0xFF010806),
      ];
      centerAlign = const Alignment(0.0, -0.6);
    } else {
      // 'space' - Mar de estrellas profundo clásico
      baseGradient = [
        const Color(0xFF0D1B2A),
        const Color(0xFF070E17),
        const Color(0xFF030508),
      ];
      centerAlign = const Alignment(-0.4, -0.3);
    }

    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: centerAlign,
        radius: 1.4,
        colors: baseGradient,
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final pulse = bgReactivity && isPlaying ? (sin(tick * 2) * 0.08) : 0.0;
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.65, 0.45),
        radius: 1.1,
        colors: [
          (mode == 'nebula'
                  ? const Color(0xFF7B2CBF)
                  : mode == 'aurora'
                      ? const Color(0xFF00FF87)
                      : mode == 'cyberpunk'
                          ? const Color(0xFFFF007F)
                          : const Color(0xFF1E3A8A))
              .withValues(alpha: (0.16 + pulse).clamp(0.05, 0.35)),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, nebulaPaint);

    for (final star in stars) {
      final starPos = Offset(star.u * size.width, star.v * size.height);
      final alpha = (star.baseAlpha + 0.35 * sin(tick * star.twinkleSpeed + star.twinkleOffset)).clamp(0.12, 1.0);

      if (star.radius > 1.6) {
        canvas.drawCircle(
          starPos,
          star.radius * 2.2,
          Paint()
            ..color = star.color.withValues(alpha: alpha * 0.28)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
        );
      }

      canvas.drawCircle(
        starPos,
        star.radius,
        Paint()..color = star.color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DeepSpacePainter oldDelegate) => true;
}

class _CometShowerWidget extends StatefulWidget {
  const _CometShowerWidget();

  @override
  State<_CometShowerWidget> createState() => _CometShowerWidgetState();
}

class _CometShowerWidgetState extends State<_CometShowerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  final List<_CometItem> _comets = [];
  final Random _random = Random();
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      _comets.add(_CometItem());
    }

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _ticker.addListener(_updateComets);
  }

  void _updateComets() {
    if (_lastSize.width <= 0) return;
    for (final comet in _comets) {
      comet.update(_lastSize, _random);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.removeListener(_updateComets);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _lastSize = Size(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          size: Size.infinite,
          painter: _CometShowerPainter(comets: _comets),
        );
      },
    );
  }
}

class _CometItem {
  double x = -999;
  double y = -999;
  double length = 180;
  double speed = 6.0;
  double angle = 2.35;
  double headRadius = 2.5;
  double tailWidth = 2.0;
  Color color = const Color(0xFF00E5FF);
  double opacity = 0.85;
  bool isInitialized = false;
  int delayTicks = 0;

  void update(Size size, Random random) {
    if (delayTicks > 0) {
      delayTicks--;
      return;
    }

    if (!isInitialized) {
      _spawn(size, random);
      isInitialized = true;
      return;
    }

    x += cos(angle) * speed;
    y += sin(angle) * speed;

    if (x < -length - 100 || y > size.height + length + 100) {
      delayTicks = random.nextInt(40) + 10;
      _spawn(size, random);
    }
  }

  void _spawn(Size size, Random random) {
    if (random.nextBool()) {
      x = random.nextDouble() * (size.width + 200);
      y = -random.nextDouble() * 60 - 20;
    } else {
      x = size.width + random.nextDouble() * 100 + 20;
      y = random.nextDouble() * (size.height * 0.55);
    }

    angle = 2.25 + (random.nextDouble() * 0.35 - 0.17);
    speed = 4.5 + random.nextDouble() * 5.0;
    length = 130.0 + random.nextDouble() * 150.0;
    headRadius = 2.0 + random.nextDouble() * 1.8;
    tailWidth = 1.6 + random.nextDouble() * 1.5;
    opacity = 0.65 + random.nextDouble() * 0.35;

    final palette = [
      const Color(0xFFFFFFFF),
      const Color(0xFF80D8FF),
      const Color(0xFF00E5FF),
      const Color(0xFFB388FF),
      const Color(0xFF69F0AE),
    ];
    color = palette[random.nextInt(palette.length)];
  }
}

class _CometShowerPainter extends CustomPainter {
  final List<_CometItem> comets;

  _CometShowerPainter({required this.comets});

  @override
  void paint(Canvas canvas, Size size) {
    for (final comet in comets) {
      if (comet.delayTicks > 0 || !comet.isInitialized) continue;

      final head = Offset(comet.x, comet.y);
      final tail = Offset(
        comet.x - cos(comet.angle) * comet.length,
        comet.y - sin(comet.angle) * comet.length,
      );

      final tailPaint = Paint()
        ..shader = ui.Gradient.linear(
          head,
          tail,
          [
            comet.color.withValues(alpha: comet.opacity),
            comet.color.withValues(alpha: comet.opacity * 0.35),
            Colors.transparent,
          ],
          [0.0, 0.45, 1.0],
        )
        ..strokeWidth = comet.tailWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(head, tail, tailPaint);

      canvas.drawCircle(
        head,
        comet.headRadius * 3.2,
        Paint()
          ..color = comet.color.withValues(alpha: comet.opacity * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      canvas.drawCircle(
        head,
        comet.headRadius,
        Paint()..color = Colors.white.withValues(alpha: comet.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CometShowerPainter oldDelegate) => true;
}

// ==========================================
// VISUALIZADOR DE AUDIO EN TIEMPO REAL
// Soporta estilos Normal y Circular, formas Barras y Ondas
// ==========================================
class LiveAudioVisualizer extends StatefulWidget {
  final double height;
  final double width;
  final VisualizerStyle style;
  final VisualizerShape shape;
  final double sensitivity;
  final bool isPlaying;
  final Color primaryColor;
  final Color? secondaryColor;
  final Widget? centerChild;

  const LiveAudioVisualizer({
    super.key,
    this.height = 42,
    this.width = double.infinity,
    this.style = VisualizerStyle.normal,
    this.shape = VisualizerShape.bars,
    this.sensitivity = 1.0,
    required this.isPlaying,
    required this.primaryColor,
    this.secondaryColor,
    this.centerChild,
  });

  @override
  State<LiveAudioVisualizer> createState() => _LiveAudioVisualizerState();
}

class _LiveAudioVisualizerState extends State<LiveAudioVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        if (widget.style == VisualizerStyle.circular) {
          return CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _CircularVisualizerPainter(
              animationValue: _animController.value,
              isPlaying: widget.isPlaying,
              shape: widget.shape,
              sensitivity: widget.sensitivity,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor ?? widget.primaryColor.withValues(alpha: 0.6),
            ),
            child: widget.centerChild != null ? Center(child: widget.centerChild) : null,
          );
        }

        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _NormalVisualizerPainter(
            animationValue: _animController.value,
            isPlaying: widget.isPlaying,
            shape: widget.shape,
            sensitivity: widget.sensitivity,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor ?? widget.primaryColor.withValues(alpha: 0.6),
          ),
        );
      },
    );
  }
}

class _NormalVisualizerPainter extends CustomPainter {
  final double animationValue;
  final bool isPlaying;
  final VisualizerShape shape;
  final double sensitivity;
  final Color primaryColor;
  final Color secondaryColor;

  _NormalVisualizerPainter({
    required this.animationValue,
    required this.isPlaying,
    required this.shape,
    required this.sensitivity,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (shape == VisualizerShape.bars) {
      const int barCount = 36;
      final totalSpacing = size.width * 0.28;
      final barWidth = ((size.width - totalSpacing) / barCount).clamp(2.5, 12.0);
      final gap = (size.width - (barCount * barWidth)) / (barCount - 1);

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [primaryColor, secondaryColor],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final t = animationValue * 2 * pi;

      for (int i = 0; i < barCount; i++) {
        double factor = 0.08;
        if (isPlaying) {
          final s1 = sin(i * 0.42 + t * 2.6);
          final c1 = cos(i * 0.24 - t * 3.1);
          final s2 = sin((i + 4) * 0.6 + t * 1.8);
          factor = ((s1 * 0.32 + c1 * 0.26 + s2 * 0.22 + 0.52) * sensitivity).clamp(0.08, 1.0);
        }
        final barHeight = (size.height * factor).clamp(3.5, size.height);
        final x = i * (barWidth + gap);
        final y = size.height - barHeight;

        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          Radius.circular(barWidth / 2),
        );
        canvas.drawRRect(rrect, paint);
      }
    } else {
      // Wave shape
      final wavePath = Path();
      final fillPath = Path();
      fillPath.moveTo(0, size.height);
      wavePath.moveTo(0, size.height * 0.7);

      final t = animationValue * 2 * pi;
      final step = (size.width / 40).clamp(2.0, 10.0);

      for (double x = 0; x <= size.width; x += step) {
        final normX = x / size.width;
        double waveY = size.height * 0.7;
        if (isPlaying) {
          final w1 = sin(normX * 10 + t * 2.2);
          final w2 = sin(normX * 6 - t * 1.5);
          final w3 = cos(normX * 16 + t * 2.8);
          final val = (w1 * 0.45 + w2 * 0.35 + w3 * 0.20) * sensitivity;
          waveY = size.height * 0.5 - (val * (size.height * 0.42));
        }
        final clampedY = waveY.clamp(2.0, size.height - 2.0);
        if (x == 0) {
          wavePath.moveTo(x, clampedY);
          fillPath.lineTo(x, clampedY);
        } else {
          wavePath.lineTo(x, clampedY);
          fillPath.lineTo(x, clampedY);
        }
      }

      fillPath.lineTo(size.width, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: 0.35),
            secondaryColor.withValues(alpha: 0.04),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);

      final linePaint = Paint()
        ..shader = LinearGradient(
          colors: [primaryColor, secondaryColor],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(wavePath, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NormalVisualizerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.shape != shape ||
        oldDelegate.sensitivity != sensitivity ||
        oldDelegate.primaryColor != primaryColor;
  }
}

class _CircularVisualizerPainter extends CustomPainter {
  final double animationValue;
  final bool isPlaying;
  final VisualizerShape shape;
  final double sensitivity;
  final Color primaryColor;
  final Color secondaryColor;

  _CircularVisualizerPainter({
    required this.animationValue,
    required this.isPlaying,
    required this.shape,
    required this.sensitivity,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (min(size.width, size.height) / 2) * 0.65;
    final maxSpoke = (min(size.width, size.height) / 2) * 0.32;
    final t = animationValue * 2 * pi;

    if (shape == VisualizerShape.bars) {
      const int count = 52;
      final angleStep = (2 * pi) / count;

      final paint = Paint()
        ..color = primaryColor
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < count; i++) {
        final angle = i * angleStep;
        double factor = 0.10;
        if (isPlaying) {
          final s1 = sin(i * 0.5 + t * 2.5);
          final c1 = cos(i * 0.3 - t * 3.0);
          factor = ((s1 * 0.5 + c1 * 0.5 + 0.6) * 0.7 * sensitivity).clamp(0.08, 1.0);
        }
        final spokeLen = factor * maxSpoke;
        final start = Offset(
          center.dx + cos(angle) * baseRadius,
          center.dy + sin(angle) * baseRadius,
        );
        final end = Offset(
          center.dx + cos(angle) * (baseRadius + spokeLen),
          center.dy + sin(angle) * (baseRadius + spokeLen),
        );

        paint.color = Color.lerp(primaryColor, secondaryColor, (i / count)) ?? primaryColor;
        canvas.drawLine(start, end, paint);
      }
    } else {
      // Circular wave
      const int count = 72;
      final angleStep = (2 * pi) / count;
      final path = Path();

      for (int i = 0; i <= count; i++) {
        final angle = i * angleStep;
        double factor = 0.15;
        if (isPlaying) {
          final w = sin(i * 0.8 + t * 2.4) * 0.45 + cos(i * 0.4 - t * 1.8) * 0.35 + 0.4;
          factor = (w * sensitivity).clamp(0.08, 1.0);
        }
        final r = baseRadius + (factor * maxSpoke);
        final pt = Offset(center.dx + cos(angle) * r, center.dy + sin(angle) * r);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();

      final strokePaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularVisualizerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.shape != shape;
  }
}

// ==========================================
// PANEL DERECHO DE REPRODUCCIÓN (RIGHT SIDEBAR)
// Información ampliada, portada grande, visualizador y cola de espera
// ==========================================
class _RightNowPlayingSidebar extends StatelessWidget {
  const _RightNowPlayingSidebar();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final track = provider.currentTrack;

    return GlassPanel(
      width: 320,
      margin: const EdgeInsets.fromLTRB(0, 14, 14, 14),
      borderRadius: BorderRadius.circular(16),
      blur: provider.blurAmount,
      opacity: provider.glassOpacity,
      padding: const EdgeInsets.all(16),
      child: track == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.music_note_outlined, size: 48, color: SpotifyTheme.lightGray),
                  const SizedBox(height: 12),
                  const Text(
                    'No hay canción activa',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Elige una pista de tu biblioteca o del buscador',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.graphic_eq, color: SpotifyTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Sonando ahora',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Colors.white70),
                      tooltip: 'Cerrar panel lateral',
                      onPressed: () => provider.toggleRightSidebar(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Carátula en formato grande con sombra y reflejo
                      Center(
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: provider.lyricsPrimaryColor.withValues(alpha: 0.55),
                                blurRadius: 28,
                                spreadRadius: 2,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: track.artworkUrl != null
                                ? Image.network(
                                    track.artworkUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _defaultArtwork(260),
                                  )
                                : _defaultArtwork(260),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Título, Artista y Corazón Reanimated
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                ArtistClickableText(
                                  artist: track.artist,
                                  avatarUrl: track.artworkUrl,
                                  style: TextStyle(fontSize: 13, color: SpotifyTheme.lightGray),
                                ),
                              ],
                            ),
                          ),
                          SpotifyAnimatedHeart(
                            isLiked: provider.isFavorite(track),
                            size: 24,
                            onTap: () => provider.toggleFavorite(track),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Badge de información ampliada
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.album, size: 16, color: SpotifyTheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      track.album,
                                      style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: SpotifyTheme.primary.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                track.isLocal ? 'LOCAL MP3' : '320K STEREO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: SpotifyTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Visualizador reactivo en el panel lateral
                      if (provider.isVisualizerEnabled) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Visualizador de Audio',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60),
                            ),
                            Text(
                              provider.visualizerShape == VisualizerShape.bars ? 'Barras' : 'Ondas',
                              style: TextStyle(fontSize: 11, color: SpotifyTheme.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 54,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: LiveAudioVisualizer(
                            height: 38,
                            isPlaying: provider.isPlaying,
                            sensitivity: provider.visualizerSensitivity,
                            style: VisualizerStyle.normal,
                            shape: provider.visualizerShape,
                            primaryColor: SpotifyTheme.primary,
                            secondaryColor: provider.lyricsPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Próximas canciones en cola
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'A continuación (Cola)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            '${provider.effectiveQueue.length} disponibles',
                            style: const TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (provider.effectiveQueue.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No hay más canciones en la cola', style: TextStyle(color: Colors.white38, fontSize: 11)),
                        )
                      else
                        ...provider.effectiveQueue.take(5).map((qTrack) {
                          final isThis = qTrack.id == track.id;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isThis
                                  ? SpotifyTheme.primary.withValues(alpha: 0.16)
                                  : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isThis ? SpotifyTheme.primary.withValues(alpha: 0.35) : Colors.transparent,
                              ),
                            ),
                            child: InkWell(
                              onTap: () => provider.playTrack(qTrack, keepQueue: true),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: qTrack.artworkUrl != null
                                        ? Image.network(
                                            qTrack.artworkUrl!,
                                            width: 36,
                                            height: 36,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _defaultArtwork(36),
                                          )
                                        : _defaultArtwork(36),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          qTrack.title,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isThis ? FontWeight.bold : FontWeight.w500,
                                            color: isThis ? SpotifyTheme.primary : Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        ArtistClickableText(
                                          artist: qTrack.artist,
                                          avatarUrl: qTrack.artworkUrl,
                                          style: const TextStyle(fontSize: 10.5, color: Colors.white54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isThis ? Icons.volume_up : Icons.play_arrow,
                                    size: 18,
                                    color: isThis ? SpotifyTheme.primary : Colors.white54,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  static Widget _defaultArtwork([double size = 48]) {
    return Container(
      width: size,
      height: size,
      color: SpotifyTheme.darkGray,
      child: Icon(Icons.music_note, color: Colors.white54, size: size * 0.5),
    );
  }
}

// ==========================================
// PANEL FLOTANTE DE PERSONALIZACIÓN (SPICETIFY STUDIO)
// Sliders, toggles y temas en tiempo real
// ==========================================
class _CustomizationStudioDialog extends StatefulWidget {
  const _CustomizationStudioDialog();

  @override
  State<_CustomizationStudioDialog> createState() => _CustomizationStudioDialogState();
}

class _CustomizationStudioDialogState extends State<_CustomizationStudioDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: GlassPanel(
        width: 660,
        height: 620,
        borderRadius: BorderRadius.circular(22),
        blur: 32.0,
        opacity: 0.85,
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SpotifyTheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.tune, color: SpotifyTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personalización Spicetify Studio',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Efecto cristal, visualizadores, temas y extensiones en vivo',
                          style: TextStyle(fontSize: 12, color: SpotifyTheme.lightGray),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tab bar
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: SpotifyTheme.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SpotifyTheme.primary.withValues(alpha: 0.6)),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(icon: Icon(Icons.graphic_eq, size: 18), text: 'Visualizador'),
                  Tab(icon: Icon(Icons.blur_on, size: 18), text: 'Cristal & Fondo'),
                  Tab(icon: Icon(Icons.palette_outlined, size: 18), text: 'Temas'),
                  Tab(icon: Icon(Icons.extension_outlined, size: 18), text: 'Extensiones'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Visualizador
                  ListView(
                    children: [
                      _buildSwitchTile(
                        title: 'Activar Visualizador de Audio',
                        subtitle: 'Dibuja ondas o barras dinámicas que reaccionan a la música',
                        value: provider.isVisualizerEnabled,
                        onChanged: provider.setVisualizerEnabled,
                      ),
                      const SizedBox(height: 12),
                      _buildSectionHeader('Estilo de Renderizado'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceButton(
                              label: 'Normal (Horizontal)',
                              icon: Icons.equalizer,
                              isSelected: provider.visualizerStyle == VisualizerStyle.normal,
                              onTap: () => provider.setVisualizerStyle(VisualizerStyle.normal),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildChoiceButton(
                              label: 'Circular (Radial)',
                              icon: Icons.circle_outlined,
                              isSelected: provider.visualizerStyle == VisualizerStyle.circular,
                              onTap: () => provider.setVisualizerStyle(VisualizerStyle.circular),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildSectionHeader('Forma del Visualizador'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceButton(
                              label: 'Barras (Equalizer)',
                              icon: Icons.bar_chart,
                              isSelected: provider.visualizerShape == VisualizerShape.bars,
                              onTap: () => provider.setVisualizerShape(VisualizerShape.bars),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildChoiceButton(
                              label: 'Ondas (Waveform)',
                              icon: Icons.waves,
                              isSelected: provider.visualizerShape == VisualizerShape.waves,
                              onTap: () => provider.setVisualizerShape(VisualizerShape.waves),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildSliderTile(
                        title: 'Sensibilidad y Reactividad',
                        valueText: '${provider.visualizerSensitivity.toStringAsFixed(1)}x',
                        value: provider.visualizerSensitivity,
                        min: 0.5,
                        max: 2.5,
                        onChanged: provider.setVisualizerSensitivity,
                      ),
                      const SizedBox(height: 12),
                      _buildSwitchTile(
                        title: 'Mostrar en la Barra Inferior de Reproducción',
                        subtitle: 'Muestra una barra de ecualizador fluida sobre los controles',
                        value: provider.showVisualizerInBottomBar,
                        onChanged: provider.setShowVisualizerInBottomBar,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 52,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: LiveAudioVisualizer(
                          height: 36,
                          isPlaying: true,
                          sensitivity: provider.visualizerSensitivity,
                          style: provider.visualizerStyle,
                          shape: provider.visualizerShape,
                          primaryColor: SpotifyTheme.primary,
                          secondaryColor: provider.lyricsPrimaryColor,
                        ),
                      ),
                    ],
                  ),

                  // Tab 2: Fondo & Efecto Cristal (Glassmorphism)
                  ListView(
                    children: [
                      _buildSectionHeader('🎬 Motor de Video de Fondo (Live Video)'),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.video_library_outlined, color: SpotifyTheme.primary, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Fondo Cinemático Personalizado',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Importa tu propio archivo de video animado (.mp4, .mkv, .mov, .webm) para reemplazar el fondo estelar.',
                              style: TextStyle(fontSize: 11.5, color: SpotifyTheme.lightGray),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: SpotifyTheme.primary,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  icon: const Icon(Icons.file_upload_outlined, size: 16),
                                  label: const Text('Importar Video...'),
                                  onPressed: () => provider.pickAndSetCustomVideo(),
                                ),
                                if (provider.backgroundMode == 'custom_video') ...[
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white70,
                                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                      textStyle: const TextStyle(fontSize: 11.5),
                                    ),
                                    icon: const Icon(Icons.restart_alt, size: 16),
                                    label: const Text('Restaurar Estrellas'),
                                    onPressed: () => provider.restoreSpaceBackground(),
                                  ),
                                ],
                              ],
                            ),
                            if (provider.backgroundMode == 'custom_video' && provider.customVideoPath != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: SpotifyTheme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: SpotifyTheme.primary.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 14, color: SpotifyTheme.primary),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Activo: ${File(provider.customVideoPath!).uri.pathSegments.isNotEmpty ? File(provider.customVideoPath!).uri.pathSegments.last : "Video personalizado"}',
                                        style: TextStyle(fontSize: 11, color: SpotifyTheme.primary, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSectionHeader('Fondos Cinemáticos Incorporados'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceButton(
                              label: 'Mar de Estrellas',
                              icon: Icons.auto_awesome,
                              isSelected: provider.backgroundMode == 'space',
                              onTap: () => provider.setBackgroundMode('space'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceButton(
                              label: 'Nebulosa Galáctica',
                              icon: Icons.grain,
                              isSelected: provider.backgroundMode == 'nebula',
                              onTap: () => provider.setBackgroundMode('nebula'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceButton(
                              label: 'Cyberpunk Grid',
                              icon: Icons.grid_4x4,
                              isSelected: provider.backgroundMode == 'cyberpunk',
                              onTap: () => provider.setBackgroundMode('cyberpunk'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceButton(
                              label: 'Aurora Boreal',
                              icon: Icons.waves,
                              isSelected: provider.backgroundMode == 'aurora',
                              onTap: () => provider.setBackgroundMode('aurora'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildSwitchTile(
                        title: 'Lluvia de Cometas (Shooting Stars)',
                        subtitle: 'Animación continua y fluida de cometas cruzando suavemente el lienzo estelar a 60 FPS',
                        value: provider.isCometShowerEnabled,
                        onChanged: provider.setCometShowerEnabled,
                      ),
                      const SizedBox(height: 12),
                      _buildSwitchTile(
                        title: 'Sincronización Cromática (Adaptive UI)',
                        subtitle: 'Adapta los acentos (botón Play, barra, iconos, contornos) automáticamente según el fondo o video',
                        value: provider.adaptiveColorFromBackground,
                        onChanged: provider.setAdaptiveColorMode,
                      ),
                      const SizedBox(height: 14),
                      _buildSliderTile(
                        title: 'Opacidad de los Paneles de Cristal (Glassmorphism)',
                        valueText: provider.glassOpacity <= 0.05
                            ? '0% (Flotante Puro)'
                            : provider.glassOpacity >= 0.98
                                ? '100% (Sólido)'
                                : '${(provider.glassOpacity * 100).toStringAsFixed(0)}%',
                        value: provider.glassOpacity,
                        min: 0.0,
                        max: 1.0,
                        onChanged: provider.setGlassOpacity,
                      ),
                      const SizedBox(height: 14),
                      _buildSliderTile(
                        title: 'Nivel de Desenfoque (Blur Glassmorphism)',
                        valueText: '${provider.blurAmount.toStringAsFixed(0)} px',
                        value: provider.blurAmount,
                        min: 0.0,
                        max: 50.0,
                        onChanged: provider.setBlurAmount,
                      ),
                      const SizedBox(height: 14),
                      _buildSwitchTile(
                        title: 'Reactividad y Pulso Ambiental',
                        subtitle: 'El aura luminosa del fondo respira suavemente al ritmo musical',
                        value: provider.bgReactivity,
                        onChanged: provider.setBgReactivity,
                      ),
                    ],
                  ),

                  // Tab 3: Temas Spicetify
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 80,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: AppTheme.themes.length,
                    itemBuilder: (context, index) {
                      final themeKey = AppTheme.themes.keys.elementAt(index);
                      final theme = AppTheme.themes[themeKey]!;
                      final isSelected = provider.activeThemeKey == themeKey;

                      return InkWell(
                        onTap: () => provider.setTheme(themeKey),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? theme.primary : Colors.white.withValues(alpha: 0.1),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [theme.primary, theme.accentGlow],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      theme.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      themeKey == 'sleek' ? 'Por defecto' : 'Modo oscuro',
                                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: theme.primary, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Tab 4: Extensiones & Rendimiento
                  ListView(
                    children: [
                      _buildSwitchTile(
                        title: 'Minimizar a Burbuja Flotante (Always-on-Top)',
                        subtitle: 'Al minimizar la app, se convierte en el reproductor burbuja flotante sobre otros programas',
                        value: provider.minimizeToBubbleEnabled,
                        onChanged: provider.setMinimizeToBubbleEnabled,
                      ),
                      const SizedBox(height: 12),
                      _buildSwitchTile(
                        title: 'Bloqueador de Anuncios & Filtro de Audio',
                        subtitle: 'Evita cortes molestos y garantiza pistas musicales limpias',
                        value: provider.adBlockerEnabled,
                        onChanged: provider.setAdBlockerEnabled,
                      ),
                      const SizedBox(height: 12),
                      _buildSwitchTile(
                        title: 'Modo Ultra-Rendimiento (Menor uso de GPU)',
                        subtitle: 'Reduce efectos pesados para máxima fluidez en cualquier PC',
                        value: provider.ultraPerformanceMode,
                        onChanged: provider.setUltraPerformanceMode,
                      ),
                      const SizedBox(height: 14),
                      _buildSliderTile(
                        title: 'Calibración de Letras Sincronizadas (Offset)',
                        valueText: '${provider.lyricOffsetMs > 0 ? "+" : ""}${provider.lyricOffsetMs} ms',
                        value: provider.lyricOffsetMs.toDouble(),
                        min: -1000,
                        max: 1000,
                        onChanged: (val) => provider.setLyricOffsetMs(val.round()),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white12,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.restart_alt, size: 18),
                        label: const Text('Restablecer Ajustes por Defecto'),
                        onPressed: () {
                          provider.resetCustomizationToDefaults();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ajustes restablecidos al estado original')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpotifyTheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Listo', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white70)),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: SpotifyTheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(valueText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SpotifyTheme.primary)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: SpotifyTheme.primary,
              thumbColor: Colors.white,
              trackHeight: 3,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? SpotifyTheme.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? SpotifyTheme.primary : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? SpotifyTheme.primary : Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// BOTÓN DE CORAZÓN CON ANIMACIÓN REANIMATED
// Inspirado en TheWidlarzGroup/Spotify-Heart-Reanimated
// ==========================================
class SpotifyAnimatedHeart extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final double size;

  const SpotifyAnimatedHeart({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.size = 22,
  });

  @override
  State<SpotifyAnimatedHeart> createState() => _SpotifyAnimatedHeartState();
}

class _SpotifyAnimatedHeartState extends State<SpotifyAnimatedHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceCircleAnimation;
  final List<_FlyingParticle> _particles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.35).chain(CurveTween(curve: Curves.easeOutBack)), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
    ]).animate(_controller);

    _bounceCircleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
  }

  void _triggerAnimation() {
    if (!widget.isLiked) {
      _particles.clear();
      for (int i = 0; i < 7; i++) {
        final angle = (i * (2 * pi / 7)) + (_rnd.nextDouble() * 0.3 - 0.15);
        final distance = 20.0 + _rnd.nextDouble() * 18.0;
        _particles.add(
          _FlyingParticle(
            targetOffset: Offset(cos(angle) * distance, sin(angle) * distance),
            scale: 0.5 + _rnd.nextDouble() * 0.6,
          ),
        );
      }
      _controller.forward(from: 0.0);
    } else {
      _controller.reverse(from: 0.5);
    }
    widget.onTap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _triggerAnimation,
      child: SizedBox(
        width: widget.size * 2,
        height: widget.size * 2,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Círculo rebotante de fondo (Bouncing Circle)
                if (_controller.value > 0.0 && _controller.value < 0.9)
                  Opacity(
                    opacity: (1.0 - _bounceCircleAnimation.value).clamp(0.0, 1.0),
                    child: Container(
                      width: widget.size * (1.0 + _bounceCircleAnimation.value * 2.2),
                      height: widget.size * (1.0 + _bounceCircleAnimation.value * 2.2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SpotifyTheme.primary.withValues(alpha: 0.8),
                          width: (1.0 - _bounceCircleAnimation.value) * 3.0 + 0.5,
                        ),
                      ),
                    ),
                  ),

                // Partículas voladoras de corazones (Flying Hearts)
                if (_controller.value > 0.05 && _controller.value < 0.95)
                  ..._particles.map((p) {
                    final progress = _controller.value;
                    final currentOffset = Offset(
                      p.targetOffset.dx * progress,
                      p.targetOffset.dy * progress,
                    );
                    final opacity = (1.0 - progress).clamp(0.0, 1.0);
                    return Transform.translate(
                      offset: currentOffset,
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: p.scale * (1.0 - progress * 0.5),
                          child: Icon(
                            Icons.favorite,
                            color: SpotifyTheme.primary,
                            size: 11,
                          ),
                        ),
                      ),
                    );
                  }),

                // Corazón principal con escala reanimada
                Transform.scale(
                  scale: _controller.isAnimating ? _scaleAnimation.value : 1.0,
                  child: Icon(
                    widget.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: widget.isLiked ? SpotifyTheme.primary : SpotifyTheme.lightGray,
                    size: widget.size,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FlyingParticle {
  final Offset targetOffset;
  final double scale;
  _FlyingParticle({required this.targetOffset, required this.scale});
}

// ==========================================
// BARRA LATERAL ADAPTABLE (SIDEBAR RESPONSIVE)
// Estilo RN-Spotify-Clone-Redesigned
// ==========================================
class _SidebarWidget extends StatelessWidget {
  final bool isCompact;

  const _SidebarWidget({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final user = provider.userProfile;

    if (isCompact) {
      return GlassPanel(
        width: 74,
        borderRadius: BorderRadius.zero,
        margin: EdgeInsets.zero,
        blur: provider.blurAmount,
        opacity: provider.glassOpacity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF00FFA3), SpotifyTheme.primary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.graphic_eq, color: Colors.black, size: 24),
            ),
            const SizedBox(height: 24),
            _compactNavItem(Icons.home_filled, 'Inicio', 0, provider),
            _compactNavItem(Icons.search, 'Buscar en Internet', 1, provider),
            _compactNavItem(Icons.library_music, 'Tu biblioteca', 2, provider),
            _compactNavItem(Icons.favorite, 'Canciones que te gustan', 3, provider),
            _compactNavItem(Icons.lyrics_outlined, 'Letra en vivo', 4, provider),
            const Divider(color: Color(0xFF282828), indent: 14, endIndent: 14),
            _compactNavItem(Icons.person, 'Mi Perfil', 5, provider),
            const Spacer(),
            IconButton(
              tooltip: 'Personalizar diseño (Studio)',
              icon: Icon(Icons.tune, color: SpotifyTheme.primary),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.65),
                  builder: (context) => const _CustomizationStudioDialog(),
                );
              },
            ),
            const SizedBox(height: 8),
            IconButton(
              tooltip: 'Abrir Carpeta Local...',
              icon: Icon(Icons.folder_open, color: SpotifyTheme.primary),
              onPressed: () => provider.pickLocalFolder(),
            ),
          ],
        ),
      );
    }

    return GlassPanel(
      width: 240,
      borderRadius: BorderRadius.zero,
      margin: EdgeInsets.zero,
      blur: provider.blurAmount,
      opacity: provider.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF00FFA3), SpotifyTheme.primary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: SpotifyTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/cybermusic_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.graphic_eq, color: Colors.black, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'CYBERMUSIC',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _navItem(Icons.home_filled, 'Inicio', 0, provider),
          _navItem(Icons.search, 'Buscar en Internet', 1, provider),
          _navItem(Icons.library_music, 'Tu biblioteca', 2, provider),
          _navItem(Icons.favorite, 'Canciones que te gustan', 3, provider),
          _navItem(Icons.lyrics_outlined, 'Letra en vivo (Lyrics)', 4, provider),

          const SizedBox(height: 10),
          const Divider(color: Color(0xFF282828)),
          const SizedBox(height: 6),

          _navItem(Icons.person, 'Mi Perfil', 5, provider),

          const SizedBox(height: 12),
          // Botón Spicetify Studio en el sidebar
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                barrierColor: Colors.black.withValues(alpha: 0.65),
                builder: (context) => const _CustomizationStudioDialog(),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SpotifyTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SpotifyTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune, color: SpotifyTheme.primary, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Personalizar Diseño',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: SpotifyTheme.primary, size: 12),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF242424).withValues(alpha: 0.6),
              foregroundColor: SpotifyTheme.primary,
              minimumSize: const Size(double.infinity, 38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.folder_open, size: 16),
            label: const Text(
              'Abrir Carpeta Local...',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () => provider.pickLocalFolder(),
          ),

          const Spacer(),

          // Card de Perfil Resumido en el Sidebar (RN Spotify Style)
          InkWell(
            onTap: () => provider.setTab(5),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: SpotifyTheme.primaryDark,
                    backgroundImage: (user.avatarPath != null && File(user.avatarPath!).existsSync())
                        ? FileImage(File(user.avatarPath!)) as ImageProvider
                        : null,
                    child: (user.avatarPath == null || !File(user.avatarPath!).existsSync())
                        ? Text(
                            user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '@${user.username}',
                          style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white54, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactNavItem(IconData icon, String tooltip, int tabIndex, LibreSYProvider provider) {
    final isSelected = provider.currentTab == tabIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(
          icon,
          color: isSelected ? SpotifyTheme.primary : Colors.grey[400],
          size: 24,
        ),
        onPressed: () => provider.setTab(tabIndex),
      ),
    );
  }

  Widget _navItem(IconData icon, String title, int tabIndex, LibreSYProvider provider) {
    final isSelected = provider.currentTab == tabIndex;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: isSelected ? SpotifyTheme.primary.withValues(alpha: 0.16) : Colors.transparent,
      leading: Icon(
        icon,
        color: isSelected ? SpotifyTheme.primary : Colors.grey[400],
        size: 21,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[400],
          fontSize: 13.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => provider.setTab(tabIndex),
    );
  }
}

// ==========================================
// VISTA 1: INICIO (HOME) - ESTILO REDESIGNED
// ==========================================
class _HomeView extends StatelessWidget {
  const _HomeView();

  static const List<HomeHighlightItem> _trendingItems = [
    HomeHighlightItem(
      title: 'Cyberpunk Synthwave',
      subtitle: 'Pistas completas • Electrónica & Neon',
      query: 'Cyberpunk',
      imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&q=80',
    ),
    HomeHighlightItem(
      title: 'Petite Meller Mix',
      subtitle: 'Baby Love, Watson, Aeroplane y más',
      query: 'Petite Meller',
      imageUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=400&q=80',
    ),
    HomeHighlightItem(
      title: 'Lo-Fi Chill Beats',
      subtitle: 'Para estudiar y programar concentrado',
      query: 'Lofi Chill',
      imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80',
    ),
    HomeHighlightItem(
      title: 'Electronic Festival',
      subtitle: 'EDM, House & Bass de inicio a fin',
      query: 'Daft Punk',
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&q=80',
    ),
    HomeHighlightItem(
      title: 'Rock & Indie Energy',
      subtitle: 'Guitarras eléctricas y batería en vivo',
      query: 'Arctic Monkeys',
      imageUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&q=80',
    ),
    HomeHighlightItem(
      title: 'The Weeknd & Pop',
      subtitle: 'Éxitos globales completos',
      query: 'The Weeknd',
      imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&q=80',
    ),
  ];

  static const List<HomeHighlightItem> _genreItems = [
    HomeHighlightItem(
      title: 'Pop Global Hits',
      subtitle: 'Dua Lipa, Coldplay, Bruno Mars',
      query: 'Dua Lipa',
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400&q=80',
    ),
    HomeHighlightItem(
      title: 'Clásicos del Rock',
      subtitle: 'Queen, Nirvana, Linkin Park',
      query: 'Queen',
      imageUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&q=80',
    ),
    HomeHighlightItem(
      title: 'Gaming & Phonk',
      subtitle: 'Adrenalina pura para tus partidas',
      query: 'Phonk',
      imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&q=80',
    ),
    HomeHighlightItem(
      title: 'Piano & Acoustic',
      subtitle: 'Melodías instrumentales relajantes',
      query: 'Ludovico Einaudi',
      imageUrl: 'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=400&q=80',
    ),
    HomeHighlightItem(
      title: 'Jazz & Lounge',
      subtitle: 'Clásicos nocturnos y saxofón',
      query: 'Frank Sinatra',
      imageUrl: 'https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final user = provider.userProfile;

    return Container(
      color: SpotifyTheme.background.withValues(alpha: provider.glassOpacity * 0.45),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int gridColumns = constraints.maxWidth > 900
              ? 3
              : (constraints.maxWidth > 540 ? 2 : 1);

          return CustomScrollView(
            slivers: [
              // Header con Saludo y avatar clicable que lleva al Perfil
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(user.displayName),
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Música ilimitada, letras sincronizadas y sin anuncios',
                            style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 13),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => provider.setTab(5),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: SpotifyTheme.primary, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: SpotifyTheme.primaryDark,
                            backgroundImage: (user.avatarPath != null && File(user.avatarPath!).existsSync())
                                ? FileImage(File(user.avatarPath!)) as ImageProvider
                                : null,
                            child: (user.avatarPath == null || !File(user.avatarPath!).existsSync())
                                ? Text(
                                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Grid de destacados (Spotify Style)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridColumns,
                    mainAxisExtent: 68,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _trendingItems[index];
                      return InkWell(
                        onTap: () {
                          provider.setTab(1);
                          provider.searchOnline(item.query);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF242424),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 68,
                                  height: 68,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 68,
                                    height: 68,
                                    color: SpotifyTheme.primary,
                                    child: const Icon(Icons.music_note, color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(Icons.play_circle_fill, color: SpotifyTheme.primary, size: 30),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _trendingItems.length,
                  ),
                ),
              ),

              // Sección Canciones Populares de Hoy (Algoritmo de Tendencias Diarias)
              SliverToBoxAdapter(
                child: _HorizontalTrackSection(
                  title: 'Canciones Populares del Día (Top Hits Globales)',
                  icon: const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 22),
                  tracks: provider.popularTracks,
                  isLoading: provider.isLoadingPopular,
                  refreshTooltip: 'Actualizar canciones populares',
                  onRefresh: () => provider.fetchDailyPopularTracks(),
                ),
              ),

              // Sección Recomendadas para ti (Similares a lo que escuchas)
              SliverToBoxAdapter(
                child: _HorizontalTrackSection(
                  title: 'Recomendadas para ti (Basadas en tus gustos)',
                  icon: Icon(Icons.auto_awesome, color: SpotifyTheme.primary, size: 22),
                  tracks: provider.recommendedTracks,
                  isLoading: provider.isLoadingRecommendations,
                  refreshTooltip: 'Generar nuevas recomendaciones',
                  onRefresh: () => provider.fetchRecommendedTracks(),
                ),
              ),

              // Sección Reproducido Recientemente (si hay historial)
              if (provider.recentlyPlayed.isNotEmpty)
                SliverToBoxAdapter(
                  child: _HorizontalTrackSection(
                    title: 'Reproducido recientemente',
                    tracks: provider.recentlyPlayed.take(10).toList(),
                  ),
                ),

              const SliverToBoxAdapter(
                child: _HomeImageCarousel(
                  title: 'Destacados para escuchar de inicio a fin',
                  items: _trendingItems,
                ),
              ),

              const SliverToBoxAdapter(
                child: _HomeImageCarousel(
                  title: 'Explorar estaciones y géneros',
                  items: _genreItems,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    String prefix = 'Buenas noches';
    if (hour < 12) {
      prefix = 'Buenos días';
    } else if (hour < 19) {
      prefix = 'Buenas tardes';
    }
    final firstName = name.split(' ').first;
    return '$prefix, $firstName!';
  }
}

// ==========================================
// SECCIÓN HORIZONTAL CON BARRITA DESLIZANTE VISIBLE Y FLECHAS < >
// Permite arrastrar la barra y usar flechas para explorar más canciones
// ==========================================
class _HorizontalTrackSection extends StatefulWidget {
  final String title;
  final Widget? icon;
  final List<Track> tracks;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final String? refreshTooltip;

  const _HorizontalTrackSection({
    required this.title,
    this.icon,
    required this.tracks,
    this.isLoading = false,
    this.onRefresh,
    this.refreshTooltip,
  });

  @override
  State<_HorizontalTrackSection> createState() => _HorizontalTrackSectionState();
}

class _HorizontalTrackSectionState extends State<_HorizontalTrackSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollBy(double offset) {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + offset).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de la sección con título, flechas de navegación < > y refresco
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  _SectionScrollArrow(
                    icon: Icons.chevron_left,
                    tooltip: 'Desplazar a la izquierda',
                    onTap: () => _scrollBy(-340),
                  ),
                  const SizedBox(width: 6),
                  _SectionScrollArrow(
                    icon: Icons.chevron_right,
                    tooltip: 'Desplazar a la derecha',
                    onTap: () => _scrollBy(340),
                  ),
                  if (widget.onRefresh != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.refresh, color: SpotifyTheme.lightGray, size: 20),
                      tooltip: widget.refreshTooltip ?? 'Actualizar',
                      onPressed: widget.onRefresh,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Contenedor con Barrita de Desplazamiento Horizontal Visible (RawScrollbar interactivo)
        if (widget.isLoading)
          SizedBox(
            height: 242,
            child: Center(child: CircularProgressIndicator(color: SpotifyTheme.primary)),
          )
        else if (widget.tracks.isNotEmpty)
          SizedBox(
            height: 242,
            child: RawScrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              thickness: 7,
              radius: const Radius.circular(4),
              thumbColor: SpotifyTheme.primary.withValues(alpha: 0.65),
              trackColor: Colors.white.withValues(alpha: 0.08),
              trackBorderColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.tracks.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final track = widget.tracks[index];
                    return _TrackCardItem(track: track);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionScrollArrow extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SectionScrollArrow({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_SectionScrollArrow> createState() => _SectionScrollArrowState();
}

class _SectionScrollArrowState extends State<_SectionScrollArrow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hovered ? Colors.white.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.07),
              border: Border.all(
                color: _hovered ? SpotifyTheme.primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(widget.icon, color: _hovered ? SpotifyTheme.primary : Colors.white70, size: 19),
          ),
        ),
      ),
    );
  }
}

class ArtistClickableText extends StatefulWidget {
  final String artist;
  final String? avatarUrl;
  final TextStyle? style;
  final int maxLines;

  const ArtistClickableText({
    super.key,
    required this.artist,
    this.avatarUrl,
    this.style,
    this.maxLines = 1,
  });

  @override
  State<ArtistClickableText> createState() => _ArtistClickableTextState();
}

class _ArtistClickableTextState extends State<ArtistClickableText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.artist.isEmpty || widget.artist == 'Archivo de tu PC') {
      return Text(
        widget.artist,
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final defaultStyle = widget.style ?? TextStyle(color: SpotifyTheme.lightGray, fontSize: 11);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final provider = Provider.of<LibreSYProvider>(context, listen: false);
          provider.openArtistProfile(widget.artist, avatarUrl: widget.avatarUrl);
        },
        child: Text(
          widget.artist,
          style: defaultStyle.copyWith(
            color: _isHovered ? Colors.white : defaultStyle.color,
            decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
          ),
          maxLines: widget.maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _TrackCardItem extends StatelessWidget {
  final Track track;

  const _TrackCardItem({required this.track});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context, listen: false);

    return InkWell(
      onTap: () => provider.playTrack(track),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SpotifyTheme.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: track.artworkUrl != null
                      ? Image.network(
                          track.artworkUrl!,
                          width: 136,
                          height: 136,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _fallbackArt(),
                        )
                      : _fallbackArt(),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: SpotifyTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6)],
                    ),
                    padding: const EdgeInsets.all(7),
                    child: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              track.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            ArtistClickableText(
              artist: track.artist,
              avatarUrl: track.artworkUrl,
              style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackArt() {
    return Container(
      width: 136,
      height: 136,
      color: SpotifyTheme.darkGray,
      child: const Icon(Icons.album, color: Colors.white54, size: 50),
    );
  }
}

class _HomeImageCarousel extends StatefulWidget {
  final String title;
  final List<HomeHighlightItem> items;

  const _HomeImageCarousel({required this.title, required this.items});

  @override
  State<_HomeImageCarousel> createState() => _HomeImageCarouselState();
}

class _HomeImageCarouselState extends State<_HomeImageCarousel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollBy(double offset) {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + offset).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _SectionScrollArrow(
                    icon: Icons.chevron_left,
                    tooltip: 'Desplazar a la izquierda',
                    onTap: () => _scrollBy(-340),
                  ),
                  const SizedBox(width: 6),
                  _SectionScrollArrow(
                    icon: Icons.chevron_right,
                    tooltip: 'Desplazar a la derecha',
                    onTap: () => _scrollBy(340),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 242,
          child: RawScrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            thickness: 7,
            radius: const Radius.circular(4),
            thumbColor: SpotifyTheme.primary.withValues(alpha: 0.65),
            trackColor: Colors.white.withValues(alpha: 0.08),
            trackBorderColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                scrollDirection: Axis.horizontal,
                itemCount: widget.items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return InkWell(
                    onTap: () {
                      provider.setTab(1);
                      provider.searchOnline(item.query);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SpotifyTheme.card,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 136,
                                  height: 136,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 136,
                                    height: 136,
                                    color: SpotifyTheme.darkGray,
                                    child: const Icon(Icons.album, color: Colors.white54, size: 50),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: SpotifyTheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6)],
                                  ),
                                  padding: const EdgeInsets.all(7),
                                  child: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// VISTA 2: BUSCADOR POR INTERNET (REDESIGNED)
// ==========================================
class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);

    return Container(
      color: SpotifyTheme.background.withValues(alpha: provider.glassOpacity * 0.45),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '¿Qué quieres escuchar hoy?',
                      hintStyle: TextStyle(color: SpotifyTheme.lightGray),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: const Color(0xFF242424),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (query) => provider.searchOnline(query),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpotifyTheme.primary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(100, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () => provider.searchOnline(_searchController.text),
                child: const Text('Buscar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (provider.isSearching)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(color: SpotifyTheme.primary),
              ),
            )
          else if (provider.onlineSearchResults.isEmpty)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text(
                        'Busca artistas, canciones y podcasts',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Encuentra pistas completas en internet y reprodúcelas o descárgalas en tu PC.',
                        style: TextStyle(color: SpotifyTheme.lightGray),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: provider.onlineSearchResults.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xFF202020), height: 1),
                itemBuilder: (context, index) {
                  final track = provider.onlineSearchResults[index];
                  return _TrackTileItem(track: track);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// FILA DE CANCIÓN CON MICROANIMACIÓN DE CORAZÓN
// ==========================================
class _TrackTileItem extends StatelessWidget {
  final Track track;

  const _TrackTileItem({required this.track});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final isSelected = provider.currentTrack?.id == track.id;
    final isFav = provider.isFavorite(track);
    final downloading = provider.isDownloading(track.id);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: const Color(0xFF222222),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: track.artworkUrl != null
            ? Image.network(
                track.artworkUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _defaultArtwork(),
              )
            : _defaultArtwork(),
      ),
      title: Text(
        track.title,
        style: TextStyle(
          color: isSelected ? SpotifyTheme.primary : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ArtistClickableText(
              artist: track.artist,
              avatarUrl: track.artworkUrl,
              style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 12),
            ),
          ),
          Text(
            ' • ${_formatDuration(track.duration)}',
            style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 12),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Ver letra sincronizada',
            icon: const Icon(Icons.lyrics_outlined, color: Colors.white70, size: 20),
            onPressed: () {
              if (provider.currentTrack?.id != track.id) {
                provider.playTrack(track);
              }
              provider.setTab(4);
            },
          ),

          if (!track.isLocal)
            downloading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: SpotifyTheme.primary),
                    ),
                  )
                : IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Descargar canción completa en MP3',
                    icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white70, size: 22),
                    onPressed: () async {
                      final savedPath = await provider.downloadTrackAsMp3(track);
                      if (context.mounted && savedPath != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: SpotifyTheme.primary,
                            content: Text(
                              '¡Descargado en MP3: $savedPath!',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                    },
                  ),

          // Botón animado de Me Gusta (Spotify Heart Reanimated)
          SpotifyAnimatedHeart(
            isLiked: isFav,
            size: 21,
            onTap: () {
              provider.toggleFavorite(track);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF282828),
                  content: Text(
                    !isFav
                        ? 'Guardada permanentemente en Tu Biblioteca y Favoritos ❤️'
                        : 'Eliminada de Tu Biblioteca',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),

          IconButton(
            visualDensity: VisualDensity.compact,
            icon: isSelected && provider.isBufferingTrack
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: SpotifyTheme.primary),
                  )
                : Icon(
                    isSelected && provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: SpotifyTheme.primary,
                    size: 32,
                  ),
            onPressed: () {
              if (isSelected) {
                provider.togglePlayPause();
              } else {
                provider.playTrack(track);
              }
            },
          ),
        ],
      ),
      onTap: () => provider.playTrack(track),
    );
  }

  Widget _defaultArtwork() {
    return Container(
      width: 48,
      height: 48,
      color: SpotifyTheme.darkGray,
      child: const Icon(Icons.music_note, color: Colors.white54),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

// ==========================================
// VISTA 3: TU BIBLIOTECA
// ==========================================
class _LibraryView extends StatelessWidget {
  const _LibraryView();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final tracks = provider.allLibraryTracks;

    return Container(
      color: SpotifyTheme.background.withValues(alpha: provider.glassOpacity * 0.45),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu Biblioteca',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Canciones guardadas y carpetas locales (${tracks.length} pistas)',
                    style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpotifyTheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('Importar carpeta de PC', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => provider.pickLocalFolder(),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Expanded(
            child: tracks.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.library_add_check_outlined, size: 60, color: Colors.white24),
                          const SizedBox(height: 14),
                          const Text(
                            'Tu biblioteca está vacía',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dale al corazón ❤️ en cualquier canción o importa una carpeta de tu PC.',
                            style: TextStyle(color: SpotifyTheme.lightGray),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: tracks.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFF202020), height: 1),
                    itemBuilder: (context, index) {
                      return _TrackTileItem(track: tracks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// VISTA 4: CANCIONES QUE TE GUSTAN
// ==========================================
class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);

    return Container(
      color: SpotifyTheme.background.withValues(alpha: provider.glassOpacity * 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF5038A0), SpotifyTheme.background],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF450AF5), Color(0xFF8E8EE5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.favorite, size: 55, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('PLAYLIST', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      const Text(
                        'Canciones que te gustan',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${provider.favoriteTracks.length} canciones guardadas permanentemente',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.favoriteTracks.isEmpty
                ? Center(
                    child: Text(
                      'Aún no has marcado canciones con el corazón ❤️.',
                      style: TextStyle(color: SpotifyTheme.lightGray),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: provider.favoriteTracks.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFF202020), height: 1),
                    itemBuilder: (context, index) {
                      return _TrackTileItem(track: provider.favoriteTracks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// VISTA 5: LETRAS SINCRONIZADAS
// Inspirada en Jellify-Music/App (Blurred background + smooth sync)
// ==========================================
class _LyricsSyncedView extends StatefulWidget {
  const _LyricsSyncedView();

  @override
  State<_LyricsSyncedView> createState() => _LyricsSyncedViewState();
}

class _LyricsSyncedViewState extends State<_LyricsSyncedView> {
  final ScrollController _scrollController = ScrollController();
  int _lastScrolledIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveLine(int activeIndex) {
    if (activeIndex != _lastScrolledIndex && activeIndex >= 0 && _scrollController.hasClients) {
      _lastScrolledIndex = activeIndex;
      // Posicionar la línea activa en el tercio superior de la vista (aprox. 160px desde arriba)
      // para evitar que se tire muy arriba y siempre haya suficiente contexto visible
      final targetOffset = (activeIndex * 68.0) - 160.0;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final track = provider.currentTrack;
    final lyrics = provider.currentLyrics;
    final activeIndex = provider.activeLyricIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveLine(activeIndex);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 850;
        final useSplitMode = provider.lyricsSplitMode && isWideScreen;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                provider.lyricsPrimaryColor.withValues(alpha: provider.glassOpacity * 0.75),
                provider.lyricsSecondaryColor.withValues(alpha: provider.glassOpacity * 0.75),
                SpotifyTheme.background.withValues(alpha: provider.glassOpacity * 0.65),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra Superior con Botones
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black45,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Volver atrás', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () => provider.goBackFromLyrics(),
                  ),
                  const SizedBox(width: 14),
                  if (isWideScreen)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: useSplitMode
                            ? SpotifyTheme.primary.withValues(alpha: 0.25)
                            : Colors.black38,
                        foregroundColor: useSplitMode ? SpotifyTheme.primary : Colors.white70,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: useSplitMode ? SpotifyTheme.primary : Colors.transparent,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      icon: Icon(useSplitMode ? Icons.view_sidebar : Icons.crop_portrait, size: 18),
                      label: Text(
                        useSplitMode ? 'Vista Dividida (Carátula + Letra)' : 'Vista Centrada Inmersiva',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      onPressed: () => provider.toggleLyricsSplitMode(),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Ajustar visualizador y desenfoque',
                    icon: Icon(Icons.tune, color: SpotifyTheme.primary),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black.withValues(alpha: 0.65),
                        builder: (context) => const _CustomizationStudioDialog(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: track == null
                    ? const Center(
                        child: Text(
                          'Reproduce cualquier canción para ver la letra sincronizada en tiempo real.',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : provider.isLoadingLyrics
                        ? Center(
                            child: CircularProgressIndicator(color: SpotifyTheme.primary),
                          )
                        : useSplitMode
                            // Vista Inmersiva Dividida: Carátula a la izquierda + Letras grandes a la derecha
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Columna Izquierda: Carátula, info y visualizador
                                  SizedBox(
                                    width: 320,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 280,
                                            height: 280,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: provider.lyricsPrimaryColor.withValues(alpha: 0.6),
                                                  blurRadius: 36,
                                                  spreadRadius: 4,
                                                  offset: const Offset(0, 12),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: track.artworkUrl != null
                                                  ? Image.network(
                                                      track.artworkUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => _defaultArtwork(280),
                                                    )
                                                  : _defaultArtwork(280),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    track.title,
                                                    style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.w900,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  ArtistClickableText(
                                                    artist: track.artist,
                                                    avatarUrl: track.artworkUrl,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: SpotifyTheme.lightGray,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SpotifyAnimatedHeart(
                                              isLiked: provider.isFavorite(track),
                                              size: 26,
                                              onTap: () => provider.toggleFavorite(track),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        if (provider.isVisualizerEnabled)
                                          Container(
                                            height: 48,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.35),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                            ),
                                            child: LiveAudioVisualizer(
                                              height: 36,
                                              isPlaying: provider.isPlaying,
                                              sensitivity: provider.visualizerSensitivity,
                                              style: provider.visualizerStyle,
                                              shape: provider.visualizerShape,
                                              primaryColor: SpotifyTheme.primary,
                                              secondaryColor: provider.lyricsPrimaryColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 36),

                                  // Columna Derecha: Letras Sincronizadas
                                  Expanded(
                                    child: _buildLyricsList(lyrics, activeIndex, provider),
                                  ),
                                ],
                              )
                            // Vista Inmersiva Centrada
                            : _buildLyricsList(lyrics, activeIndex, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLyricsList(List<LyricLine> lyrics, int activeIndex, LibreSYProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: lyrics.length,
      itemBuilder: (context, index) {
        final line = lyrics[index];
        final isCurrent = index == activeIndex;
        final isPast = index < activeIndex;

        return GestureDetector(
          onTap: () => provider.seek(line.timestamp),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuad,
            padding: EdgeInsets.symmetric(
              vertical: isCurrent ? 14 : 10,
              horizontal: 14,
            ),
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: isCurrent ? Colors.white.withValues(alpha: 0.10) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Transform.scale(
              scale: isCurrent ? 1.05 : 1.0,
              alignment: Alignment.centerLeft,
              child: Text(
                line.text,
                style: TextStyle(
                  fontSize: isCurrent ? 30 : 21,
                  fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: isCurrent ? 0.3 : 0,
                  shadows: isCurrent
                      ? [
                          Shadow(
                            color: SpotifyTheme.primary.withValues(alpha: 0.5),
                            blurRadius: 16,
                          ),
                        ]
                      : null,
                  color: isCurrent
                      ? Colors.white
                      : isPast
                          ? Colors.white.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _defaultArtwork([double size = 48]) {
    return Container(
      width: size,
      height: size,
      color: SpotifyTheme.darkGray,
      child: Icon(Icons.music_note, color: Colors.white54, size: size * 0.5),
    );
  }
}

// ==========================================
// VISTA 6: PERFIL DE USUARIO
// Inspirada en rit3zh/expo-animated-sticky-header & RN-Spotify-Clone
// Encabezado retráctil interactivo, edición de foto y datos
// ==========================================
class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  int _activeProfileTab = 0; // 0: Canciones Favoritas, 1: Biblioteca Completa, 2: Sobre el Usuario

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(BuildContext context, LibreSYProvider provider) {
    final user = provider.userProfile;
    final nameCtrl = TextEditingController(text: user.displayName);
    final userCtrl = TextEditingController(text: user.username);
    final bioCtrl = TextEditingController(text: user.bio);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242424),
          title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: SpotifyTheme.primaryDark,
                      backgroundImage: (user.avatarPath != null && File(user.avatarPath!).existsSync())
                          ? FileImage(File(user.avatarPath!)) as ImageProvider
                          : null,
                      child: (user.avatarPath == null || !File(user.avatarPath!).existsSync())
                          ? Text(
                              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                            )
                          : null,
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.of(dialogCtx).pop();
                        await provider.pickAvatarImage();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: SpotifyTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre público',
                    labelStyle: TextStyle(color: SpotifyTheme.lightGray),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SpotifyTheme.primary)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: userCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre de usuario (@)',
                    labelStyle: TextStyle(color: SpotifyTheme.lightGray),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SpotifyTheme.primary)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioCtrl,
                  decoration: InputDecoration(
                    labelText: 'Biografía',
                    labelStyle: TextStyle(color: SpotifyTheme.lightGray),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SpotifyTheme.primary)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SpotifyTheme.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                provider.updateProfile(
                  displayName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : user.displayName,
                  username: userCtrl.text.trim().isNotEmpty ? userCtrl.text.trim() : user.username,
                  bio: bioCtrl.text.trim(),
                );
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final user = provider.userProfile;
    final favCount = provider.favoriteTracks.length;
    final totalSongs = provider.allLibraryTracks.length;

    // Efecto Parallax Sticky Header (inspirado en rit3zh/expo-animated-sticky-header)
    final double collapseRatio = (_scrollOffset / 140.0).clamp(0.0, 1.0);
    final double avatarSize = 100.0 - (collapseRatio * 45.0);

    return Container(
      color: SpotifyTheme.background.withValues(alpha: provider.glassOpacity * 0.45),
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Sticky Parallax Banner
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [const Color(0xFF333333), const Color(0xFF181818), SpotifyTheme.background],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar animado retráctil
                      Hero(
                        tag: 'userAvatar',
                        child: Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: SpotifyTheme.primary, width: 3),
                            boxShadow: const [
                              BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 4)),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: SpotifyTheme.primaryDark,
                            backgroundImage: (user.avatarPath != null && File(user.avatarPath!).existsSync())
                                ? FileImage(File(user.avatarPath!)) as ImageProvider
                                : null,
                            child: (user.avatarPath == null || !File(user.avatarPath!).existsSync())
                                ? Text(
                                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                                    style: TextStyle(
                                      fontSize: avatarSize * 0.42,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('PERFIL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: SpotifyTheme.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('PRO', style: TextStyle(color: SpotifyTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.displayName,
                              style: TextStyle(
                                fontSize: 32 - (collapseRatio * 8),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${user.username} • ${user.bio}',
                              style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white54),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Editar Perfil'),
                                  onPressed: () => _showEditProfileDialog(context, provider),
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: SpotifyTheme.primary,
                                    side: BorderSide(color: SpotifyTheme.primary),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  icon: const Icon(Icons.add_a_photo, size: 16),
                                  label: const Text('Cambiar Foto'),
                                  onPressed: () => provider.pickAvatarImage(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tarjetas de estadísticas (Stats Row) estilo expo-animated-sticky-header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
                  child: Row(
                    children: [
                      _buildStatCard('Canciones Favoritas', '$favCount', Icons.favorite, SpotifyTheme.primary),
                      const SizedBox(width: 14),
                      _buildStatCard('En Tu Biblioteca', '$totalSongs', Icons.library_music, Colors.blueAccent),
                      const SizedBox(width: 14),
                      _buildStatCard('Carpetas Locales', '${provider.savedCustomFolders.length}', Icons.folder, Colors.amber),
                    ],
                  ),
                ),
              ),

              // Pestañas de Perfil (Inspiradas en expo-animated-sticky-header / RN-Spotify)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      _buildTabButton('Tus Favoritos', 0),
                      const SizedBox(width: 16),
                      _buildTabButton('Toda tu Biblioteca', 1),
                      const SizedBox(width: 16),
                      _buildTabButton('Acerca de', 2),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Contenido según la pestaña activa
              if (_activeProfileTab == 0) ...[
                if (provider.favoriteTracks.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                      child: Text('Aún no tienes canciones favoritas guardadas con el corazón ❤️.', style: TextStyle(color: SpotifyTheme.lightGray)),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final track = provider.favoriteTracks[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _TrackTileItem(track: track),
                        );
                      },
                      childCount: provider.favoriteTracks.length,
                    ),
                  ),
              ] else if (_activeProfileTab == 1) ...[
                if (provider.allLibraryTracks.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                      child: Text('Tu biblioteca local está vacía.', style: TextStyle(color: SpotifyTheme.lightGray)),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final track = provider.allLibraryTracks[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _TrackTileItem(track: track),
                        );
                      },
                      childCount: provider.allLibraryTracks.length,
                    ),
                  ),
              ] else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: SpotifyTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF282828)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Información del Perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 10),
                          Text('Nombre: ${user.displayName}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text('Usuario: @${user.username}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text('Biografía: ${user.bio}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text('Foto personalizada: ${user.avatarPath != null ? "Activa" : "Por defecto"}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SpotifyTheme.primary,
                              foregroundColor: Colors.black,
                            ),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Editar información ahora'),
                            onPressed: () => _showEditProfileDialog(context, provider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),

          // Mini top navbar cuando se scrollea hacia abajo (Sticky NavBar)
          if (collapseRatio > 0.6)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                color: Colors.black.withValues(alpha: 0.95),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: SpotifyTheme.primaryDark,
                      backgroundImage: (user.avatarPath != null && File(user.avatarPath!).existsSync())
                          ? FileImage(File(user.avatarPath!)) as ImageProvider
                          : null,
                      child: (user.avatarPath == null || !File(user.avatarPath!).existsSync())
                          ? Text(user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U')
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      user.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Colors.white70),
                      onPressed: () => _showEditProfileDialog(context, provider),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int tabIndex) {
    final isSelected = _activeProfileTab == tabIndex;
    return InkWell(
      onTap: () {
        setState(() {
          _activeProfileTab = tabIndex;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? SpotifyTheme.primary : SpotifyTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? SpotifyTheme.primary : const Color(0xFF333333),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: SpotifyTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF282828)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: SpotifyTheme.lightGray), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// VISTA DEL PERFIL DEL ARTISTA (DISCOGRAFÍA & TOP POPULARES)
// ==========================================
class _ArtistProfileView extends StatefulWidget {
  const _ArtistProfileView();

  @override
  State<_ArtistProfileView> createState() => _ArtistProfileViewState();
}

class _ArtistProfileViewState extends State<_ArtistProfileView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final artistName = provider.currentArtistName ?? 'Artista';
    final avatar = provider.currentArtistAvatar;
    final tracks = provider.artistTopTracks;
    final isFollowing = provider.isFollowingArtist(artistName);

    // Identificar álbumes únicos para la sección de Discografía
    final Map<String, List<Track>> albumGroups = {};
    for (final t in tracks) {
      if (t.album.isNotEmpty && t.album != 'Álbum' && t.album != 'Pista Completa Online') {
        albumGroups.putIfAbsent(t.album, () => []).add(t);
      }
    }

    return Container(
      color: SpotifyTheme.background.withValues(alpha: provider.glassOpacity * 0.45),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Barra Superior de Navegación & Botón Volver
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    tooltip: 'Volver a la vista anterior',
                    onPressed: () => provider.goBackFromArtistProfile(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Perfil del Artista',
                    style: TextStyle(
                      color: SpotifyTheme.lightGray,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                    tooltip: 'Recargar discografía',
                    onPressed: () => provider.fetchArtistDiscography(artistName, preferredArtwork: avatar),
                  ),
                ],
              ),
            ),
          ),

          // Hero Banner del Artista con Fondo Degradado
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1F382B),
                    const Color(0xFF14201A),
                    SpotifyTheme.card,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 18, offset: Offset(0, 6)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar Redondo del Artista en Alta Resolución
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: SpotifyTheme.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: SpotifyTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: avatar != null && avatar.isNotEmpty
                          ? Image.network(
                              avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _fallbackArtistAvatar(artistName),
                            )
                          : _fallbackArtistAvatar(artistName),
                    ),
                  ),
                  const SizedBox(width: 28),

                  // Metadatos del Artista
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified, color: Color(0xFF3D91F4), size: 20),
                            const SizedBox(width: 6),
                            const Text(
                              'Artista verificado',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          artistName,
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${provider.artistMonthlyListenersFormatted} oyentes mensuales',
                          style: TextStyle(
                            color: SpotifyTheme.lightGray,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fila de Controles de Acción (Reproducir Todo, Aleatorio, Seguir)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  // Botón Circular de Reproducir Todo
                  InkWell(
                    onTap: () => provider.playArtistAll(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFF00FFA3), SpotifyTheme.primary],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: SpotifyTheme.primary.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        (provider.isPlaying &&
                                provider.currentTrack != null &&
                                provider.currentTrack!.artist.toLowerCase().contains(artistName.toLowerCase()))
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Botón de Reproducción Aleatoria
                  IconButton(
                    tooltip: 'Reproducción aleatoria de canciones',
                    icon: Icon(
                      Icons.shuffle,
                      color: provider.isShuffleEnabled ? SpotifyTheme.primary : Colors.white70,
                      size: 24,
                    ),
                    onPressed: () => provider.playArtistAll(shuffle: true),
                  ),
                  const SizedBox(width: 12),

                  // Botón de Seguir / Siguiendo
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isFollowing ? SpotifyTheme.primary : Colors.white,
                      side: BorderSide(
                        color: isFollowing ? SpotifyTheme.primary : Colors.white54,
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    icon: Icon(isFollowing ? Icons.check : Icons.add, size: 18),
                    label: Text(
                      isFollowing ? 'SIGUIENDO' : 'SEGUIR',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                    ),
                    onPressed: () => provider.toggleFollowArtist(artistName),
                  ),
                  const SizedBox(width: 16),

                  // Contador de Canciones
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      '${tracks.length} canciones',
                      style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Encabezado de la Sección "Populares"
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 10),
              child: Row(
                children: [
                  const Text(
                    'Populares',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ordenadas de la más popular a la menos popular',
                    style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Estado de Carga / Vacío / Lista de Canciones Populares
          if (provider.isLoadingArtist)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: SpotifyTheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Cargando canciones populares de $artistName...',
                        style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (tracks.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.music_off, size: 54, color: Colors.white30),
                      const SizedBox(height: 14),
                      Text(
                        'No se encontraron canciones disponibles para "$artistName".',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SpotifyTheme.primary,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Intentar de nuevo'),
                        onPressed: () => provider.fetchArtistDiscography(artistName, preferredArtwork: avatar),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = tracks[index];
                  final isPlayingThis = provider.currentTrack?.id == track.id;
                  final rank = index + 1;

                  return _ArtistTrackRankItem(
                    track: track,
                    rank: rank,
                    isSelected: isPlayingThis,
                    isPlaying: isPlayingThis && provider.isPlaying,
                  );
                },
                childCount: tracks.length,
              ),
            ),

          // Sección de Álbumes y Sencillos (Discografía) si existen álbumes detectados
          if (!provider.isLoadingArtist && albumGroups.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 32, 26, 12),
                child: Row(
                  children: [
                    const Text(
                      'Discografía & Álbumes',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '(${albumGroups.length} álbumes y sencillos)',
                      style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: albumGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final albumName = albumGroups.keys.elementAt(index);
                    final albumTracks = albumGroups[albumName]!;
                    final albumCover = albumTracks.first.artworkUrl;

                    return InkWell(
                      onTap: () {
                        provider.playTrack(albumTracks.first);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SpotifyTheme.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: albumCover != null
                                  ? Image.network(
                                      albumCover,
                                      width: 126,
                                      height: 126,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _fallbackAlbumArt(),
                                    )
                                  : _fallbackAlbumArt(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              albumName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${albumTracks.length} ${albumTracks.length == 1 ? "canción" : "canciones"}',
                              style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Espacio extra al final para que la barra inferior no tape nada
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }

  Widget _fallbackArtistAvatar(String name) {
    return Container(
      color: const Color(0xFF282828),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
      ),
    );
  }

  Widget _fallbackAlbumArt() {
    return Container(
      width: 126,
      height: 126,
      color: SpotifyTheme.darkGray,
      child: const Icon(Icons.album, color: Colors.white54, size: 48),
    );
  }
}

// Item de canción clasificada por orden de popularidad (#1, #2, ...)
class _ArtistTrackRankItem extends StatefulWidget {
  final Track track;
  final int rank;
  final bool isSelected;
  final bool isPlaying;

  const _ArtistTrackRankItem({
    required this.track,
    required this.rank,
    required this.isSelected,
    required this.isPlaying,
  });

  @override
  State<_ArtistTrackRankItem> createState() => _ArtistTrackRankItemState();
}

class _ArtistTrackRankItemState extends State<_ArtistTrackRankItem> {
  bool _isHovered = false;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final isFav = provider.isFavorite(widget.track);
    final downloading = provider.isDownloading(widget.track.id);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => provider.playTrack(widget.track),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.08)
                : widget.isSelected
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Número de Ranking (#1, #2...) o icono de reproducción
              SizedBox(
                width: 32,
                child: Center(
                  child: widget.isPlaying
                      ? Icon(Icons.volume_up, color: SpotifyTheme.primary, size: 18)
                      : Text(
                          '#${widget.rank}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: widget.isSelected ? SpotifyTheme.primary : Colors.white54,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 8),

              // Portada pequeña de la canción
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: widget.track.artworkUrl != null
                    ? Image.network(
                        widget.track.artworkUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 44,
                          height: 44,
                          color: SpotifyTheme.darkGray,
                          child: const Icon(Icons.music_note, color: Colors.white54, size: 20),
                        ),
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        color: SpotifyTheme.darkGray,
                        child: const Icon(Icons.music_note, color: Colors.white54, size: 20),
                      ),
              ),
              const SizedBox(width: 14),

              // Título y Álbum
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.track.title,
                      style: TextStyle(
                        color: widget.isSelected ? SpotifyTheme.primary : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.track.album,
                      style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Barra de Popularidad Estilo Spotify
              SizedBox(
                width: 60,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: ((51 - widget.rank.clamp(1, 50)) / 50.0).clamp(0.15, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isSelected ? SpotifyTheme.primary : Colors.white38,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Duración
              Text(
                _formatDuration(widget.track.duration),
                style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 12),
              ),
              const SizedBox(width: 12),

              // Botón de Letra Sincronizada
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Ver letra sincronizada',
                icon: const Icon(Icons.lyrics_outlined, color: Colors.white70, size: 19),
                onPressed: () {
                  if (provider.currentTrack?.id != widget.track.id) {
                    provider.playTrack(widget.track);
                  }
                  provider.setTab(4);
                },
              ),

              // Botón de Descarga MP3
              if (!widget.track.isLocal)
                downloading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: SpotifyTheme.primary),
                        ),
                      )
                    : IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Descargar canción completa en MP3',
                        icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white70, size: 21),
                        onPressed: () async {
                          final savedPath = await provider.downloadTrackAsMp3(widget.track);
                          if (context.mounted && savedPath != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: SpotifyTheme.primary,
                                content: Text(
                                  '¡Descargado en MP3: $savedPath!',
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }
                        },
                      ),

              // Botón de Favorito (Corazón Animado)
              SpotifyAnimatedHeart(
                isLiked: isFav,
                size: 21,
                onTap: () => provider.toggleFavorite(widget.track),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// BARRA INFERIOR DE REPRODUCCIÓN (FULL CONTROLES)
// ==========================================
class _BottomPlayerBar extends StatelessWidget {
  const _BottomPlayerBar();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibreSYProvider>(context);
    final track = provider.currentTrack;

    double progress = 0.0;
    if (provider.duration.inMilliseconds > 0) {
      progress = (provider.position.inMilliseconds / provider.duration.inMilliseconds).clamp(0.0, 1.0);
    }

    IconData repeatIcon = Icons.repeat;
    Color repeatColor = Colors.grey;
    String repeatTooltip = 'Repetir desactivado';
    if (provider.repeatMode == RepeatMode.all) {
      repeatIcon = Icons.repeat;
      repeatColor = SpotifyTheme.primary;
      repeatTooltip = 'Repetir toda la lista';
    } else if (provider.repeatMode == RepeatMode.one) {
      repeatIcon = Icons.repeat_one;
      repeatColor = SpotifyTheme.primary;
      repeatTooltip = 'Repetir esta canción';
    }

    return GlassPanel(
      height: 98,
      borderRadius: BorderRadius.zero,
      margin: EdgeInsets.zero,
      blur: provider.blurAmount,
      opacity: provider.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: Border(
        top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: Row(
        children: [
          // 1. Pista actual
          Expanded(
            flex: 3,
            child: track == null
                ? Row(
                    children: [
                      const Icon(Icons.music_note, color: Colors.white24),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Selecciona una canción',
                          style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: track.artworkUrl != null
                            ? Image.network(
                                track.artworkUrl!,
                                width: 54,
                                height: 54,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _fallbackCover(),
                              )
                            : _fallbackCover(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              track.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            provider.isBufferingTrack
                                ? Text(
                                    'Descargando pista completa...',
                                    style: TextStyle(
                                      color: SpotifyTheme.primary,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : ArtistClickableText(
                                    artist: track.artist,
                                    avatarUrl: track.artworkUrl,
                                    style: TextStyle(
                                      color: SpotifyTheme.lightGray,
                                      fontSize: 11,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      SpotifyAnimatedHeart(
                        isLiked: provider.isFavorite(track),
                        size: 21,
                        onTap: () => provider.toggleFavorite(track),
                      ),
                    ],
                  ),
          ),

          // 2. Controles centrales + Mini Visualizador Integrado
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        tooltip: provider.isShuffleEnabled ? 'Aleatorio activado' : 'Activar modo aleatorio',
                        icon: Icon(
                          Icons.shuffle,
                          size: 19,
                          color: provider.isShuffleEnabled ? SpotifyTheme.primary : Colors.grey,
                        ),
                        onPressed: provider.toggleShuffle,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        tooltip: 'Anterior',
                        icon: const Icon(Icons.skip_previous, size: 24, color: Colors.white),
                        onPressed: provider.playPrevious,
                      ),
                      provider.isBufferingTrack
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: SpotifyTheme.primary),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  if (provider.isPlaying)
                                    BoxShadow(
                                      color: SpotifyTheme.primary.withValues(alpha: 0.4),
                                      blurRadius: 14,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                tooltip: provider.isPlaying ? 'Pausar' : 'Reproducir',
                                icon: Icon(
                                  provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                  size: 38,
                                  color: Colors.white,
                                ),
                                onPressed: provider.togglePlayPause,
                              ),
                            ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        tooltip: 'Siguiente canción',
                        icon: const Icon(Icons.skip_next, size: 24, color: Colors.white),
                        onPressed: provider.playNext,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        tooltip: repeatTooltip,
                        icon: Icon(repeatIcon, size: 19, color: repeatColor),
                        onPressed: provider.toggleRepeatMode,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDuration(provider.position),
                        style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Mini visualizador fluido sobre la barra
                            if (provider.isVisualizerEnabled && provider.showVisualizerInBottomBar)
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 4,
                                right: 4,
                                child: Opacity(
                                  opacity: 0.35,
                                  child: LiveAudioVisualizer(
                                    height: 16,
                                    isPlaying: provider.isPlaying,
                                    sensitivity: provider.visualizerSensitivity * 0.7,
                                    style: VisualizerStyle.normal,
                                    shape: provider.visualizerShape,
                                    primaryColor: SpotifyTheme.primary,
                                    secondaryColor: provider.lyricsPrimaryColor,
                                  ),
                                ),
                              ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                trackHeight: 3,
                                activeTrackColor: SpotifyTheme.primary,
                                inactiveTrackColor: const Color(0xFF404040),
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: progress,
                                onChanged: (val) {
                                  final newPos = provider.duration * val;
                                  provider.seek(newPos);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(provider.duration),
                        style: TextStyle(color: SpotifyTheme.lightGray, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Letras, Panel Derecho, Visualizador, Volumen y Personalización Spicetify Studio
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: provider.currentTab == 4 ? 'Cerrar letra' : 'Ver letra en vivo',
                  icon: Icon(
                    Icons.lyrics,
                    size: 20,
                    color: provider.currentTab == 4 ? SpotifyTheme.primary : Colors.grey,
                  ),
                  onPressed: () => provider.toggleLyricsView(),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: provider.isRightSidebarOpen ? 'Ocultar panel lateral' : 'Mostrar panel "Sonando ahora"',
                  icon: Icon(
                    Icons.view_sidebar_outlined,
                    size: 20,
                    color: provider.isRightSidebarOpen ? SpotifyTheme.primary : Colors.grey,
                  ),
                  onPressed: () => provider.toggleRightSidebar(),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: provider.isVisualizerEnabled ? 'Visualizador activo' : 'Activar visualizador',
                  icon: Icon(
                    Icons.graphic_eq,
                    size: 20,
                    color: provider.isVisualizerEnabled ? SpotifyTheme.primary : Colors.grey,
                  ),
                  onPressed: () => provider.setVisualizerEnabled(!provider.isVisualizerEnabled),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Modo Burbuja Flotante (Mini Player)',
                  icon: Icon(
                    Icons.picture_in_picture_alt_rounded,
                    size: 20,
                    color: SpotifyTheme.primary,
                  ),
                  onPressed: () => provider.enterMiniBubbleMode(),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Personalización de Interfaz (Spicetify Studio)',
                  icon: Icon(
                    Icons.tune,
                    size: 20,
                    color: SpotifyTheme.primary,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withValues(alpha: 0.65),
                      builder: (context) => const _CustomizationStudioDialog(),
                    );
                  },
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: provider.volume == 0 ? 'Activar sonido' : 'Silenciar',
                  icon: Icon(
                    provider.volume == 0
                        ? Icons.volume_off
                        : (provider.volume < 0.5 ? Icons.volume_down : Icons.volume_up),
                    size: 19,
                    color: provider.volume == 0 ? Colors.redAccent : Colors.grey,
                  ),
                  onPressed: provider.toggleMute,
                ),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 82),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                        trackHeight: 2.5,
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: const Color(0xFF404040),
                      ),
                      child: Slider(
                        value: provider.volume,
                        onChanged: (val) => provider.setVolume(val),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      width: 52,
      height: 52,
      color: SpotifyTheme.darkGray,
      child: const Icon(Icons.music_note, color: Colors.white54),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
