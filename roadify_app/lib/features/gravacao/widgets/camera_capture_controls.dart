import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../coleta/viewmodels/coleta_viewmodel.dart';

class CameraCaptureControls extends StatelessWidget {
  final CameraMediaType mediaType;
  final bool isVideoRecording;
  final bool isBusy;
  final Duration videoElapsed;
  final int videoDurationSeconds;
  final String? errorMessage;
  final VoidCallback onTakePhoto;
  final VoidCallback onToggleVideo;

  const CameraCaptureControls({
    super.key,
    required this.mediaType,
    required this.isVideoRecording,
    required this.isBusy,
    required this.videoElapsed,
    required this.videoDurationSeconds,
    required this.errorMessage,
    required this.onTakePhoto,
    required this.onToggleVideo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(errorMessage!, style: TextStyle(color: colors.error)),
          ),
        if (isVideoRecording) ...[
          Row(
            children: [
              Icon(Icons.fiber_manual_record, size: 15, color: colors.error),
              const SizedBox(width: 6),
              Text(
                'VÍDEO • ${videoElapsed.inSeconds}s / $videoDurationSeconds s',
                key: const ValueKey('video-recording-duration'),
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (mediaType == CameraMediaType.photos)
          _CaptureButton(
            key: const ValueKey('botao-capturar-foto'),
            icon: Icons.camera_alt_rounded,
            label: AppLocalizations.of(context)!.text('takeRoadPhoto'),
            detail: AppLocalizations.of(context)!.text('incidentImage'),
            onPressed: !isBusy && !isVideoRecording ? onTakePhoto : null,
          )
        else if (mediaType == CameraMediaType.videos)
          _CaptureButton(
            key: const ValueKey('botao-gravar-video'),
            icon: isVideoRecording
                ? Icons.stop_rounded
                : Icons.videocam_rounded,
            label: isVideoRecording ? AppLocalizations.of(context)!.text('finishVideo') : AppLocalizations.of(context)!.text('recordVideo'),
            detail: 'Duração máxima: $videoDurationSeconds segundos',
            isRecording: isVideoRecording,
            onPressed: !isBusy ? onToggleVideo : null,
          )
        else
          Row(
            children: [
              Expanded(
                child: _CaptureButton(
                  key: const ValueKey('botao-capturar-foto'),
                  icon: Icons.camera_alt_rounded,
                  label: 'FOTO',
                  detail: 'Registrar imagem',
                  onPressed: !isBusy && !isVideoRecording ? onTakePhoto : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CaptureButton(
                  key: const ValueKey('botao-gravar-video'),
                  icon: isVideoRecording
                      ? Icons.stop_rounded
                      : Icons.videocam_rounded,
                  label: isVideoRecording ? AppLocalizations.of(context)!.text('stopVideo') : AppLocalizations.of(context)!.text('video'),
                  detail: isVideoRecording
                      ? AppLocalizations.of(context)!.text('tapToSave')
                      : 'Máx. $videoDurationSeconds s',
                  isRecording: isVideoRecording,
                  onPressed: !isBusy ? onToggleVideo : null,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback? onPressed;
  final bool isRecording;

  const _CaptureButton({
    super.key,
    required this.icon,
    required this.label,
    required this.detail,
    required this.onPressed,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = isRecording ? colors.error : colors.primary;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: isRecording ? colors.onError : colors.onPrimary,
        padding: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(detail, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
