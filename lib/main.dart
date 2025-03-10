import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'user_list.dart'; // Import the new feature
import 'Auth.dart'; // Import the new authentication page

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
      home: const AuthGate(), // Redirect to authentication page first
    );
  }
}

// Handles user authentication
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const SearchPage(); // If authenticated, go to main page
        } else {
          return const AuthPage(); // Otherwise, show login page
        }
      },
    );
  }
}

class AddUser {
  final String RestaurantName;
  final String Adress;
  final int Number;
  final String googleName;

  AddUser(this.RestaurantName, this.Adress, this.Number, this.googleName);

  Future<void> addUser() async {
    CollectionReference users = FirebaseFirestore.instance.collection('searches');

    try {
      DocumentReference docRef = await users.add({
        'Restaurant_Name': RestaurantName,
        'Adress': Adress,
        'Number': Number,
        'google_name': googleName,
      });
      print("User Added with ID: ${docRef.id}");
    } catch (error) {
      print("Failed to add user: $error");
    }
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _searchQuery = '';

  // Function to handle logout
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate back to the authentication page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fullNameController.dispose();
    _companyController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String googleName = user?.displayName ?? 'Unknown';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('BiteBuddy'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(255, 116, 128, 215),
                      const Color.fromARGB(255, 124, 139, 223),
                    ],
                  ),
                ),
              ),
            ),
            // Add a logout button to the right side of the app bar
            
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 30,),
                onPressed: () => _logout(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Add User section
                  const Text(
                    'Add User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Restaurant Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Get the current values from the text fields
                      String fullName = _fullNameController.text;
                      String company = _companyController.text;
                      int age = int.tryParse(_ageController.text) ?? 0;

                      // Call the AddUser function with the current values
                      AddUser(fullName, company, age, googleName).addUser();
                    },
                    child: const Text("Search"),
                  ),
                  const SizedBox(height: 30),

                  // Display all users from Firestore
                  const UserList(), // Use the new feature here
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}