import 'package:flutter/material.dart';
import 'package:classfury/app/theme/app_colors.dart';

class RoundedLogo extends StatelessWidget {
  final double size;
  final double borderRadius;

  const RoundedLogo({
    Key? key,
    this.size = 80,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
