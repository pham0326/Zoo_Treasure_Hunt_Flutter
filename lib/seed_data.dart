// lib/seed_data.dart
// The five starter animals, ported from the Kotlin
// FileSightingRepository.getDefaultSightings().
// Coordinates are spread across the Adelaide Zoo / Botanic Park area,
// each at least ~100m apart, matching the Android app so the GPS-style
// proximity logic remains meaningful.

import 'animal.dart';

List<Animal> getDefaultAnimals() {
  final now = DateTime.now().millisecondsSinceEpoch;

  return [
    Animal(
      name: 'Lion',
      timestamp: now,
      imageUrl:
          'https://wilk0077.github.io/comp2012-images/assets-sm/african-lion-ai.jpg',
      latitude: -34.9142,
      longitude: 138.6056,
    ),
    Animal(
      name: 'Red Panda',
      timestamp: now,
      imageUrl:
          'https://wilk0077.github.io/comp2012-images/assets-sm/red-panda-ai.jpg',
      latitude: -34.9176,
      longitude: 138.6068,
    ),
    Animal(
      name: 'Giraffe',
      timestamp: now,
      imageUrl:
          'https://wilk0077.github.io/comp2012-images/assets-sm/giraffe-ai.jpg',
      latitude: -34.9133,
      longitude: 138.6042,
    ),
    Animal(
      name: 'Kangaroo',
      timestamp: now,
      imageUrl:
          'https://wilk0077.github.io/comp2012-images/assets-sm/red-kangaroo-ai.jpg',
      latitude: -34.9159,
      longitude: 138.6020,
    ),
    Animal(
      name: 'Penguin',
      timestamp: now,
      imageUrl:
          'https://wilk0077.github.io/comp2012-images/assets-sm/penguin-ai.jpg',
      latitude: -34.9120,
      longitude: 138.6075,
    ),
  ];
}
