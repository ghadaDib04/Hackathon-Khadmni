import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TrustBadge extends StatelessWidget {
  const TrustBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.retroTeal.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.verified_user_rounded,
            size: 11,
            color: AppColors.retroTeal,
          ),
          SizedBox(width: 3),
          Text(
            'VÉRIFIÉ IA',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.retroTeal,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
