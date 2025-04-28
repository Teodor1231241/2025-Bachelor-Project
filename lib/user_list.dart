import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserList extends StatelessWidget {
  const UserList({super.key});

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
          stream: FirebaseFirestore.instance.collection('searches').snapshots(),
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
                final user = users[index].data() as Map<String, dynamic>;
              
                final color = index % 2 == 0 ? Color(0xFFC6667A) : Color(0xFF4795E4);
                final isProcessing = user['Updated'] == 402;

                return Card(
                  color: color,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildProfileImage(user),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: user['google_name'] ?? 'Unknown User',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const TextSpan(text: ' found about the '),
                                    TextSpan(
                                      text: user['Restaurant_Name'] ?? 'Unknown Restaurant',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const TextSpan(text: ' from '),
                                    TextSpan(
                                      text: user['Adress'] ?? 'Unknown Address',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const TextSpan(text: ' that:'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        if (isProcessing)
                          const Center(child: Text('Still processing...', 
                            style: TextStyle(fontSize: 16)))
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCoverImage(user),
                              const SizedBox(height: 8),
                              Text(
                                user['Restaurant_Name'] ?? 'Unknown Restaurant',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPhotoGallery(user),
                            ],
                          ),
                        const SizedBox(height: 15),

                        if (!isProcessing)
                          Text(
                            user['review'] ?? 'No review available',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
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

  Widget _buildProfileImage(Map<String, dynamic> user) {
    return CircleAvatar(
      radius: 20,
      backgroundImage: _getImageProvider(user['google_user_photo']),
      onBackgroundImageError: (_, __) => const Icon(Icons.error),
      child: user['google_user_photo'] == null 
          ? const Icon(Icons.person)
          : null,
    );
  }

Widget _buildCoverImage(Map<String, dynamic> user) {
  final coverPhoto = user['cover_photo'];
  if (coverPhoto == null || coverPhoto.isEmpty) return const SizedBox.shrink();

  final String photoUrl = _buildGooglePhotoUrl(coverPhoto);

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(photoUrl);
        try {
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        } catch (e) {
          debugPrint('Error launching URL: $e');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'View Cover Photo ↗',
          style: TextStyle(
            color: const Color.fromARGB(255, 237, 247, 255),
            decoration: TextDecoration.underline,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}

  Widget _buildPhotoGallery(Map<String, dynamic> user) {
    final photos = _parsePhotos(user['photos']);
    if (photos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _buildGooglePhotoUrl(photos[index]),
                width: 100,
                height: 100,
                headers: const {'Referer': 'http://localhost'},
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()));
                },
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.photo, size: 30),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ImageProvider _getImageProvider(String? url) {
    if (url == null || url.isEmpty) {
      return const AssetImage('assets/placeholder.png');
    }
    try {
      return NetworkImage(url, headers: const {'Referer': 'http://localhost'});
    } catch (e) {
      return const AssetImage('assets/placeholder.png');
    }
  }

  List<String> _parsePhotos(dynamic photos) {
    if (photos == null) return [];
    if (photos is String) return photos.split('\n');
    if (photos is List) return photos.cast<String>().where((p) => p.isNotEmpty).toList();
    return [];
  }

  String _buildGooglePhotoUrl(String photoReference) {
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=800'
        '&photoreference=$photoReference'
        '&key=AIzaSyCw5W0ImANZwSj0AT-ain0AyXJJr_ZX6Cs';
  }
}