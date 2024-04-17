 import 'package:examenflutteriit/components/lottie/addLottie.dart';
import 'package:flutter/material.dart';

class ConnectionError extends StatelessWidget {
  const ConnectionError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: AddLottie(filePath: "assets/lottie/connectionLost.json", height: 200, width: 200,   repeatAnimation: true, fit: BoxFit.cover,));
  }
}


