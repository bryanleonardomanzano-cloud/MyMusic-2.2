/// Repositorio implementa [PlayerDataSource] usando [just_audio].
/// Encapsula la dependencia de Flutter/just_audio para aislarla
/// de la lógica domain pura.
import 'dart:async';

import 'package:just_audio/just_audio.dart' as ja;

import 'package:mymusic/features/player/data/player_data_source.dart';
import 'package:mymusic/features/player/domain/player_state.dart';

class PlayerRepository implements PlayerDataSource {
  /// Instancia de just_audio
  final _player = ja.AudioPlayer();

  /// Stream controller para emitir estados propios
  final _stateController = StreamController<PlayerState>.broadcast();

  String? _currentTrack;
  String? _currentArtist;
  List<String> _currentPlaylist = const [];

  @override
  Stream<PlayerState> get stateStream => _stateController.stream;

  void _emit(PlayerState state) {
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  PlayerState _currentPlayingState({int? positionOverride}) {
    final dur = _player.duration?.inMilliseconds ?? 0;
    final pos = positionOverride ?? _player.position.inMilliseconds;
    return PlayerState.playing(
      currentTrack: _currentTrack ?? 'Track',
      duration: dur,
      position: pos,
      artist: _currentArtist,
      playlist: _currentPlaylist,
    );
  }

  PlayerState _currentPausedState({int? positionOverride}) {
    final dur = _player.duration?.inMilliseconds ?? 0;
    final pos = positionOverride ?? _player.position.inMilliseconds;
    return PlayerState.paused(
      currentTrack: _currentTrack ?? 'Track',
      duration: dur,
      position: pos,
      artist: _currentArtist,
      playlist: _currentPlaylist,
    );
  }

  @override
  Future<PlayerState> loadTrack({
    required String trackId,
    required String title,
    required String artist,
    required int duration,
    required List<String> playlist,
    int initialPosition = 0,
    String? sourceUrl,
    Map<String, String>? headers,
  }) async {
    try {
      _currentTrack = title;
      _currentArtist = artist;
      _currentPlaylist = playlist;

      await _player.stop();

      if (sourceUrl != null && sourceUrl.isNotEmpty) {
        await _player.setUrl(sourceUrl, headers: headers);
        if (initialPosition > 0) {
          await _player.seek(Duration(milliseconds: initialPosition));
        }
        await _player.play();
      }

      final effectiveDuration = _player.duration?.inMilliseconds ?? duration;
      final state = PlayerState.playing(
        currentTrack: title,
        duration: effectiveDuration,
        position: initialPosition,
        artist: artist,
        playlist: playlist,
      );
      _emit(state);
      return state;
    } catch (e) {
      final errorState = PlayerState.error(message: 'Error al cargar pista: $e');
      _emit(errorState);
      return errorState;
    }
  }

  @override
  Future<PlayerState> togglePause() async {
    try {
      if (_player.playing) {
        await _player.pause();
        final pausedState = _currentPausedState();
        _emit(pausedState);
        return pausedState;
      } else {
        if (_currentTrack != null) {
          await _player.play();
          final playingState = _currentPlayingState();
          _emit(playingState);
          return playingState;
        }
        final initialState = PlayerState.initial;
        _emit(initialState);
        return initialState;
      }
    } catch (e) {
      final errorState = PlayerState.error(message: 'Error al alternar pausa: $e');
      _emit(errorState);
      return errorState;
    }
  }

  @override
  Future<PlayerState> seek({required int position}) async {
    try {
      await _player.seek(Duration(milliseconds: position));
      final state = _player.playing
          ? _currentPlayingState(positionOverride: position)
          : _currentPausedState(positionOverride: position);
      _emit(state);
      return state;
    } catch (e) {
      final errorState = PlayerState.error(message: 'Error al buscar: $e');
      _emit(errorState);
      return errorState;
    }
  }

  @override
  Future<PlayerState> stop() async {
    try {
      await _player.stop();
      final initialState = PlayerState.initial;
      _emit(initialState);
      return initialState;
    } catch (e) {
      final errorState = PlayerState.error(message: 'Error al detener: $e');
      _emit(errorState);
      return errorState;
    }
  }

  @override
  Future<PlayerState> updateMetadata({
    required String title,
    required String artist,
    required int duration,
  }) async {
    _currentTrack = title;
    _currentArtist = artist;
    final state = _player.playing
        ? _currentPlayingState()
        : _currentPausedState();
    _emit(state);
    return state;
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
    await _player.dispose();
  }
}