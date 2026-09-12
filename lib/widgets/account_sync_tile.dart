import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/doomnotes_theme.dart';
import '../screens/auth_screen.dart';

class AccountSyncTile extends StatelessWidget {
  const AccountSyncTile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    if (user != null && !user.isAnonymous) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: DoomNotesTheme.violetSoft,
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Icon(Icons.person_rounded, color: DoomNotesTheme.violet)
              : null,
        ),
        title: Text(user.displayName ?? user.email ?? 'Signed in'),
        subtitle: const Text('Cloud sync is on'),
        trailing: Icon(Icons.cloud_done_rounded, color: DoomNotesTheme.mint),
        onTap: () async {
          final shouldSignOut = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Account'),
              content: Text(
                'Signed in as ${user.email ?? user.displayName ?? 'your account'}.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Close'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          );

          if (shouldSignOut == true) {
            await AuthService.instance.signOut();
          }
        },
      );
    }

    return ListTile(
      leading: const Icon(Icons.cloud_sync_rounded),
      title: const Text('Back up and sync'),
      subtitle: const Text('Sign in to access your library on every device'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AuthScreen(
              isLinkingAnonymousAccount: true,
            ),
          ),
        );
      },
    );
  }
}