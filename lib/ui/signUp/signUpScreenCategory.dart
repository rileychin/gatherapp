import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gather_app/constants.dart';
import 'package:gather_app/main.dart';
import 'package:gather_app/model/user.dart';
import 'package:gather_app/services/authenticate.dart';
import 'package:gather_app/services/helper.dart';
import 'package:gather_app/ui/home/homeScreen.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:image_picker/image_picker.dart';

File _image;

class SignUpScreenCategory extends StatefulWidget {


  final User user;

  SignUpScreenCategory({Key key, @required this.user}) : super(key: key);


  @override
  State createState() => _SignUpCategoryState(this.user);
}

class _SignUpCategoryState extends State<SignUpScreenCategory> {


  final User user;

  _SignUpCategoryState(this.user);
  List<String> _userCategory = [];


  GlobalKey<FormState> _key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          child: new Form(
            key: _key,
            child: categoryUI(),
          ),
        ),
      ),
    );
  }

  Widget categoryUI() {
    return new Column(
      children: <Widget>[
        new Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Lets get to know you better!',
              style: TextStyle(
                  color: Color(COLOR_PRIMARY),
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            )),
        SizedBox(height:10),
        Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Select at least one category you are interested in',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0),
            )),
        CheckboxGroup(
          //update here if want to add more categories
          labels: CATEGORIES,
        onSelected: (List<String> checked) {
            setState(() {
              _userCategory = checked;
            });
            print(checked.toString());
            } ,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: RaisedButton(
              color: Color(COLOR_PRIMARY),
              child: Text(
                'Confirm',
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
    //print(_userCategory);
    if (_userCategory.length == 0){
      showAlertDialog(context, 'Failed', 'Please select at least one category');
    }
    else{
      try {

        User user2 = User(
            email: user.email,
            firstName: user.firstName,
            phoneNumber: user.phoneNumber,
            userID: user.userID,
            active: true,
            lastName: user.lastName,
            profilePictureURL: user.profilePictureURL,
            userCategory: _userCategory);

        //update only 1 user data
        await FireStoreUtils.firestore
            .collection(USERS)
            .doc(user.userID)
            .update({"userCategory" : _userCategory});
        hideProgress();
        pushAndRemoveUntil(context, HomeScreen(user: user2), false);
      } catch (e) {
        print('_SignUpCategoryState._sendToServer $e');
        hideProgress();
        showAlertDialog(context, 'Failed', 'Couldn\'t sign up');
      }
    }
    }

}
