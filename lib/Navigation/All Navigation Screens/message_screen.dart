import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../message/chat_room.dart';
import '../../widget/initialize_current_user.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    try {
      String currentUserUid = AuthService.currentUser!.uid;

      QuerySnapshot<Map<String, dynamic>> contactsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserUid)
              .collection('contacts')
              .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> contact
          in contactsSnapshot.docs) {
        String contactUid = contact.id;
        String contactName = contact['name'];

        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(contactUid)
                .get();

        String profileImageUrl = userSnapshot['profileImage'];

        Contact newContact = Contact(
          uid: contactUid,
          name: contactName,
          profileImage: profileImageUrl,
        );
        contacts.add(newContact);
      }

      setState(() {});
    } catch (e) {
      print('Error fetching contacts: $e');
    }
  }

  static String chatRoomId(String uid1, String uid2) {
    String channelId;
    if (uid1.compareTo(uid2) < 0) {
      channelId = "$uid1-$uid2";
    } else {
      channelId = "$uid2-$uid1";
    }
    return channelId;
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          return Future<void>.delayed(const Duration(seconds: 1));
        },
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (BuildContext context, int index) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatroom')
                  .doc(chatRoomId(AuthService.currentUser!.displayName!,
                      contacts[index].name))
                  .collection('chats')
                  .orderBy("time", descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text(contacts[index].name),
                    subtitle: Text('Loading...'),
                  );
                } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  Map<String, dynamic> lastMessage =
                      snapshot.data!.docs[0].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(contacts[index].profileImage),
                    ),
                    title: Text(contacts[index].name),
                    subtitle: Text(lastMessage['message'] ?? 'No messages'),
                    onTap: () {
                      String roomId = chatRoomId(
                          AuthService.currentUser!.displayName!,
                          contacts[index].name);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatRoom(
                            chatRoomId: roomId,
                            userMap: {
                              'name': contacts[index].name,
                              'profilePicture': contacts[index].profileImage
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  // If there are no messages
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(contacts[index].profileImage),
                    ),
                    title: Text(contacts[index].name),
                    subtitle: Text('No messages'),
                    onTap: () {
                      String roomId = chatRoomId(
                          AuthService.currentUser!.displayName!,
                          contacts[index].name);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatRoom(
                            chatRoomId: roomId,
                            userMap: {
                              'name': contacts[index].name,
                              'profilePicture': contacts[index].profileImage
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class Contact {
  final String uid;
  final String name;
  final String profileImage;

  Contact({
    required this.uid,
    required this.name,
    required this.profileImage,
  });
}
