import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class UserList extends StatelessWidget {
  const UserList({super.key});

  // Function to fetch first photo from Unsplash based on restaurant name with random page
  Future<String> _fetchCoverPhoto(String restaurantName, int index) async {
    try {
      final randomPage = Random().nextInt(10) + 1; // Random page between 1-10
      final response = await http.get(
        Uri.parse('https://api.unsplash.com/search/photos?page=$randomPage&query=$restaurantName restaurant&client_id=QypFFqHbs4Y7YgEq7WM54sUYc6f9Gt0DAYFmErkK1vc'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          // Use index to select different photo from results
          final resultIndex = min(index, data['results'].length - 1);
          return data['results'][resultIndex]['urls']['regular'];
        }
      }
      return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80';
    } catch (e) {
      return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80';
    }
  }

  // Function to fetch 10 random restaurant photos from Unsplash with random page
  Future<List<String>> _fetchRestaurantPhotos(int index) async {
    try {
      final randomPage = Random().nextInt(10) + 1; // Random page between 1-10
      final response = await http.get(
        Uri.parse('https://api.unsplash.com/search/photos?page=$randomPage&per_page=10&query=restaurant&client_id=QypFFqHbs4Y7YgEq7WM54sUYc6f9Gt0DAYFmErkK1vc'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          // Shuffle the results to get different photos for each card
          final results = List.from(data['results']);
          results.shuffle();
          return List<String>.from(results.map((photo) => photo['urls']['regular']));
        }
      }
      return List.filled(10, 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');
    } catch (e) {
      return List.filled(10, 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Searches',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('searches')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No users found.'));
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userData = users[index].data() as Map<String, dynamic>;
                final isProcessing = userData['Updated'] == 402;

                // Timestamp handling
                final Timestamp? timestamp = userData['timestamp'];
                final DateTime? date = timestamp?.toDate();
                final String formattedTime = date != null 
                    ? DateFormat('HH:mm - dd:MM:yyyy').format(date)
                    : 'No timestamp';

                // Profile photo handling
                String profilePhotoUrl = userData['google_user_photo'] ?? '';
                profilePhotoUrl = profilePhotoUrl.isNotEmpty
                    ? profilePhotoUrl.replaceFirst('=s96-c', '=s200-c')
                    : '';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 3,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 139, 131),
                          Color.fromARGB(255, 137, 202, 255)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: profilePhotoUrl.isNotEmpty
                                    ? NetworkImage(profilePhotoUrl)
                                    : const NetworkImage(
                                        '/web/user_logo.png'),
                                radius: 20,
                                onBackgroundImageError: (_, __) =>
                                    const Icon(Icons.error),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: userData['google_name'] ?? 'Unknown User',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(text: ' found about the '),
                                      TextSpan(
                                        text: userData['Restaurant_Name'] ??
                                            'Unknown Restaurant',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(text: ' from '),
                                      TextSpan(
                                        text: userData['Adress'] ?? 'Unknown Address',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(text: ' that:'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          if (isProcessing)
                            const Center(
                                child: Text('Still processing...',
                                    style: TextStyle(fontSize: 16)))
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<String>(
                                  future: _fetchCoverPhoto(userData['Restaurant_Name'] ?? 'restaurant', index),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const SizedBox(
                                        height: 200,
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    }
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        snapshot.data ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  userData['Restaurant_Name'] ??
                                      'Unknown Restaurant',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FutureBuilder<List<String>>(
                                  future: _fetchRestaurantPhotos(index),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const SizedBox(
                                        height: 100,
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    }
                                    return SizedBox(
                                      height: 100,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data?.length ?? 0,
                                        itemBuilder: (context, photoIndex) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Image.network(
                                              snapshot.data?[photoIndex] ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons.broken_image),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          const SizedBox(height: 15),

                          if (!isProcessing)
                            Text(
                              userData['review'] ?? 'No review available',
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}