import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class RecordedMediaItem {
  final int id;
  final String type;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final double odometerKm;
  final String filePath;

  const RecordedMediaItem({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.odometerKm,
    required this.filePath,
  });

  String get label => switch (type) {
    'photo' => 'Foto',
    'video' => 'Vídeo',
    'audio' => 'Áudio',
    _ => 'Mídia',
  };

  IconData get icon => switch (type) {
    'photo' => Icons.photo_camera_rounded,
    'video' => Icons.videocam_rounded,
    'audio' => Icons.mic_rounded,
    _ => Icons.attach_file_rounded,
  };
}

class RecordedMediaPreviewDialog extends StatefulWidget {
  final RecordedMediaItem media;

  const RecordedMediaPreviewDialog({super.key, required this.media});

  @override
  State<RecordedMediaPreviewDialog> createState() =>
      _RecordedMediaPreviewDialogState();
}

class _RecordedMediaPreviewDialogState
    extends State<RecordedMediaPreviewDialog> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  Future<void>? _initialization;
  Object? _playbackError;

  @override
  void initState() {
    super.initState();
    if (widget.media.type == 'video') {
      final controller = VideoPlayerController.file(
        File(widget.media.filePath),
      );
      _videoController = controller;
      _initialization = controller
          .initialize()
          .then((_) {
            if (mounted) setState(() {});
          })
          .catchError((Object error) {
            _playbackError = error;
            if (mounted) setState(() {});
          });
    } else if (widget.media.type == 'audio') {
      final player = AudioPlayer();
      _audioPlayer = player;
      _initialization = player
          .setFilePath(widget.media.filePath)
          .then((_) {
            if (mounted) setState(() {});
          })
          .catchError((Object error) {
            _playbackError = error;
            if (mounted) setState(() {});
          });
    }
  }

  @override
  void dispose() {
    final video = _videoController;
    if (video != null) unawaited(video.dispose());
    final audio = _audioPlayer;
    if (audio != null) unawaited(audio.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    final time =
        '${media.timestamp.hour.toString().padLeft(2, '0')}:'
        '${media.timestamp.minute.toString().padLeft(2, '0')}:'
        '${media.timestamp.second.toString().padLeft(2, '0')}';

    return AlertDialog(
      title: Text('${media.label} #${media.id}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (media.type == 'photo')
              Image.file(
                File(media.filePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 140,
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                ),
              )
            else if (media.type == 'video' || media.type == 'audio')
              _playbackControls(),
            const SizedBox(height: 12),
            Text(
              media.latitude == null || media.longitude == null
                  ? 'GPS: indisponível'
                  : 'GPS: ${media.latitude!.toStringAsFixed(6)}, '
                        '${media.longitude!.toStringAsFixed(6)}',
            ),
            Text(
              'Quilometragem estimada: ${media.odometerKm.toStringAsFixed(2)} km',
            ),
            Text('Horário: $time'),
            const SizedBox(height: 6),
            Text(
              media.filePath.split(Platform.pathSeparator).last,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _playbackControls() {
    if (_playbackError != null) {
      return Text('Não foi possível abrir o arquivo: $_playbackError');
    }

    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Não foi possível abrir o arquivo: ${snapshot.error}');
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final video = _videoController;
        if (video != null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: video.value.aspectRatio,
                child: VideoPlayer(video),
              ),
              IconButton(
                key: const ValueKey('toggle-video-playback'),
                onPressed: () {
                  if (video.value.isPlaying) {
                    video.pause();
                  } else {
                    video.play();
                  }
                  setState(() {});
                },
                icon: Icon(
                  video.value.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                ),
              ),
            ],
          );
        }

        final player = _audioPlayer!;
        return StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data?.playing ?? false;
            return Center(
              child: IconButton.filled(
                key: const ValueKey('toggle-audio-playback'),
                onPressed: () => isPlaying ? player.pause() : player.play(),
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
