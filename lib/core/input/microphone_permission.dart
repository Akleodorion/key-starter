import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Accès à la permission micro du système.
///
/// Contrat :
/// - [isGranted] dit si le micro est autorisé, sans rien demander ;
/// - [requestOnFirstLaunch] affiche la demande système une seule fois dans la
///   vie de l'app, puis ne fait plus que relire l'état ;
/// - [openSettings] ouvre les réglages de l'app, pour l'autoriser après un refus.
///
/// ```dart
/// class AlwaysGrantedMicrophonePermission implements MicrophonePermission {
///   @override
///   Future<bool> isGranted() async => true;
///   @override
///   Future<bool> requestOnFirstLaunch() async => true;
///   @override
///   Future<void> openSettings() async {}
/// }
/// ```
///
/// Voir aussi : [SystemMicrophonePermission].
abstract class MicrophonePermission {
  /// Le micro est-il autorisé ?
  Future<bool> isGranted();

  /// Demande l'autorisation au premier lancement ; renvoie l'état obtenu.
  Future<bool> requestOnFirstLaunch();

  /// Ouvre les réglages système de l'app.
  Future<void> openSettings();
}

/// Implémentation de [MicrophonePermission] avec `permission_handler`.
class SystemMicrophonePermission implements MicrophonePermission {
  static const _alreadyAskedKey = 'microphone_permission_asked';

  @override
  Future<bool> isGranted() async {
    try {
      return await Permission.microphone.isGranted;
    } catch (_) {
      return false; // plateforme sans permission micro
    }
  }

  @override
  Future<bool> requestOnFirstLaunch() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (preferences.getBool(_alreadyAskedKey) ?? false) return isGranted();
      await preferences.setBool(_alreadyAskedKey, true);
      return (await Permission.microphone.request()).isGranted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
