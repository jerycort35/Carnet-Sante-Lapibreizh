import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('rabbits_box');
  runApp(const LapibreizhApp());
}

class LapibreizhApp extends StatelessWidget {
  const LapibreizhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Les Lapibreizh - Carnet de santé',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFC5A059),
        scaffoldBackgroundColor: const Color(0xFFF9F6F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC5A059),
          primary: const Color(0xFFC5A059),
          secondary: const Color(0xFF1E252B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E252B),
          foregroundColor: Color(0xFFC5A059),
          elevation: 4,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box rabbitBox = Hive.box('rabbits_box');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carnet de Santé Lapin',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Serif')),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: rabbitBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'Aucun lapin enregistré.\nCliquez sur + pour ajouter une fiche.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final rabbit = box.getAt(index);
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFC5A059), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFC5A059),
                    backgroundImage: rabbit['photoPath'] != null
                        ? FileImage(File(rabbit['photoPath']))
                        : null,
                    child: rabbit['photoPath'] == null
                        ? const Icon(Icons.pets, color: Colors.white)
                        : null,
                  ),
                  title: Text(rabbit['name'] ?? 'Sans nom',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Sexe: ${rabbit['gender'] ?? 'Non spécifié'}'),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Color(0xFFC5A059)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RabbitDetailScreen(index: index),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC5A059),
        onPressed: () {
          rabbitBox.add({
            'name': 'Nouveau Lapin',
            'gender': 'Mâle',
            'dewormings': [],
            'vaccines': [],
          });
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class RabbitDetailScreen extends StatefulWidget {
  final int index;
  const RabbitDetailScreen({super.key, required this.index});
  @override
  State<RabbitDetailScreen> createState() => _RabbitDetailScreenState();
}

class _RabbitDetailScreenState extends State<RabbitDetailScreen> {
  final Box rabbitBox = Hive.box('rabbits_box');
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    final rabbit = rabbitBox.getAt(widget.index);
    nameController = TextEditingController(text: rabbit['name']);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void shareCard() {
    final rabbit = rabbitBox.getAt(widget.index);
    final message = "Fiche Santé Lapin - Les Lapibreizh\n\n"
        "Nom : ${rabbit['name']}\n"
        "Sexe : ${rabbit['gender']}\n"
        "Derniers vaccins et vermifuges enregistrés dans l'application !";
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    final rabbit = rabbitBox.getAt(widget.index);
    return Scaffold(
      appBar: AppBar(
        title: Text(rabbit['name'] ?? 'Fiche Lapin'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: shareCard),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final image =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image != null) {
                  rabbit['photoPath'] = image.path;
                  await rabbitBox.putAt(widget.index, rabbit);
                  setState(() {});
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFC5A059),
                backgroundImage: rabbit['photoPath'] != null
                    ? FileImage(File(rabbit['photoPath']))
                    : null,
                child: rabbit['photoPath'] == null
                    ? const Icon(Icons.camera_alt,
                        size: 40, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du lapin',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                rabbit['name'] = val;
                rabbitBox.putAt(widget.index, rabbit);
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Vermifuges'),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un Vermifuge'),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Vaccins'),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un Vaccin'),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Documents & Passeport'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Carnet papier'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.badge),
                  label: const Text('Passeport'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E252B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFC5A059),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
