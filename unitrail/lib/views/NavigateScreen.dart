import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:search_choices/search_choices.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  _NavigateState createState() => _NavigateState();
}

class _NavigateState extends State<NavigateScreen> {
  //Variables to hold responses to search_choices
  var start;
  var dest;

  @override
  Widget build(BuildContext context) {
    //readData() returns all buildings and all rooms currently stored in the database
    Future<List<DropdownMenuItem<String>>> readData() async {
      CollectionReference buildings =
          FirebaseFirestore.instance.collection("Buildings");
      //Secondary function to assure async executiong
      Future<List<DropdownMenuItem<String>>> db_call() async {
        //get list of buldings
        var buildSnap = await buildings.get();
        //Buildrooms is the final list object we aggregate for the search_choice widget
        List<DropdownMenuItem<String>> buildRooms = [];
        //For all buildings
        for (var building in buildSnap.docs) {
          var floorsnap =
              await buildings.doc(building.id).collection("Floors").get();
          //For every floor on current building
          for (var floor in floorsnap.docs) {
            //print(floor.id);
            var roomsnap = await buildings
                .doc(building.id)
                .collection("Floors")
                .doc(floor.id)
                .get();
            var data;
            //Null check room documents
            if (roomsnap.exists) {
              data = await roomsnap.data();
            }
            //For every room on given floor
            for (var room in data.keys) {
              //create dropDownMenuItem with string of "building" + "room #"
              var toAdd = await (DropdownMenuItem(
                value: building.id + room,
                child: Text(building.id + room),
              ));
              buildRooms.add(toAdd);
            }
          }
        }
        //First function return
        return buildRooms;
      }

      //final async return call
      return await db_call();
    }

    Size size = MediaQuery.of(context)
        .size; // This provides the total width and height of our screen
    return Scaffold(
        appBar: AppBar(
            title: Image.asset(
              "assets/images/logo.png",
              fit: BoxFit.contain,
              height: 5.h,
            ),
            toolbarHeight: 7.h,
            backgroundColor: const Color(0xFFa31621),
            actions: const []),
        body: Center(
            child: Column(
                mainAxisSize: MainAxisSize.min,

                //Widget list for given page.
                children: <Widget>[
              SizedBox(height: size.height * 0.1),
              const Text(
                "Testing",
                style: TextStyle(
                  color: Color.fromARGB(255, 1, 16, 129),
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: size.height * 0.1),

              const Text("Begining"),

              //Future Builder for start location searchChoices
              FutureBuilder(
                  future: readData(),
                  builder: (context,
                      AsyncSnapshot<List<DropdownMenuItem<String>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      var buildRooms = snapshot.data;
                      //print(buildRooms);
                      return SearchChoices.single(
                        items: buildRooms,
                        value: start,
                        hint: "Select one",
                        searchHint: "Select one",
                        onChanged: (value) {
                          setState(() {
                            start = value;
                          });
                        },
                        isExpanded: true,
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),

              const Text("Destination"),

              //Future Builder for Destination Search choices
              FutureBuilder(
                  future: readData(),
                  builder: (context,
                      AsyncSnapshot<List<DropdownMenuItem<String>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      var buildRooms = snapshot.data;
                      //print(buildRooms);
                      return SearchChoices.single(
                        items: buildRooms,
                        value: dest,
                        hint: "Select one",
                        searchHint: "Select one",
                        onChanged: (value) {
                          setState(() {
                            dest = value;
                          });
                        },
                        isExpanded: true,
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),

              //Crud testing button
            ])));
  }
}