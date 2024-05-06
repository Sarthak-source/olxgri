import 'dart:developer';

import 'package:com.agrobs/screens/animal_product_details_screen.dart';
import 'package:com.agrobs/screens/color_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './edit_ad_screen.dart';
import './new_ad_screen.dart';
import './products_by_category_screen.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';

class SubCategoriesScreen extends StatelessWidget {
  static const routeName = '/subcategories';

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    Map pushedArguments = ModalRoute.of(context)!.settings.arguments as Map;
    //print(pushedArguments);
    //print(subCategories);
    print('pushedArguments[' '].toString()');
    print('pushedArguments[' '].toString()');
    print('pushedArguments[' '].toString()');
    print('pushedArguments[' '].toString()');
    print(pushedArguments['newAd'].toString());
    print(pushedArguments['newAd'].runtimeType);
    bool newAd = pushedArguments['newAd'].runtimeType == bool
        ? pushedArguments['newAd']
        : pushedArguments['newAd']['newAd'];
    bool editAd = pushedArguments['newAd'].runtimeType == bool
        ? pushedArguments['editAd']
        : pushedArguments['editAd']['editAd'];

    bool isMainRoute = false;
    if (pushedArguments.isNotEmpty) {
      pushedArguments as Map<String, dynamic>;
      isMainRoute = pushedArguments['main'] ?? false;
    }

    print(
        "here is modul rout=+++++++++++++++++++++++++++{$pushedArguments} and here is extracted value ${isMainRoute}");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          langPack['Select sub category']!,
          textDirection: CurrentUser.textDirection,
          // pushedArguments['chosenCat'].name,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: HexColor(),
        foregroundColor: Colors.grey[800],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          if (!newAd)
            ListTile(
              title: Text(
                langPack['Show']! + ' ' + langPack['All']!,
                textDirection: CurrentUser.textDirection,
              ),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(ProductsByCategoryScreen.routeName, arguments: {
                  'chosenCat': pushedArguments['chosenCat'],
                  'chosenSubCat': '',
                });
              },
            ),
          Expanded(
              child: GridView.builder(
            padding: EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount:
                // 100,

                pushedArguments['chosenCat'].subCategory.length,
            itemBuilder: (ctx, i) {
              print(pushedArguments['chosenCat']);
              return InkWell(
                  onTap: isMainRoute == true
                      ? () {
                          print(
                              "this screen has been passed===================");
                          Navigator.of(context)
                              .pushNamed(NewAdScreen.routeName, arguments: {
                            'chosenCat': pushedArguments['chosenCat'],
                            'chosenSubCat':
                                pushedArguments['chosenCat'].subCategory[i],
                          });
                        }
                      : () {
                          Navigator.of(context).pushNamed(
                              AnimalProductDetailsScreen.routeName,
                              arguments: {
                                'chosenCat': pushedArguments['chosenCat'],
                                'chosenSubCat':
                                    pushedArguments['chosenCat'].subCategory[i],
                              });
                        },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (pushedArguments['chosenCat']
                                .subCategory[i]
                                .picture !=
                            null)
                          Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: CachedNetworkImage(
                                imageUrl:
                                    //  "https://media.istockphoto.com/id/483797166/photo/andalusian-horse.jpg?s=612x612&w=0&k=20&c=2Xu8veyHqHMZP7OAJwkfihgJo0bsGhz0e1yGAGw7E4Y="
                                    // ,
                                    pushedArguments['chosenCat']
                                        .subCategory[i]
                                        .picture,
                                fit: BoxFit.fitWidth,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )
                              //  Image.network(
                              //     ),
                              ),
                        Center(
                          child: Text(
                            // 'MARWARI',
                            pushedArguments['chosenCat'].subCategory[i].name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        )
                      ]));
            },
          ))

          //  Expanded(
          //     child: ListView.builder(
          //       itemCount: pushedArguments['chosenCat'].subCategory.length,
          //       itemBuilder: (ctx, i) {
          //         return ListTile(
          //           onTap: () {
          //             if (newAd) {
          //               Navigator.of(context)
          //                   .pushNamed(NewAdScreen.routeName, arguments: {
          //                 'chosenCat': pushedArguments['chosenCat'],
          //                 'chosenSubCat':
          //                     pushedArguments['chosenCat'].subCategory[i],
          //               });
          //             } else if (editAd) {
          //               Navigator.of(context)
          //                   .pushNamed(EditAdScreen.routeName, arguments: {
          //                 'chosenCat': pushedArguments['chosenCat'],
          //                 'chosenSubCat':
          //                     pushedArguments['chosenCat'].subCategory[i],
          //               });
          //             } else {
          //               Navigator.of(context).pushNamed(
          //                   ProductsByCategoryScreen.routeName,
          //                   arguments: {
          //                     'chosenCat': pushedArguments['chosenCat'],
          //                     'chosenSubCat': pushedArguments['chosenCat']
          //                         .subCategory[i],
          //                   });
          //             }
          //           },
          //           leading: pushedArguments['chosenCat']
          //                       .subCategory[i]
          //                       .picture !=
          //                   null
          //               ? Padding(
          //                   padding: const EdgeInsets.all(5.0),
          //                   child: CachedNetworkImage(
          //                     imageUrl: pushedArguments['chosenCat']
          //                         .subCategory[i]
          //                         .picture,
          //                     fit: BoxFit.fitWidth,
          //                     placeholder: (context, url) =>
          //                         CircularProgressIndicator(),
          //                     errorWidget: (context, url, error) =>
          //                         Icon(Icons.error),
          //                   )
          //                   //  Image.network(
          //                   //     ),
          //                   )
          //               : null,
          //           title: Text(
          //               pushedArguments['chosenCat'].subCategory[i].name),
          //         );
          //       },
          //     ),
          //   )
        ],
      ),
    );
  }
}
