import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gather_app/constants.dart';
import 'package:gather_app/model/user.dart';
import 'package:gather_app/model/group.dart';
import 'package:gather_app/services/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gather_app/services/authenticate.dart';
import 'package:gather_app/ui/home/homeScreen.dart';
import 'package:place_picker/place_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';

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
  String title, description, location,eventDate;
  CollectionReference groups = FirebaseFirestore.instance.collection('groups');
  LocationResult locationResult;
  final locationController = TextEditingController();
  final dateController = TextEditingController();

  var uuid = new Uuid();
  String _sessionToken;
  List<dynamic> _placeList = [];

  @override
  void initState() {
    super.initState();
    locationController.addListener(() {
      _onChanged();
    });
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(locationController.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = "AIzaSyBrCRmjv-557iJnR2U06yV9G9D3HyLBtD8";
    String type = '(regions)';
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        _placeList = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

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
                    controller: locationController,
                    validator: validateLocation,
                    onSaved: (String val) {
                      location = locationController.text;
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
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _placeList.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {setState(() {
                locationController.text = _placeList[index]["description"];
                _placeList.length = 0;
              });
              },
              title: Text(_placeList[index]["description"]),
            );
          },
        ),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    controller: dateController,
                    onTap: (){showDateTimePicker();},
                    validator: validateDescription,
                    onSaved: (String val) {
                      eventDate = dateController.text;
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
                    minLines: 10,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    validator: validateDescription,
                    onSaved: (String val) {
                      description = val;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                        alignLabelWithHint: true,
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
      print(eventDate);
      try {
        String groupId = await addGroup();
        Group group = Group(
          title: title,
          description: description,
          location: location,
          tag: ['Test'],
          groupId: groupId,
          hostId: user.userID,
          hostName: user.fullName(),
          createdDate: DateTime.now(),
          eventDate: eventDate,
        );
        await FireStoreUtils.firestore
            .collection(GROUPS)
            .doc(groupId)
            .set(group.toJson());
        hideProgress();

        DocumentSnapshot userSnapshot = await FireStoreUtils.firestore
            .collection(USERS)
            .doc(user.userID)
            .get();
        hideProgress();
        await FireStoreUtils.firestore
            .collection(USERS)
            .doc(user.userID)
            .update({"groupsCreated" : updateCreatedGroups(groupId, userSnapshot)});
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

  void showPlacePicker() async {
    LocationResult result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PlacePicker(GOOGLEAPIKEY)));

    // Handle the result in your way
    print(result.name);
    print(result.administrativeAreaLevel1.shortName);
    print(result.administrativeAreaLevel2.shortName);
    print(result.formattedAddress);
    print(result.locality);
    print(result.placeId);
    setState(() {
      locationResult = result;
      locationController.text = locationResult.name + ", " + locationResult.formattedAddress;
    });
  }

  void showDateTimePicker() async{
    DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        minTime: DateTime.now(),
        onChanged: (date) {
          print('change $date');
        },
        onConfirm: (date) {
          print('confirm $date');
          print("current date time ${DateTime.now()}");

          setState(() {
            String formatDate(DateTime date) => new DateFormat("MMMM d yyyy HH:mm").format(date);
            print(formatDate(date));
            dateController.text = formatDate(date);
            // DateTime newDate = DateTime(date.year,date.month,date.day,date.hour,date.minute);
            // print("new Date : $newDate");
            // eventDate = newDate;
          });
        },
        currentTime: DateTime.now(),
        locale: LocaleType.en);
  }

  List<dynamic> updateCreatedGroups(String groupId, DocumentSnapshot userSnapshot) {
    User user1 = User.fromJson(userSnapshot.data());

    List<dynamic> oldGroupsCreated = user1.groupsCreated;
    oldGroupsCreated.add(groupId);
    return oldGroupsCreated;
  }
}
