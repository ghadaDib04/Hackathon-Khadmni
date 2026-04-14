import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PriceBadge extends StatelessWidget {
  final double price;
  final String currency;

  const PriceBadge({super.key, required this.price, this.currency = 'dt'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.goldenYellow.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${price.toStringAsFixed(3)} $currency',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
