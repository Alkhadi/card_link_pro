// title=lib/services/preferences_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

/// Service for persisting and restoring the user's profile via SharedPreferences.
class PreferencesService {
  static const String _profileKey = 'cardlink_profile';

  Future<Profile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profileKey);
    if (jsonString == null || jsonString.isEmpty) {
      return Profile.defaultProfile();
    }
    try {
      final Map<String, dynamic> map =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return Profile.fromMap(map);
    } catch (_) {
      return Profile.defaultProfile();
    }
  }

  Future<void> saveProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(profile.toMap());
    await prefs.setString(_profileKey, jsonString);
  }
}
