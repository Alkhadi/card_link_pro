import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/profile.dart';

/// A simple persistent store for the profile using Hive.
/// Stores a single JSON-encoded profile in a Hive box.
class ProfileStore extends ChangeNotifier {
  static const _boxName = 'cardlink_profile_box';
  static const _key = 'profile_json';

  late Box _box;
  Profile _profile = Profile.defaultProfile();

  Profile get profile => _profile;

  /// Initialize Hive and load the profile if previously saved.
  static Future<ProfileStore> ensureReady() async {
    await Hive.initFlutter();
    final store = ProfileStore();
    store._box = await Hive.openBox(_boxName);
    final json = store._box.get(_key) as String?;
    if (json != null) {
      try {
        store._profile = Profile.fromJson(json);
      } catch (_) {
        store._profile = Profile.defaultProfile();
      }
    }
    return store;
  }

  /// Save the given profile and notify listeners.
  Future<void> save(Profile p) async {
    _profile = p;
    await _box.put(_key, p.toJson());
    notifyListeners();
  }

  /// Reset the profile to the default values.
  Future<void> resetToDefault() async {
    await save(Profile.defaultProfile());
  }
}
