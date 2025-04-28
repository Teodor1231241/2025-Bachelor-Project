import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                                        'https://via.placeholder.com/150'),
                                radius: 20,
                                onBackgroundImageError: (_, __) =>
                                    const Icon(Icons.error),
                                child: profilePhotoUrl.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
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
                                if (userData['cover_photo'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      userData['cover_photo'],
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                        return progress == null
                                            ? child
                                            : const SizedBox(
                                                height: 200,
                                                child: Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                              );
                                      },
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    ),
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
                                if (userData['photos'] != null)
                                  SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          _parsePhotos(userData['photos']).length,
                                      itemBuilder: (context, photoIndex) {
                                        final photoUrl = _parsePhotos(
                                            userData['photos'])[photoIndex];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: Image.network(
                                            photoUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (context, child, progress) {
                                              return progress == null
                                                  ? child
                                                  : const SizedBox(
                                                      width: 100,
                                                      height: 100,
                                                      child: Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                    );
                                            },
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.broken_image),
                                          ),
                                        );
                                      },
                                    ),
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

  List<String> _parsePhotos(dynamic photos) {
    if (photos == null) return [];
    if (photos is String) return photos.split('\n');
    if (photos is List) return photos.cast<String>();
    return [];
  }
}