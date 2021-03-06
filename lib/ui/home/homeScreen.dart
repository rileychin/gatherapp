import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gather_app/constants.dart';
import 'package:gather_app/main.dart';
import 'package:gather_app/model/user.dart';
import 'package:gather_app/services/authenticate.dart';
import 'package:gather_app/services/helper.dart';
import 'package:gather_app/ui/addGroup/addGroupScreen.dart';
import 'package:gather_app/ui/auth/authScreen.dart';
import 'package:ss_bottom_navbar/ss_bottom_navbar.dart';
import 'package:provider/provider.dart';
import 'package:gather_app/ui/blank/blankScreen.dart';
import 'package:gather_app/ui/main/mainBox.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  HomeScreen({Key key, @required this.user}) : super(key: key);

  @override
  State createState() {
    return _HomeState(user);
  }
}

class _HomeState extends State<HomeScreen> {
  final items = [
    SSBottomNavItem(text: 'Home', iconData: Icons.home),
    SSBottomNavItem(text: 'Search', iconData: Icons.search),
    SSBottomNavItem(text: 'Add', iconData: Icons.add, isIconOnly: true),
    SSBottomNavItem(text: 'Events', iconData: Icons.event),
    SSBottomNavItem(text: 'Profile', iconData: Icons.person),
  ];
  SSBottomBarState _state = SSBottomBarState();
  bool _isVisible = true;
  final User user;

  _HomeState(this.user);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => _state,
        builder: (context, child) {
          context.watch<SSBottomBarState>();
          return Scaffold(
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Text(
                      '${user.fullName()}',
                      style: TextStyle(color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Logout',
                      style: TextStyle(color: Colors.black),
                    ),
                    leading: Transform.rotate(
                        angle: pi / 1,
                        child: Icon(Icons.exit_to_app, color: Colors.black)),
                    onTap: () async {
                      user.active = false;
                      user.lastOnlineTimestamp = Timestamp.now();
                      FireStoreUtils.updateCurrentUser(user);
                      await auth.FirebaseAuth.instance.signOut();
                      MyAppState.currentUser = null;
                      pushAndRemoveUntil(context, AuthScreen(), false);
                    },
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              title: Text(
                'Home',
                style: TextStyle(color: Colors.black),
              ),
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.white,
              centerTitle: true,
            ),
            body: Row(
                children: [
                  Expanded(
                      child: IndexedStack(
                        index: _state.selected,
                        children: _buildPages(user),
                      )),
                ]),
            bottomNavigationBar: SSBottomNav(
              items: items,
              state: _state,
              color: Color(COLOR_PRIMARY),
              selectedColor: Colors.white,
              unselectedColor: Colors.black,
              visible: _isVisible,
              // bottomSheetWidget: _bottomSheet(),
              // showBottomSheetAt: 2,

              //if no bottom sheet there will
              //be overflow for index 0
              showBottomSheetAt: null,
            ),
          );
        });
  }

  List<Widget> _buildPages(user){
    List<Widget> pages = [MainBox(user: user),MainBox(user: user),AddGroupScreen(user: user),BlankScreen(user: user),BlankScreen(user: user)];
    return pages;
  }
}
