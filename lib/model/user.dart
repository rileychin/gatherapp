import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String email;
  String firstName;
  String lastName;

  String phoneNumber;

  bool active;

  Timestamp lastOnlineTimestamp;

  String userID;
  String profilePictureURL;

  bool selected;

  String appIdentifier;
  List<dynamic> userCategory;

  //store this as a list of IDs for the groups so can easily sort when can
  List<dynamic> groupsCreated;
  List<dynamic> groupsAttending;
  List<dynamic> groupsBookmarked;

  User(
      {this.email = '',
      this.firstName = '',
      this.phoneNumber = '',
      this.lastName = '',
      this.active = false,
      this.selected = false,
      lastOnlineTimestamp,
      this.userID = '',
      this.profilePictureURL = '',
      this.userCategory = const ["Sports"],
      this.groupsCreated = const [],
      this.groupsAttending = const [],
      this.groupsBookmarked = const []})
      : this.lastOnlineTimestamp = lastOnlineTimestamp ?? Timestamp.now(),
        this.appIdentifier = 'Flutter Login Screen ${Platform.operatingSystem}';

  String fullName() {
    return '$firstName $lastName';
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return new User(
        email: parsedJson['email'] ?? '',
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        active: parsedJson['active'] ?? false,
        lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'],
        phoneNumber: parsedJson['phoneNumber'] ?? '',
        userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? '',
        userCategory: parsedJson['userCategory'] ?? ["General"],
        groupsCreated: parsedJson['groupsCreated'] ?? [],
        groupsAttending: parsedJson['groupsAttending'] ?? [],
        groupsBookmarked: parsedJson['groupsBookmarked'] ?? []);
  }

  Map<String, dynamic> toJson() {
    return {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'phoneNumber': this.phoneNumber,
      'id': this.userID,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'userCategory' : this.userCategory,
      'groupsCreated' : this.groupsCreated,
      'groupsAttending' : this.groupsAttending,
      'groupsBookmarked' : this.groupsBookmarked,
    };
  }
}