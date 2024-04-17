import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class AddLottie extends StatelessWidget {

  AddLottie({
    Key? key,
    required this.filePath,
    required this.height,
    required this.width,
    required this.fit,
    required this.repeatAnimation,
  }) : super(key: key);


  String filePath;
  double height, width;
  BoxFit fit;
  bool repeatAnimation;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(filePath, reverse: true, height: height, width: width, fit: fit, repeat: repeatAnimation,);
  }
}
