// lib/main.dart
// Entry point + list screen for the Flutter port of Zoo Treasure Hunt.
// Migration notes:
//  - Compose ListScreen -> StatefulWidget; LazyColumn -> ListView.builder;
//    remember/mutableStateOf -> setState.
//  - Persistence via AnimalRepository (shared_preferences), replacing the
//    Kotlin FileSightingRepository JSON-file approach.
//  - Camera: the Kotlin app used ActivityResultContracts.TakePicture() with
//    FileProvider + file_paths.xml + manual CAMERA permission. Here the
//    image_picker plugin collapses all of that into a single async call
//    (_picker.pickImage). The returned XFile.path is stored on the Animal
//    and shown as the card thumbnail via Image.file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'animal.dart';
import 'animal_repository.dart';

void main() {
  runApp(const ZooApp());
}

class ZooApp extends StatelessWidget {
  const ZooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zoo Treasure Hunt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ListScreen(),
    );
  }
}

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final AnimalRepository _repository = AnimalRepository();
  final ImagePicker _picker = ImagePicker();

  List<Animal> _animals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    final loaded = await _repository.loadAnimals();
    setState(() {
      _animals = loaded;
      _isLoading = false;
    });
  }

  void _toggleFound(int index) {
    setState(() {
      _animals[index] = _animals[index].copyWith(
        isFound: !_animals[index].isFound,
      );
    });
    _repository.saveAnimals(_animals);
  }

  Future<void> _capturePhoto(int index) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo == null) return;

    setState(() {
      _animals[index] = _animals[index].copyWith(
        photoPath: photo.path,
        isFound: true,
      );
    });
    _repository.saveAnimals(_animals);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Great! You captured the ${_animals[index].name}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foundCount = _animals.where((a) => a.isFound).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoo Treasure Hunt'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Found $foundCount of ${_animals.length} animals',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _animals.length,
                    itemBuilder: (context, index) {
                      final animal = _animals[index];
                      return AnimalCard(
                        animal: animal,
                        onTap: () => _toggleFound(index),
                        onCapture: () => _capturePhoto(index),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;
  final VoidCallback onCapture;

  const AnimalCard({
    super.key,
    required this.animal,
    required this.onTap,
    required this.onCapture,
  });

  Widget _buildThumbnail() {
    if (animal.photoPath != null) {
      return Image.file(
        File(animal.photoPath!),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.pets, size: 56),
      );
    }
    return Image.network(
      animal.imageUrl,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.pets, size: 56),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildThumbnail(),
        ),
        title: Text(animal.name),
        subtitle: Text(animal.isFound ? 'FOUND!' : 'Not found yet'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.camera_alt),
              tooltip: 'Capture photo',
              onPressed: onCapture,
            ),
            Icon(
              animal.isFound ? Icons.check_circle : Icons.circle_outlined,
              color: animal.isFound ? Colors.green : Colors.grey,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
