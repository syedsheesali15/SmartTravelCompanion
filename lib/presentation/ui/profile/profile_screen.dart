import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../provider/profile_notifier.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _picker = ImagePicker();
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProfileNotifier>();
      if (mounted && !_seeded) {
        _nameCtrl.text = p.displayName;
        _emailCtrl.text = p.email;
        _seeded = true;
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ProfileNotifier profile) async {
    if (kIsWeb) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Profile photo from gallery is for Android / iOS installs.'),
          ),
        );
      }
      return;
    }
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 88,
    );
    if (x == null || !context.mounted) return;
    await profile.savePickedAvatarFile(File(x.path));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileNotifier>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundImage: profile.avatarImageProvider(),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Material(
                    shape: const CircleBorder(),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    elevation: 3,
                    child: IconButton(
                      tooltip: kIsWeb ? 'Photo on mobile' : 'Change photo',
                      onPressed: kIsWeb ? null : () => _pickPhoto(profile),
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!kIsWeb) ...[
            const SizedBox(height: 8),
            Align(
              child: TextButton(
                onPressed: () async {
                  await profile.clearLocalAvatarAndUseNetwork();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Using default avatar image'),
                    ),
                  );
                },
                child: const Text('Reset to default photo'),
              ),
            ),
          ],
          const SizedBox(height: 28),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Display name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              await profile.saveIdentity(
                displayName: _nameCtrl.text,
                email: _emailCtrl.text,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile saved')),
              );
            },
            child: const Text('Save changes'),
          ),
          const SizedBox(height: 20),
          Text(
            'Name and email are stored on this device. Choose a photo from your gallery — '
            'it is copied into app storage.'
            '${kIsWeb ? ' This web build skips local photo files.' : ''}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}
