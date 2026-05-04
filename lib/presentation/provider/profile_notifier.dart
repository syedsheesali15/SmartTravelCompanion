import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kName = 'stc_profile_display_name';
const _kEmail = 'stc_profile_email';
const _kAvatarFile = 'stc_profile_avatar_file';
/// Previously stored bundled network avatar; no longer read.
const _kLegacyAvatarUrl = 'stc_profile_avatar_url';

final class ProfileNotifier extends ChangeNotifier {
  static const defaultName = 'Syed Shees Ali';
  static const defaultEmail = 'shees.explore@example.com';

  /// Built-in placeholder when the user has not chosen a gallery photo.
  static const defaultAvatarAsset = 'assets/images/profile_default_avatar.png';

  String _displayName = defaultName;
  String _email = defaultEmail;

  /// Saved copy under app documents when user picks a gallery photo.
  String? _avatarFilePath;

  String get displayName => _displayName;

  String get email => _email;

  ImageProvider<Object> avatarImageProvider() {
    if (!kIsWeb && _avatarFilePath != null) {
      final file = File(_avatarFilePath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return const AssetImage(defaultAvatarAsset);
  }

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_kLegacyAvatarUrl)) {
      await prefs.remove(_kLegacyAvatarUrl);
    }
    final name = prefs.getString(_kName)?.trim();
    final mail = prefs.getString(_kEmail)?.trim();
    _displayName = name == null || name.isEmpty ? defaultName : name;
    _email = mail == null || mail.isEmpty ? defaultEmail : mail;
    _avatarFilePath = prefs.getString(_kAvatarFile);
    notifyListeners();
  }

  Future<void> saveIdentity({
    required String displayName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final name = displayName.trim();
    final mail = email.trim();
    final nameOut = name.isEmpty ? defaultName : name;
    final mailOut = mail.isEmpty ? defaultEmail : mail;
    await prefs.setString(_kName, nameOut);
    await prefs.setString(_kEmail, mailOut);
    _displayName = nameOut;
    _email = mailOut;
    notifyListeners();
  }

  Future<void> savePickedAvatarFile(File pickedFile) async {
    if (kIsWeb) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(p.join(dir.path, 'profile_avatar.jpg'));
    await dest.writeAsBytes(await pickedFile.readAsBytes(), flush: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAvatarFile, dest.path);
    _avatarFilePath = dest.path;
    notifyListeners();
  }

  /// Removes a gallery-saved photo and shows the built-in default avatar.
  Future<void> resetAvatarToDefault() async {
    if (_avatarFilePath != null && !kIsWeb) {
      try {
        final f = File(_avatarFilePath!);
        if (f.existsSync()) await f.delete();
      } catch (_) {}
    }
    _avatarFilePath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAvatarFile);
    notifyListeners();
  }
}
