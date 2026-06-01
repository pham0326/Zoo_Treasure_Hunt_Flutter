// lib/main.dart
// Entry point + list screen for the Flutter port of Zoo Treasure Hunt.
// Migration notes:
//  - Compose's @Composable ListScreen becomes a StatefulWidget.
//  - LazyColumn { items(...) } becomes ListView.builder.
//  - remember { mutableStateOf(...) } becomes State fields + setState(...).
//  - Persistence now goes through AnimalRepository (shared_preferences),
//    replacing the Kotlin FileSightingRepository's JSON-file approach.
//  - Loading from storage is asynchronous (a Future), so the screen shows
//    a loading spinner until the saved data arrives. In Compose this would
//    be a LaunchedEffect + loading state; here it's an async load in
//    initState driving setState.

import 'package:flutter/material.dart';
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

  const AnimalCard({super.key, required this.animal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            animal.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.pets, size: 56),
          ),
        ),
        title: Text(animal.name),
        subtitle: Text(animal.isFound ? 'FOUND!' : 'Not found yet'),
        trailing: Icon(
          animal.isFound ? Icons.check_circle : Icons.circle_outlined,
          color: animal.isFound ? Colors.green : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
