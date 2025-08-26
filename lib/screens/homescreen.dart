import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  bool search = false;

  String? myUsername, myName, myEmail, mypicture;
  TextEditingController messageController = TextEditingController();
  getthesharedpref() async {
    myUsername = await SharedPreferenceHelper().getUserName();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    mypicture = await SharedPreferenceHelper().getUserImage();

    setState(() {});
  }

  var queryResultSet = [];
  var tempSearchStore = [];
  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        search = false;
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      search = true;
    });
    var capitalizeValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      for (var element in queryResultSet) {
        if (element['username'].startsWith(capitalizeValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getthesharedpref();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // top: false,
      child: Scaffold(
        backgroundColor: Color(0xff703eff),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Image.asset(
                    'images/wave.png',
                    width: 40,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text("Hello, Sanjeev",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                    width: 28,
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white),
                    child: Icon(Icons.person)),
              ],
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                "Welcome To ",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            // SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                "ChatUp",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25)),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: Color(0xffececf8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search Username",
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          initiateSearch(value.toUpperCase());
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    search
                        ? ListView(
                            padding: EdgeInsets.only(left: 0.0, right: 10.0),
                            primary: false,
                            shrinkWrap: true,
                            children: tempSearchStore.map((element) {
                              return buildResultCard(element);
                            }).toList())
                        : Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Material(
                              elevation: 3.0,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage('images/boy.jpg'),
                                ),
                                title: Text(
                                  "Sanjeev Gupta",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("Hey, how are you?"),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Text("2:30 PM",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        search = false;
        var chatRoomId = getChatRoomIdbyUsername(myUsername!, data['username']);
        Map<String, dynamic> chatInfoMap = {
          "users": [myUsername, data['username']],
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                name: data['Name'],
                username: data['username'],
                profileUrl: data['Image'],
              ),
            ));
      },
      child: Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Material(
          elevation: 3.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(data['Image']),
            ),
            title: Text(
              data['Name'],
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),

            // subtitle: Text("Hey, how are you?"),
          ),
        ),
      ),
    );
  }
}
