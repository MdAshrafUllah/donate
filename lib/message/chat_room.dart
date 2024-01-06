import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatRoom extends StatefulWidget {
  final String chatRoomId;
  final Map<String, dynamic> userMap;

  const ChatRoom({
    Key? key,
    required this.chatRoomId,
    required this.userMap,
  }) : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  File? imageFile;
  final scrollController = ScrollController();
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        _isUserScrolling = true;
      }
    });
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);

      if (!_isUserScrolling) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Color getDotColor(String status) {
    if (status == 'Online') {
      return Colors.greenAccent;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.userMap['profilePicture']),
              ),
              SizedBox(width: 8), // Adjust spacing as needed
              Text(
                widget.userMap['name'],
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('chatroom')
                    .doc(widget.chatRoomId)
                    .collection('chats')
                    .orderBy("time", descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasData) {
                    final messages = snapshot.data!.docs;
                    return SingleChildScrollView(
                      reverse: true,
                      child: Column(
                        children: messages.map((message) {
                          Map<String, dynamic> map = message.data();
                          return buildMessageWidget(
                              size, map, context, scrollController);
                        }).toList(),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Center(
              child: Container(
                height: size.height / 10,
                width: size.width,
                alignment: Alignment.center,
                child: SizedBox(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height / 15,
                        width: size.width / 1.3,
                        child: TextField(
                            controller: _message,
                            decoration: InputDecoration(
                                hintText: "Send Message",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                )),
                            style: const TextStyle(
                              color: Colors.black,
                            )),
                      ),
                      IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Color(0xFF39b54a),
                          ),
                          onPressed: onSendMessage),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Rename the function to buildMessageWidget to avoid naming conflict
  Widget buildMessageWidget(Size size, Map<String, dynamic> map,
      BuildContext context, ScrollController scrollController) {
    if (map['type'] == "text") {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        width: size.width,
        alignment: map['sendby'] == auth.currentUser!.displayName
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          decoration: map['sendby'] == auth.currentUser!.displayName
              ? const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      topRight: Radius.circular(10)),
                  color: Colors.grey,
                )
              : const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(10)),
                  color: Color(0xFF39b54a),
                ),
          child: Text(
            map['message'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else if (map['type'] == "file") {
      return Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        alignment: map['sendby'] == auth.currentUser!.displayName
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: InkWell(
          onTap: () {},
          child: Container(
            height: size.height / 22,
            width: size.width / 2,
            decoration: map['sendby'] == auth.currentUser!.displayName
                ? const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        topRight: Radius.circular(10)),
                    color: Colors.grey,
                  )
                : const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                        topLeft: Radius.circular(10)),
                    color: Color(0xFF39b54a),
                  ),
            alignment: map['message'] != "" ? null : Alignment.center,
            child: map['message'] != ""
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.file_present,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'file',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )
                    ],
                  ) // Display file icon
                : const SizedBox(
                    height: 24, // Adjust the height as needed
                    width: 24, // Adjust the width as needed
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
          ),
        ),
      );
    } else if (map['type'] == "img") {
      return Container(
        height: size.height / 2.5,
        width: size.width,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        alignment: map['sendby'] == auth.currentUser!.displayName
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ShowImage(
                imageUrl: map['message'],
              ),
            ),
          ),
          child: Container(
            height: size.height / 2.5,
            width: size.width / 2,
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            alignment: map['message'] != "" ? null : Alignment.center,
            child: map['message'] != ""
                ? Image.network(
                    map['message'],
                    fit: BoxFit.cover,
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      );
    }
    return Container();
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: CachedNetworkImage(imageUrl: imageUrl),
      ),
    );
  }
}
