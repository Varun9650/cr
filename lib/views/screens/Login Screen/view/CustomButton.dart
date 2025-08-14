import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final TextStyle? textStyle;
  final Color? color;

  const CustomButton({
    this.text,
    this.child,
    required this.onTap,
    this.height,
    this.width,
    this.textStyle,
    this.color,
    Key? key,
  })  : assert(text != null || child != null,
            'Either text or child must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height ?? 50,
        width: width ?? 400,
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: color ?? const Color.fromARGB(255, 69, 138, 217),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: child ??
              Text(
                text!,
                style: textStyle ??
                    GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
        ),
      ),
    );
  }
}
