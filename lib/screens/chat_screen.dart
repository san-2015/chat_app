import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  String name, profileUrl, username;
  ChatScreen(
      {required this.name, required this.profileUrl, required this.username});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream? messageStream;
  String? myUsername, myName, myEmail, mypicture, chatRoomid, messageId;
  TextEditingController messageController = TextEditingController();

  getthesharedpref() async {
    myUsername = await SharedPreferenceHelper().getUserName();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    mypicture = await SharedPreferenceHelper().getUserImage();

    chatRoomid = getChatRoomIdbyUsername(widget.username, myUsername!);
    setState(() {});
  }

  addMessage(bool sendClicked) async {
    if (messageController.text != "") {
      String message = messageController.text;
      messageController.text = "";
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUsername,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "image": mypicture,
      };
      messageId = randomAlphaNumeric(10);
      await DatabaseMethods()
          .addMessage(chatRoomid!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": myUsername,
        };
        DatabaseMethods()
            .updateLastMessageSend(chatRoomid!, lastMessageInfoMap);
        if (sendClicked) {
          message = "";
        }
      });
    }
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      children: [
        Flexible(
            child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(24))),
        ))
      ],
    );
  }

  Widget chatMessage() {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return chatMessageTile(
                        ds[" message"], myUsername == ds["sendBy"]);
                  })
              : Container();
        });
  }

  @override
  initState() {
    super.initState();
    getthesharedpref();
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff703eff),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff703eff),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Sanjeev Gupta",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(7),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                        topRight: Radius.circular(15))),
                child: Text("Hey How are you?",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(7),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
                    child: Text("I am fine, thank you!",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              Spacer(),
              Row(children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xff703eff)),
                  child: Icon(Icons.keyboard_voice, color: Colors.white),
                ),
                Expanded(
                  child: Container(
                    // width: double.maxFinite,
                    decoration: BoxDecoration(
                        color: Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: " Write a message",
                          suffixIcon:
                              Icon(Icons.attach_file, color: Color(0xff703eff)),
                        )),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    addMessage(true);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10, left: 10),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xff703eff)),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ]),
              SizedBox(height: 10),
            ],
          )),
    );
  }
}
