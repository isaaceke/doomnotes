import 'package:flutter/material.dart';
import '../models/source_platform.dart';

class PlatformPill extends StatelessWidget {
  final SourcePlatform platform;
  final bool compact;

  const PlatformPill({
    super.key,
    required this.platform,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = platform.displayColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(platform.icon, size: compact ? 13 : 15, color: color),
          SizedBox(width: compact ? 4 : 6),
          Text(
            platform.label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}