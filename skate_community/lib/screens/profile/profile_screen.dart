// lib/screens/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skate_community/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skate_community/screens/widgets/background_wrapper.dart';
import 'package:skate_community/screens/widgets/footer_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _client = Supabase.instance.client;
  final UserService _userService = UserService();
  final TextEditingController _usernameController = TextEditingController();

  String? _email;
  String? _profileImageUrl;
  File? _newProfileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = _client.auth.currentUser!.id;
      final profile = await _userService.loadUserProfile(userId);
      setState(() {
        _usernameController.text = profile['username'] ?? '';
        _email = profile['email'] ?? '';
        _profileImageUrl = profile['profile_image'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij laden profiel: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
  setState(() => _isLoading = true);
  try {
    final userId = _client.auth.currentUser!.id;
    String? imageUrl = _profileImageUrl;

    if (_newProfileImage != null) {
      final fileExt = _newProfileImage!.path.split('.').last;
      final fileName = '$userId.$fileExt';

      // Upload de afbeelding met de upload()-methode
      await _client.storage
          .from('profile-images')
          .upload(fileName, _newProfileImage!);

      // Verkrijg de openbare URL
      final publicUrlResponse = _client.storage.from('profile-images').getPublicUrl(fileName);
      imageUrl = publicUrlResponse;
    }

    await _userService.updateUserProfile(
      userId,
      username: _usernameController.text,
      profileImageUrl: imageUrl,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profiel succesvol bijgewerkt!')),
    );
    _loadUserProfile();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fout bij opslaan profiel: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C1033), Color(0xFF9AC4F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              'Mijn Profiel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: BackgroundWrapper(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 8.0,
                      shadowColor: Colors.black45,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Profiel foto met edit knop
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _newProfileImage != null
                                        ? FileImage(_newProfileImage!)
                                        : (_profileImageUrl != null
                                            ? NetworkImage(_profileImageUrl!)
                                            : AssetImage(
                                                    'assets/images/default_profile.png')
                                                as ImageProvider),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: _pickImage,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 20,
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Color(0xFF0C1033),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Username
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Gebruikersnaam',
                                labelStyle:
                                    const TextStyle(color: Color(0xFF0C1033)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF9AC4F5)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Email (alleen lezen)
                            Text(
                              _email ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0C1033),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: const Color(0xFF0C1033),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                'Opslaan',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: const FooterWidget(currentIndex: 2),
    );
  }
}
