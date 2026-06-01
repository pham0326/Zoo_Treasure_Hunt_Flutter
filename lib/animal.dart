// lib/animal.dart
// Dart port of the Kotlin `Sighting` data class from the Android app.
// Migration note: Kotlin's `data class` auto-generates copyWith (copy),
// equality, hashCode and toString. Dart has no equivalent keyword, so these
// are written by hand. fromJson/toJson replace Kotlin's kotlinx.serialization
// / manual JSON handling used in FileSightingRepository.

class Animal {
  final String name;
  final bool isFound;
  final String notes;
  final int timestamp;
  final String imageUrl;
  final String? photoPath;
  final double latitude;
  final double longitude;

  const Animal({
    required this.name,
    this.isFound = false,
    this.notes = '',
    required this.timestamp,
    required this.imageUrl,
    this.photoPath,
    required this.latitude,
    required this.longitude,
  });

  // Equivalent of Kotlin's data class .copy(...)
  Animal copyWith({
    String? name,
    bool? isFound,
    String? notes,
    int? timestamp,
    String? imageUrl,
    String? photoPath,
    double? latitude,
    double? longitude,
  }) {
    return Animal(
      name: name ?? this.name,
      isFound: isFound ?? this.isFound,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // Equivalent of serializing the Kotlin data class to JSON for persistence.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isFound': isFound,
      'notes': notes,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'photoPath': photoPath,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Equivalent of deserializing JSON back into the data class.
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      name: json['name'] as String,
      isFound: json['isFound'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
      timestamp: json['timestamp'] as int,
      imageUrl: json['imageUrl'] as String,
      photoPath: json['photoPath'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
