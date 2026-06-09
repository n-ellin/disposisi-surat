import 'package:flutter/material.dart';
import '../../core/constants/app_color.dart';

class DateFilterBar extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DateFilterBar({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.035,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(w * 0.03),
          border: Border.all(color: const Color(0xFFE2E5EA)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 18 , color: AppColors.bluePrimary,),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}