import 'package:flutter/material.dart';

TextStyle jerseyStyle(double fontSize, [Color color = Colors.white]) {
  return TextStyle(
    fontFamily: 'Jersey 25',
    fontSize: fontSize,
    color: color,
  );
}

void slideTo(BuildContext context, Widget destination,
    {bool useFadeSlide = false}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: !useFadeSlide,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (useFadeSlide) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeOut));
          final offsetAnimation = animation.drive(tween);

          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          );

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        } else {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));

          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        }
      },
    ),
  );
}

Widget buildStyledButton({
  required BuildContext context,
  required String buttonText,
  required Color buttonColor,
  required Color textColor,
  required Color borderColor,
  required VoidCallback? onPressed,
  double borderWidth = 2.0,
  Size fixedSize = const Size(350, 59),
  double fontSize = 24,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: textColor,
      fixedSize: fixedSize,
      elevation: 0,
      side: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
      disabledBackgroundColor: buttonColor.withOpacity(0.5),
      disabledForegroundColor: textColor.withOpacity(0.7),
    ),
    onPressed: onPressed,
    child: Text(
      buttonText,
      style: jerseyStyle(fontSize, textColor),
    ),
  );
}

const Color brightWhite = Colors.white;
const Color darkMaroon = Color(0xFF562634);
const Color errorRed = Colors.red;
const Color lightMaroon = Color(0xFF9B5D6C);
const Color hintMaroon = Color(0x9938000A);
const Color goodGreen = Colors.green;
final Color intakeStatGrey = Colors.grey[600]!;
