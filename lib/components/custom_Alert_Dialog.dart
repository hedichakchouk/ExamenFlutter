 import 'package:examenflutteriit/l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class CustomAlertDialog {
  void showAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(context.l10n.alert),
        content: Text(context.l10n.alertText),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(context.l10n.no),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async{
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
            child: Text(context.l10n.yes),
          ),
        ],
      ),
    );
  }
}
