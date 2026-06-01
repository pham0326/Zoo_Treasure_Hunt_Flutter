// lib/animal_repository.dart
// Persistence layer, ported from the Kotlin FileSightingRepository.
// Migration note:
// Kotlin wrote a JSON file to context.filesDir and managed the file
// handle, read/write, and serialization manually.
// Here, shared_preferences stores a single JSON string under one key.
//    The plugin decides where the data physically lives on each platform
//    (SharedPreferences on Android, NSUserDefaults on iOS, etc.), so the
//    same Dart code persists data on every target platform.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'animal.dart';
import 'seed_data.dart';

class AnimalRepository {
  static const String _storageKey = 'animals_json';
  Future<List<Animal>> loadAnimals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      return getDefaultAnimals();
    }

    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => Animal.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAnimals(List<Animal> animals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(animals.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
