import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatelessWidget {
  final String animationPath;
  final double width;
  final double height;
  final BoxFit fit;

  LottieAnimation({
    required this.animationPath,
    required this.width,
    required this.height,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      animationPath,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
