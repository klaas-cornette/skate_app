// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:skate_community/screens/auth/sign_in_screen.dart';
import 'package:skate_community/screens/profile/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skate_community/screens/widgets/background_wrapper.dart';
import 'package:skate_community/screens/widgets/footer_widget.dart';
import 'package:skate_community/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _locationAccess = false;
  final SupabaseClient _client = Supabase.instance.client;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  

  /// Laadt de huidige instellingen van de gebruiker uit de 'user_settings' tabel
  Future<void> _loadSettings() async {
    try {
      final userId = _client.auth.currentUser!.id;
      final settings = await _settingsService.loadUserSettings(userId);
      setState(() {
        _locationAccess = settings['location_sharing'] as bool? ?? true;
      });
    } catch (e) {
      setState(() {
        _locationAccess = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij laden instellingen: $e')),
      );
    }
  }

  /// Wijzigt de locatietoegang in de database en update de lokale state
  Future<void> _toggleLocationAccess(bool value) async {
    setState(() {
      _locationAccess = value;
    });
    try {
      final userId = _client.auth.currentUser!.id;
      await _settingsService.updateLocationSharing(userId, value);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij updaten locatie-instellingen: $e')),
      );
    }
  }

  void _navigateToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Verwijderen'),
        content: const Text(
          'Weet je zeker dat je je account wilt verwijderen? Dit kan niet ongedaan gemaakt worden.',
        ),
        actions: [
          TextButton(
            child: const Text('Annuleren'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child:
                const Text('Verwijderen', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await _client.auth.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uitloggen'),
        content: const Text('Weet je zeker dat je wilt uitloggen?'),
        actions: [
          TextButton(
            child: const Text('Annuleren'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Uitloggen', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await _client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
          ),
        ],
      ),
    );
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
            automaticallyImplyLeading: false,
            title: const Text(
              'Instellingen',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
                      // Locatietoegang Switch
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.location_on,
                            color: Color(0xFF0C1033)),
                        title: const Text(
                          'Locatietoegang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        subtitle: Text(
                          _locationAccess
                              ? 'Locatie delen is ingeschakeld'
                              : 'Locatie delen is uitgeschakeld',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Switch(
                          value: _locationAccess,
                          activeColor: const Color(0xFF0C1033),
                          onChanged: _toggleLocationAccess,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      // Mijn Profiel
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            const Icon(Icons.person, color: Color(0xFF0C1033)),
                        title: const Text(
                          'Mijn Profiel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        onTap: _navigateToProfile,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      // Uitloggen knop
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.exit_to_app,
                            color: Color(0xFF0C1033)),
                        title: const Text(
                          'Uitloggen',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        onTap: _confirmLogout,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      // Account Verwijderen
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text(
                          'Account Verwijderen',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        onTap: _confirmDeleteAccount,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FooterWidget(currentIndex: 3),
    );
  }
}
