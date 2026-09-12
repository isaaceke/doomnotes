import 'package:flutter/material.dart';
import '../theme/doomnotes_theme.dart';

class AuthProviderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool dark;

  const AuthProviderButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: dark ? DoomNotesTheme.ink : Colors.white,
          foregroundColor: dark ? Colors.white : DoomNotesTheme.ink,
          side: BorderSide(
            color: dark ? DoomNotesTheme.ink : DoomNotesTheme.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DoomNotesTheme.radiusSmall),
          ),
        ),
      ),
    );
  }
}