import 'package:flutter/material.dart';

import 'demo_items.dart';

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> item;

  ItemDetailsPage({required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Food Details',
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF39b54a),
          iconTheme:
              IconThemeData(color: Colors.white, size: size.width * 0.07),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.item["image"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Text(
                  widget.item["title"],
                  style: TextStyle(
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Color(0xFF39b54a),
                      size: size.width * 0.04,
                    ),
                    Text(
                      widget.item["subtitle"],
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          widget.item["isSaved"] = !widget.item["isSaved"];
                        });
                      },
                      color: Colors.white70,
                      height: size.height * 0.04,
                      minWidth: size.width * 0.085,
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.item["isSaved"]
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: size.height * 0.03,
                        color: widget.item["isSaved"]
                            ? Color(0xFF39b54a)
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description:',
                      style: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.item['description'],
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.justify,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comments:',
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          comments.add(_commentController.text);
                          _commentController.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF39b54a),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8.0), // Set your desired border radius here
                        ),
                      ),
                      child: Text('Submit'),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            comments[index],
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
