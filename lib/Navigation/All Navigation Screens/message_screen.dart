import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../message/chat_room.dart';
import '../../widget/initialize_current_user.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late List<Contact> contacts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    setState(() {
      isLoading = true;
    });
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
        String contactStatus = userSnapshot['status'];

        Contact newContact = Contact(
          uid: contactUid,
          name: contactName,
          profileImage: profileImageUrl,
          status: contactStatus,
        );
        contacts.add(newContact);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
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
      return Colors.lightGreen;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            return Future<void>.delayed(const Duration(seconds: 1));
          },
          child: contacts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(
                    child: Text("You don't have any Message Contact"),
                  ),
                )
              : ListView.builder(
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            title: Row(
                              children: [
                                Text(contacts[index].name),
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getDotColor(contacts[index].status),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: const Text('Loading...'),
                          );
                        } else if (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty) {
                          Map<String, dynamic> lastMessage =
                              snapshot.data!.docs[0].data()
                                  as Map<String, dynamic>;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(contacts[index].profileImage),
                            ),
                            title: Row(
                              children: [
                                Text(contacts[index].name),
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getDotColor(contacts[index].status),
                                  ),
                                ),
                              ],
                            ),
                            subtitle:
                                Text(lastMessage['message'] ?? 'No messages'),
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
                                      'profilePicture':
                                          contacts[index].profileImage,
                                      'status': contacts[index].status
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(contacts[index].profileImage),
                            ),
                            title: Row(
                              children: [
                                Text(contacts[index].name),
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getDotColor(contacts[index].status),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: const Text('No messages'),
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
                                      'profilePicture':
                                          contacts[index].profileImage,
                                      'status': contacts[index].status
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
      ),
    );
  }
}

class Contact {
  final String uid;
  final String name;
  final String profileImage;
  final String status;

  Contact({
    required this.uid,
    required this.name,
    required this.profileImage,
    required this.status,
  });
}
