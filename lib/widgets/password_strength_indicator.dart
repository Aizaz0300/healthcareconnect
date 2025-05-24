import 'package:flutter/material.dart';


class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: strength.percentage,
          backgroundColor: Colors.grey[200],
          color: strength.color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text(
          strength.label,
          style: TextStyle(
            color: strength.color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  _StrengthLevel _calculatePasswordStrength() {
    if (password.isEmpty) {
      return _StrengthLevel.none;
    }

    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    switch (score) {
      case 5:
        return _StrengthLevel.strong;
      case 4:
        return _StrengthLevel.good;
      case 3:
        return _StrengthLevel.fair;
      case 2:
        return _StrengthLevel.weak;
      default:
        return _StrengthLevel.veryWeak;
    }
  }
}

class _StrengthLevel {
  final String label;
  final Color color;
  final double percentage;

  const _StrengthLevel(this.label, this.color, this.percentage);

  static const none = _StrengthLevel('', Colors.grey, 0.0);
  static const veryWeak = _StrengthLevel('Very Weak', Colors.red, 0.2);
  static const weak = _StrengthLevel('Weak', Colors.orange, 0.4);
  static const fair = _StrengthLevel('Fair', Colors.yellow, 0.6);
  static const good = _StrengthLevel('Good', Colors.lightGreen, 0.8);
  static const strong = _StrengthLevel('Strong', Colors.green, 1.0);
}
