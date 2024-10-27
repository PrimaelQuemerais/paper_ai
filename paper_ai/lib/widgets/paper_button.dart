import 'package:flutter/material.dart';

class PaperButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool outlined;
  final IconData? icon;

  const PaperButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: icon != null
                  ? Icon(icon, color: Colors.black)
                  : const SizedBox.shrink(),
              label: Text(
                text,
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: icon != null
                  ? Icon(icon, color: Colors.white)
                  : const SizedBox.shrink(),
              label: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
    );
  }
}
