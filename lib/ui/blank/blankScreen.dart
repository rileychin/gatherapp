import 'package:flutter/cupertino.dart';

import 'package:gather_app/model/user.dart';
import 'package:gather_app/services/helper.dart';

class BlankScreen extends StatefulWidget{
  final User user;

  BlankScreen({Key key, @required this.user}) : super(key: key);

  @override
  State createState(){
    return _BlankScreen(user);
  }
}

class _BlankScreen extends State<BlankScreen> {
  final User user;

  _BlankScreen(this.user);

  @override
  Widget build(BuildContext context){
    return Center(
      child: Column(children: <Widget>[
        displayCircleImage(user.profilePictureURL, 125, false),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user.firstName),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user.email),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user.phoneNumber),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user.userID),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user.userCategory.toString()),
            ),
      ],)
    );
  }

}