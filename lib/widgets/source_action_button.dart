import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/source_platform.dart';
import '../theme/doomnotes_theme.dart';

class SourceActionButton extends StatelessWidget {
  final String url;
  final SourcePlatform platform;
  final bool fullWidth;

  const SourceActionButton({
    super.key,
    required this.url,
    required this.platform,
    this.fullWidth = true,
  });

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(url);

    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This source link is invalid.')),
      );
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the source link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: () => _open(context),
      icon: Icon(
        platform == SourcePlatform.youtube ||
                platform == SourcePlatform.tiktok ||
                platform == SourcePlatform.instagram
            ? Icons.play_arrow_rounded
            : Icons.open_in_new_rounded,
      ),
      label: Text(platform.actionLabel.toUpperCase()),
      style: FilledButton.styleFrom(
        backgroundColor: platform.color,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DoomNotesTheme.radiusSmall),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.45,
          fontSize: 12,
        ),
      ),
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}