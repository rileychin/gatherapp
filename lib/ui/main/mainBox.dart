import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gather_app/model/user.dart';
import 'package:gather_app/model/group.dart';

class MainBox extends StatefulWidget {
  final User user;

  MainBox({Key key, @required this.user}) : super(key: key);

  @override
  State createState() {
    return _MainBox(user);
  }
}

class _MainBox extends State<MainBox> {
  final User user;
  List<Group> groups;
  int itemCount = -1;
  _MainBox(this.user);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: itemCount > 0
            ? ListView.builder(
              itemCount: itemCount,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('Item ${index + 1}'),
                );
              },
            )
            : Center(child: const Text('No grouping')));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return groups.isEmpty 
  //       ? Center(child: const Text('No grouping')) 
  //       : ListView.builder(
  //             itemCount: itemCount,
  //             itemBuilder: (BuildContext context, int index) {
  //               return ListTile(
  //                 title: Text('Item ${index + 1}'),
  //               );
  //             },
  //           );
  // }

}
