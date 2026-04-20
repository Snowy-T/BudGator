import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/app_local_storage.dart';

enum AppLanguagePreference { system, de, en, it, es }

extension AppLanguagePreferenceX on AppLanguagePreference {
  String get storageValue => name;

  Locale? get locale {
    return switch (this) {
      AppLanguagePreference.system => null,
      AppLanguagePreference.de => const Locale('de'),
      AppLanguagePreference.en => const Locale('en'),
      AppLanguagePreference.it => const Locale('it'),
      AppLanguagePreference.es => const Locale('es'),
    };
  }

  static AppLanguagePreference fromStorageValue(String raw) {
    for (final value in AppLanguagePreference.values) {
      if (value.storageValue == raw) return value;
    }
    return AppLanguagePreference.system;
  }
}

final appLanguageProvider =
    StateNotifierProvider<AppLanguageController, AppLanguagePreference>((ref) {
      return AppLanguageController(ref.read(localStorageProvider));
    });

class AppLanguageController extends StateNotifier<AppLanguagePreference> {
  AppLanguageController(this._storage)
    : super(
        AppLanguagePreferenceX.fromStorageValue(_storage.loadAppLanguage()),
      );

  final AppLocalStorage _storage;

  Future<void> setPreference(AppLanguagePreference preference) async {
    state = preference;
    if (preference == AppLanguagePreference.system) {
      await _storage.resetAppLanguage();
      return;
    }
    await _storage.saveAppLanguage(preference.storageValue);
  }
}
