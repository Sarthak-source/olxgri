import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './filter_screen.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';
import '../widgets/grid_products.dart';

class AnimalProductDetailsScreen extends StatefulWidget {
  static const routeName = '/animmal-products-by-category';

  @override
  _AnimalProductDetailsScreenState createState() =>
      _AnimalProductDetailsScreenState();
}

class _AnimalProductDetailsScreenState
    extends State<AnimalProductDetailsScreen> {
  String _sortingOrder = '';
  List<Map> filters = [];

  String _sortingType = '';
  final index = 4;
  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    final Map<String, dynamic> pushedMap =
        ModalRoute.of(context)!.settings.arguments as dynamic;
    
    return Scaffold(
      appBar: AppBar(
        actions: [   
          SizedBox(width: 4,),

                 Icon(Icons.share),
SizedBox(width: 4,),
          Icon(Icons.notification_important),
                    SizedBox(width: 4,),

        ],
        title: Text(
          pushedMap['chosenSubCat'] != ''
              ? pushedMap['chosenSubCat'].name
              : pushedMap['chosenCat'].name,
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl:
                      //  "https://media.istockphoto.com/id/483797166/photo/andalusian-horse.jpg?s=612x612&w=0&k=20&c=2Xu8veyHqHMZP7OAJwkfihgJo0bsGhz0e1yGAGw7E4Y="
                      // ,
               pushedMap['chosenSubCat'] .picture
           ,
                  fit: BoxFit.cover,
                  width:  MediaQuery.of(context).size.width,
                  height:MediaQuery.of(context).size.height/2.5 ,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height:50,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    color: Colors.black87,
                    child: Text(
                        pushedMap['chosenSubCat'] .name ,
                      
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ExpansionTile(
                title: Text("General Information"),
                maintainState: true,
                backgroundColor: Colors.yellow,
                collapsedBackgroundColor: Colors.yellow,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                collapsedShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                children: [
                  Text("General Information"),
                  Text("General Information"),
                  const Text("General Information")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ExpansionTile(
                title: Text("Fodder"),
                maintainState: true,
                backgroundColor: Colors.yellow,
                collapsedBackgroundColor: Colors.yellow,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                collapsedShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                children: [
                  Text("Fodder"),
                  Text("Fodder"),
                  const Text("Fodder")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ExpansionTile(
                title: Text("Care Of Breed"),
                maintainState: true,
                backgroundColor: Colors.yellow,
                collapsedBackgroundColor: Colors.yellow,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                collapsedShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                children: [
                  Text("Care Of Breed"),
                  Text("Care Of Breed"),
                  const Text("Care Of Breed")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ExpansionTile(
                title: Text("Diseases and Treatment"),
                maintainState: true,
                backgroundColor: Colors.yellow,
                collapsedBackgroundColor: Colors.yellow,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                collapsedShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                children: [
                  Text("Diseases and Treatment"),
                  Text("Diseases and Treatment"),
                  const Text("Diseases and Treatment")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ExpansionTile(
                title: Text("References"),
                maintainState: true,
                backgroundColor: Colors.yellow,
                collapsedBackgroundColor: Colors.yellow,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                collapsedShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                children: [
                  Text("References"),
                  Text("References"),
                  const Text("References")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
