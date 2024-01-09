// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utsargo/widget/initialize_current_user.dart';

class ReceiverDeliveryStatus extends StatefulWidget {
  String foodImage;
  String foodTitle;
  String? senderId;
  String? postId;
  ReceiverDeliveryStatus(
      {super.key,
      required this.foodImage,
      required this.foodTitle,
      this.senderId,
      this.postId});

  @override
  State<ReceiverDeliveryStatus> createState() => _ReceiverDeliveryStatusState();
}

class _ReceiverDeliveryStatusState extends State<ReceiverDeliveryStatus> {
  bool? receivingDirectly;
  bool? receivingByDeliver;
  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Delivery Progress'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.2,
                    width: size.width * 0.2,
                    child: Image.network(widget.foodImage),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.foodTitle,
                    style: TextStyle(fontSize: size.width * 0.05),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: size.height * 0.03,
                      width: size.width * 0.03,
                      decoration: BoxDecoration(
                        color: ((receivingDirectly ?? false) ||
                                (receivingByDeliver ?? true))
                            ? const Color(0xFF39b54a)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF39b54a), width: 2),
                      ),
                      child: Center(
                        child: Container(
                          height: size.height * 0.02,
                          width: size.width * 0.02,
                          decoration: const BoxDecoration(
                            color: Color(0xFF39b54a),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 5,
                      width: size.width * 0.3,
                      color: ((receivingDirectly ?? false) ||
                              (receivingByDeliver ?? true))
                          ? const Color(0xFF39b54a)
                          : Colors.grey,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: size.height * 0.03,
                      width: size.width * 0.03,
                      decoration: BoxDecoration(
                        color: ((receivingDirectly ?? false) ||
                                (receivingByDeliver ?? true))
                            ? const Color(0xFF39b54a)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF39b54a), width: 2),
                      ),
                      child: Center(
                        child: Container(
                          height: size.height * 0.02,
                          width: size.width * 0.02,
                          decoration: const BoxDecoration(
                            color: Color(0xFF39b54a),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 5,
                      width: 100,
                      color: ((receivingDirectly ?? false) ||
                              (receivingByDeliver ?? false))
                          ? const Color(0xFF39b54a)
                          : Colors.grey,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: size.height * 0.03,
                      width: size.width * 0.03,
                      decoration: BoxDecoration(
                        color: ((receivingDirectly ?? false) ||
                                (receivingByDeliver ?? false))
                            ? const Color(0xFF39b54a)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF39b54a), width: 2),
                      ),
                      child: Center(
                        child: Container(
                          height: size.height * 0.02,
                          width: size.width * 0.02,
                          decoration: const BoxDecoration(
                            color: Color(0xFF39b54a), // Green color
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Sent",
                      style: TextStyle(fontSize: size.width * 0.035),
                    ),
                    Text("on they way",
                        style: TextStyle(fontSize: size.width * 0.035)),
                    Text("Delivered",
                        style: TextStyle(fontSize: size.width * 0.035))
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (widget.senderId != AuthService.currentUser!.uid)
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                            "Are you Receiving the food to the Owner Directly?"),
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text('Yes'),
                                Checkbox(
                                  value: receivingDirectly == true,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      receivingDirectly = newValue;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('No'),
                                Checkbox(
                                  value: receivingDirectly == false,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      receivingDirectly = !newValue!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                    if (receivingDirectly == false)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Are you Receiving the food by Delivery?"),
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Text('Yes'),
                                  Checkbox(
                                    value: receivingByDeliver == true,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        receivingByDeliver = newValue;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('No'),
                                  Checkbox(
                                    value: receivingByDeliver == false,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        receivingByDeliver = !newValue!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                  ],
                ),
              if (receivingDirectly == true || receivingByDeliver == true)
                ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(AuthService.currentUser!.uid)
                          .collection('complete Received')
                          .add({
                        'senderId': widget.senderId,
                        'postTitle': widget.foodTitle,
                        'postImage': widget.foodImage,
                      });

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(AuthService.currentUser!.uid)
                          .collection('forReceive')
                          .where('postId', isEqualTo: widget.postId)
                          .get()
                          .then((querySnapshot) {
                        for (var doc in querySnapshot.docs) {
                          doc.reference.delete();
                        }
                      });

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                          content: Text(
                            'Successfully received the Food',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                          )));
                      Navigator.pushReplacementNamed(
                          context, "/navigationScreen",
                          arguments: 3);
                    },
                    child: const Text("Confirm"))
            ],
          ),
        ),
      ),
    );
  }
}
