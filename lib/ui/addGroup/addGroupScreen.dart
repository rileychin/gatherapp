import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gather_app/constants.dart';
import 'package:gather_app/model/user.dart';
import 'package:gather_app/model/group.dart';
import 'package:gather_app/services/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gather_app/services/authenticate.dart';
import 'package:gather_app/ui/home/homeScreen.dart';

class AddGroupScreen extends StatefulWidget {
  final User user;
  AddGroupScreen({Key key, @required this.user}) : super(key: key);

  @override
  State createState() => _AddGroupScreen(user);
}

class _AddGroupScreen extends State<AddGroupScreen> {
  final User user;
  _AddGroupScreen(this.user);
  GlobalKey<FormState> _key = new GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String title, description, location, dateTime;
  CollectionReference groups = FirebaseFirestore.instance.collection('groups');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: new Container(
        margin: new EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
        child: new Form(
            key: _key, autovalidateMode: _validate, child: groupFormUI()),
      ),
    );
  }


  //REQUIRED FIELDS:
  //(0) OPTIONAL: Group image (image picker)
  //1: Title (text box)
  //(2) OPTIONAL: Online/Offline event (radio button)
  //3: Location (text box/ google maps API location picker)
  //4: Date (date time picker)
  //5: Description (long&wide text box max 100 words)
  //6: Tags (checkbox from constants.dart)

  //NOTE: confirm button put next screen, push to firestore
  //after user select tags & confirms the group posting
  Widget groupFormUI() {
    return new Column(
      children: <Widget>[
        new Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Add New Group',
              style: TextStyle(
                  color: Color(COLOR_PRIMARY),
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            )),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    validator: validateTitle,
                    onSaved: (String val) {
                      title = val;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: 'Title',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Color(COLOR_PRIMARY), width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: validateLocation,
                    onSaved: (String val) {
                      location = val;
                    },
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: 'Location',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Color(COLOR_PRIMARY), width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    validator: validateDescription,
                    onSaved: (String val) {
                      dateTime = val;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: 'Date and Time',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Color(COLOR_PRIMARY), width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    validator: validateDescription,
                    onSaved: (String val) {
                      description = val;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 90, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: 'Description',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Color(COLOR_PRIMARY), width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),

        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: RaisedButton(
              color: Color(COLOR_PRIMARY),
              child: Text(
                'Add Group',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              textColor: Colors.white,
              splashColor: Color(COLOR_PRIMARY),
              onPressed: _sendToServer,
              padding: EdgeInsets.only(top: 12, bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(color: Color(COLOR_PRIMARY))),
            ),
          ),
        ),
      ],
    );
  }

  _sendToServer() async {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      showProgress(context, 'Creating new group, Please wait...', false);
      try {
        String groupId = await addGroup();
        Group group = Group(
          title: title,
          description: description,
          location: location,
          tag: ['Test'],
          userId: user.userID,
          groupId: groupId,
          hostId: user.userID,
          hostName: user.fullName(),
          createdDate: DateTime.now(),
        );
        await FireStoreUtils.firestore
            .collection('groups')
            .doc(groupId)
            .set(group.toJson());
        hideProgress();
        pushAndRemoveUntil(context, HomeScreen(user: user), false);
      } catch (e) {
        print('_addGroupState._sendToServer $e');
        hideProgress();
        showAlertDialog(context, 'Failed', 'Couldn\'t add group');
      }
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  Future<String> addGroup() {
    return groups
        .add({'title': title})
        .then((value) => value.id)
        .catchError((error) => print("Failed to add group: $error"));
  }
}
