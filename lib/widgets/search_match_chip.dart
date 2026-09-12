import 'package:flutter/material.dart';
import '../theme/doomnotes_theme.dart';

class SearchMatchChip extends StatelessWidget {
  final String label;

  const SearchMatchChip({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DoomNotesTheme.violetSoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: DoomNotesTheme.violet,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}