import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';

class LocalAuth {
  LocalAuth._();
  static final LocalAuth instance = LocalAuth._();

  static const _kEmail = 'auth.email';
  static const _kName  = 'auth.name';
  static const _kHash  = 'auth.pw_hash';
  static const _kLoggedIn = 'auth.logged_in';

  final _sec = const FlutterSecureStorage();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<bool> hasAccount() async {
    final email = await _sec.read(key: _kEmail);
    final hash  = await _sec.read(key: _kHash);
    return email != null && hash != null;
  }

  Future<void> signUp({
    required String email,
    required String displayName,
    required String password,
  }) async {
    final salt = BCrypt.gensalt();
    final hash = BCrypt.hashpw(password, salt);

    await _sec.write(key: _kEmail, value: email.trim());
    await _sec.write(key: _kName,  value: displayName.trim());
    await _sec.write(key: _kHash,  value: hash);

    final p = await _prefs;
    await p.setBool(_kLoggedIn, true);
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final savedEmail = await _sec.read(key: _kEmail);
    final savedHash  = await _sec.read(key: _kHash);
    if (savedEmail == null || savedHash == null) return false;

    final ok = (email.trim() == savedEmail) && BCrypt.checkpw(password, savedHash);
    if (ok) {
      final p = await _prefs;
      await p.setBool(_kLoggedIn, true);
    }
    return ok;
  }

  Future<void> signOut() async {
    final p = await _prefs;
    await p.setBool(_kLoggedIn, false);
  }

  Future<void> deleteAccount() async {
    await _sec.delete(key: _kEmail);
    await _sec.delete(key: _kName);
    await _sec.delete(key: _kHash);
    final p = await _prefs;
    await p.setBool(_kLoggedIn, false);
  }

  Future<bool> isLoggedIn() async {
    final p = await _prefs;
    return p.getBool(_kLoggedIn) ?? false;
  }

  Future<String?> currentEmail() => _sec.read(key: _kEmail);
  Future<String?> currentName()  => _sec.read(key: _kName);

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    final savedHash = await _sec.read(key: _kHash);
    if (savedHash == null) throw Exception('No account found');
    if (!BCrypt.checkpw(currentPassword, savedHash)) {
      throw Exception('Current password is incorrect');
    }
    final salt = BCrypt.gensalt();
    final newHash = BCrypt.hashpw(newPassword, salt);
    await _sec.write(key: _kHash, value: newHash);
  }
}
