class Group {
  String title;
  String description;
  String location;
  List<dynamic> tag;
  String groupId;
  String userId;
  String commentId;
  DateTime createdDate;

  Group({
    this.title = '',
    this.description = '',
    this.location = '',
    this.tag = const [],
    this.groupId = '',
    this.userId = '',
    this.commentId = '',
    this.createdDate,
  });

  factory Group.fromJson(Map<String, dynamic> parsedJson) {
    return new Group(
      title: parsedJson['title'] ?? '',
      description: parsedJson['description'] ?? '',
      location: parsedJson['location'] ?? '',
      tag: parsedJson['tag'] ?? [],
      groupId: parsedJson['groupId'] ?? '',
      userId: parsedJson['userId'] ?? '',
      commentId: parsedJson['commentId'] ?? '',
      createdDate: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': this.title,
      'description': this.description,
      'location': this.location,
      'tag': this.tag,
      'groupId': this.groupId,
      'userId': this.userId,
      'commentId': this.commentId,
      'createdDate': this.createdDate,
    };
  }
}
