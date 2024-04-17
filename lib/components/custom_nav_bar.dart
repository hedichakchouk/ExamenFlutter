import 'package:examenflutteriit/main.dart';
import 'package:examenflutteriit/pages/account_page.dart';
import 'package:examenflutteriit/pages/main_screen.dart';
import 'package:examenflutteriit/pages/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  final user = FirebaseAuth.instance.currentUser;


  final controller = PersistentTabController(initialIndex: 0);

  List<Widget> buildScreens() {
    return [SettingsPage(), MainScreen(),AccountPage() ];
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.themeData.brightness == Brightness.dark;

    List<PersistentBottomNavBarItem> navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          activeColorSecondary: Colors.black,
          inactiveIcon:   Icon(CupertinoIcons.settings, color:isDark? Colors.grey:Colors.white),
          icon: const Icon(CupertinoIcons.settings, color: Colors.black),
          title: ("Settings"),
          activeColorPrimary: isDark? CupertinoColors.activeGreen : CupertinoColors.label ,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          activeColorSecondary: Colors.black,
          inactiveIcon:   Icon(CupertinoIcons.home,  color:isDark? Colors.grey:Colors.white),
          icon: const Icon(CupertinoIcons.home, color: Colors.black),
          title: ("Home"),
          activeColorPrimary: isDark? CupertinoColors.activeGreen : CupertinoColors.label ,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          activeColorSecondary: Colors.black,
          inactiveIcon:   Icon(CupertinoIcons.person, color:isDark? Colors.grey:Colors.white),
          icon: const Icon(CupertinoIcons.person, color: Colors.black),
          title: ("Account"),
          activeColorPrimary: isDark? CupertinoColors.activeGreen : CupertinoColors.label ,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
      ];
    }


    return PersistentTabView(
      context,
      controller: controller,
      screens: buildScreens(),
      items: navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: isDark?Colors.white12:Colors.green,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar:isDark? Colors.white:Colors.red,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style1,
    );
  }
}
