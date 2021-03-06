//REQUIRED FIELDS:
//(0) OPTIONAL: Group image (image picker)
//1: Title (text box)
//(2) OPTIONAL: Online/Offline event (radio button)
//3: Location (text box/ google maps API location picker)
//4: Date (date time picker)
//5: Description (long&wide text box max 100 words)
//6: Tags (checkbox from constants.dart)

class Group {
  String title;
  String description;
  String location;
  List<dynamic> tag;
  String groupId;

  //every group needs a host yea
  String hostId;
  String hostName;

  //every group also needs attendees
  List<String> attendees;

  //might also need max number of attendees
  //int maxAttendees;

  String commentId;
  DateTime createdDate;
  String eventDate;

  //for multiple photos, if not by default no image
  List<String> groupPictureURL;

  //Group status to determine if 'active', 'canceled', 'over'
  String status;


  Group({
    this.title = '',
    this.description = '',
    this.location = '',
    this.tag = const [],
    this.groupId = '',
    this.hostId = '',
    this.hostName = '',
    this.commentId = '',
    this.createdDate,
    this.eventDate,
    this.status = 'active'
  });

  factory Group.fromJson(Map<String, dynamic> parsedJson) {
    return new Group(
      title: parsedJson['title'] ?? '',
      description: parsedJson['description'] ?? '',
      location: parsedJson['location'] ?? '',
      tag: parsedJson['tag'] ?? [],
      groupId: parsedJson['groupId'] ?? '',
      hostId: parsedJson['hostId'] ?? '',
      hostName: parsedJson['hostName'] ?? '',
      commentId: parsedJson['commentId'] ?? '',
      createdDate: DateTime.now(),
      eventDate: parsedJson['eventDate'] ?? '',
      status: parsedJson['status'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': this.title,
      'description': this.description,
      'location': this.location,
      'tag': this.tag,
      'groupId': this.groupId,
      'hostId' : this.hostId,
      'hostName' : this.hostName,
      'commentId': this.commentId,
      'createdDate': this.createdDate,
      'eventDate': this.eventDate,
      'status' : this.status,
    };
  }
}
