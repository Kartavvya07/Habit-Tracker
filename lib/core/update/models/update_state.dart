import 'package:equatable/equatable.dart';
import 'update_manifest.dart';

/// Sealed hierarchy representing update state transitions.
sealed class UpdateState extends Equatable {
  const UpdateState();

  @override
  List<Object?> get props => [];
}

class UpdateStateIdle extends UpdateState {
  const UpdateStateIdle();
}

class UpdateStateChecking extends UpdateState {
  final bool isManual;
  const UpdateStateChecking({this.isManual = false});

  @override
  List<Object?> get props => [isManual];
}

class UpdateStateAvailable extends UpdateState {
  final UpdateManifest manifest;
  const UpdateStateAvailable(this.manifest);

  @override
  List<Object?> get props => [manifest];
}

class UpdateStateDownloading extends UpdateState {
  final UpdateManifest manifest;
  final double progress; // Range 0.0 to 1.0

  const UpdateStateDownloading(this.manifest, this.progress);

  @override
  List<Object?> get props => [manifest, progress];
}

class UpdateStateInstalling extends UpdateState {
  final UpdateManifest manifest;
  const UpdateStateInstalling(this.manifest);

  @override
  List<Object?> get props => [manifest];
}

class UpdateStateCompleted extends UpdateState {
  final String apkPath;
  const UpdateStateCompleted(this.apkPath);

  @override
  List<Object?> get props => [apkPath];
}

class UpdateStateFailed extends UpdateState {
  final String message;
  const UpdateStateFailed(this.message);

  @override
  List<Object?> get props => [message];
}
