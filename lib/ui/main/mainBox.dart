import 'package:cloud_firestore/cloud_firestore.dart';
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
    return
    Scaffold(
      body: Align(
          child: Center(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("groups")
                    .snapshots(),
                builder: buildUserList
              )
          )
      )
    );
  }

  Widget buildUserList(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    print("snapshot has data? ${snapshot.hasData}");
    print("snapshot has data? ${snapshot.data.size}");
    if (snapshot.hasData && snapshot.data.size != 0) {
      return ListView.builder(
        itemCount: snapshot.data.docs.length,
        itemBuilder: (context, index) {
          String title = snapshot.data.docs[index]['title'];
          String eventDate = snapshot.data.docs[index]['eventDate'];

          return ListTile(
            selectedTileColor: Colors.amber,
            onTap: () {print("hello");},
            title: Text(title),
            subtitle: Text(eventDate.toString()),
          );
        },
      );
    } else if (snapshot.data.size == 0) {
      return Center(
        child:
          Image.asset('assets/images/empty.jpg')
      );
    } else {
      return CircularProgressIndicator();
    }
  }

}
