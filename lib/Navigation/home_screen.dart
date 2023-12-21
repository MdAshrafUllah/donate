import 'package:flutter/material.dart';
import 'package:utsargo/Navigation/Item_details_page.dart';

import 'demo_items.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Color(0xFF39b54a),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: size.width / 30,
                      right: size.width / 30,
                    ),
                    height: size.height / 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[200],
                      border: Border.all(width: 1, color: Colors.black26),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _locationController,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: size.width / 30,
                        fontWeight: FontWeight.bold,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Color(0xFF39b54a),
                      decoration: InputDecoration(
                        hintText: 'Location',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: size.width / 30,
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                MaterialButton(
                  minWidth: size.width / 20,
                  height: size.height / 20,
                  onPressed: () {},
                  color: Color(0xFF39b54a),
                  child: Text(
                    'Go',
                    style: TextStyle(
                        fontSize: size.width / 22, color: Colors.white),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        color: Color(0xFF39b54a),
                      ),
                      Text(
                        'Filter',
                        style: TextStyle(fontSize: size.width / 24),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: listItem.map((item) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemDetailsPage(
                                  item: item,
                                )),
                      );
                    },
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: size.height / 6.5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(item["image"]),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MaterialButton(
                                    onPressed: () {
                                      setState(() {
                                        item["isSaved"] = !item["isSaved"];
                                      });
                                    },
                                    color: Colors.white,
                                    height: size.height * 0.04,
                                    minWidth: size.width * 0.085,
                                    padding: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      item["isSaved"]
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      size: size.height * 0.03,
                                      color: item["isSaved"]
                                          ? Color(0xFF39b54a)
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Color(0xFF39b54a),
                                size: size.width * 0.035,
                              ),
                              Text(
                                item["subtitle"],
                                style: TextStyle(
                                  fontSize: size.width * 0.035,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Expanded(
                            child: Text(
                              item["title"],
                              style: TextStyle(
                                fontSize:
                                    size.width * 0.05, // Adjusted font size
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
