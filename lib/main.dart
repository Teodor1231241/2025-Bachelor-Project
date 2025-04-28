import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'user_list.dart';
import 'Auth.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bite Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const SearchPage();
        } else {
          return const AuthPage();
        }
      },
    );
  }
}

class AddUser {
  final String restaurantName;
  final String address;
  final String language;
  final String googleName;
  final String googleUserPhoto;
  final int updated;

  AddUser(
    this.restaurantName,
    this.address,
    this.language,
    this.googleName,
    this.googleUserPhoto,
    this.updated,
  );

  Future<void> addUser() async {
    CollectionReference users = FirebaseFirestore.instance.collection('searches');
    try {
      // Debug print to verify all fields
      print('Saving to Firestore: {'
          'Restaurant_Name: $restaurantName, '
          'Adress: $address, '
          'Language: $language, '
          'google_name: $googleName, '
          'google_user_photo: $googleUserPhoto, '
          'updated: $updated}');

      DocumentReference docRef = await users.add({
        'Restaurant_Name': restaurantName,
        'Adress': address,
        'Language': language,
        'google_name': googleName,
        'google_user_photo': googleUserPhoto.isEmpty 
            ? 'https://via.placeholder.com/150'  // Ensure non-empty value
            : googleUserPhoto,
        'Updated': updated,
      });
      
      // Verify document creation
      print('Document created with ID: ${docRef.id}');
      DocumentSnapshot doc = await docRef.get();
      print('Saved data: ${doc.data()}');

    } catch (error) {
      print("Failed to add user: $error");
      rethrow;
    }
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _restaurantNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedLanguage;
  Timer? _timer;
  int _currentTextIndex = 0;
  
  final List<String> _languages = ['românește', 'english', 'español', 'français', 'deutsch'];
  final List<String> _animatedTexts = [
    'Să aflăm ceva',
    'Let\'s find out something',
    'Vamos a descubrir algo',
    'Let\'s find out something',
    'Découvrons quelque chose',
    'Să aflăm ceva',
    'Lass uns etwas herausfinden'
  ];
  
  final List<List<String>> _formTexts = [
    ['Despre restaurantul', 'situat în', 'în'],
    ['About the restaurant', 'located in', 'in'],
    ['Sobre el restaurante', 'ubicado en', 'en'],
    ['About the restaurant', 'located in', 'in'],
    ['À propos du restaurant', 'situé à', 'en'],
    ['Despre restaurantul', 'situat în', 'în'],
    ['Über das Restaurant', 'gelegen in', 'in'],
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _currentTextIndex = (_currentTextIndex + 1) % _animatedTexts.length;
      });
    });
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _restaurantNameController.clear();
    _addressController.clear();
    setState(() => _selectedLanguage = null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restaurantNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedText(String text) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Text(
        text,
        key: ValueKey<String>(text),
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String googleName = user?.displayName ?? 'Unknown';
    final String googleUserPhoto = user?.photoURL ?? '';
    final int updated = 402;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Bite Buddy'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 116, 128, 215),
                      Color.fromARGB(255, 124, 139, 223),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 30),
                onPressed: () => _logout(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -1),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            )),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _animatedTexts[_currentTextIndex],
                          key: ValueKey<int>(_currentTextIndex),
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildFormRow(),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await AddUser(
                                _restaurantNameController.text.trim(),
                                _addressController.text.trim(),
                                _selectedLanguage ?? 'English',
                                googleName,
                                googleUserPhoto,
                                updated,
                              ).addUser();
                              _clearForm();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error saving: $e')),
                              );
                            }
                          }
                        },
                        child: const Text("Save Restaurant"),
                      ),
                      const SizedBox(height: 50),
                      const UserList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedText(_formTexts[_currentTextIndex][0]),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: TextFormField(
                controller: _restaurantNameController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  border: UnderlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 8),
            _buildAnimatedText(_formTexts[_currentTextIndex][1]),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'City',
                  border: UnderlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 8),
            _buildAnimatedText(_formTexts[_currentTextIndex][2]),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: DropdownButtonFormField<String>(
                value: _selectedLanguage,
                hint: const Text('Language'),
                items: _languages
                    .map((lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedLanguage = value),
              ),
            ),
          ],
        ),
      ],
    );
  }
}