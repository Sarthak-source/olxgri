import 'dart:async';

import 'package:com.agrobs/helpers/api_helper.dart';
import 'package:com.agrobs/providers/video_provider.dart';
import 'package:com.agrobs/screens/color_helper.dart';
import 'package:advertising_id/advertising_id.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/ad_manager.dart';
import '../helpers/app_config.dart';
import '../helpers/current_user.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/product.dart';
import '../providers/languages.dart';
import '../providers/products.dart';
import '../screens/all_categories_screen.dart';
import '../screens/location_search_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/search_ad_screen.dart';
import '../widgets/category_tile.dart';
import '../widgets/product_item.dart';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Product> latestProducts = [];
  List<Product> featuredProducts = [];
  List<Category> categories = [];
  late Razorpay razorpay;

//! # native_admob_flutter: ^1.5.0+1 deprecated
//AdManager.adMobNativeAdUnit
  // final controller = NativeAdController();

  //var adLoaded = false;

  late StreamSubscription _subscription;
  double _height = 0;
  final _adUnitId = 'ca-app-pub-9259101471660565/8555196884';

  //final _adUnitId = 'ca-app-pub-3940256099942544/8135179316';
  final _pageSize = 8;
  var _scrollController = ScrollController();
  int _listLength = 1;
  int productLimit = 8;
  bool firstBuild = true;
  bool isOnBottom = false;
  bool allPagesAreFetched = false;
  bool loadingNewPage = false;
  int page = 1;

  bool isFacebookAdsShow = false;

  final PagingController<int, ProductItem> _pagingController =
      PagingController(firstPageKey: 1);

  //! # native_admob_flutter: ^1.5.0+1 deprecated
  // void printAdDetails(NativeAdController controller) async {
  //   /// Just for showcasing the ability to access
  //   /// NativeAd's details via its controller.
  //   print("------- NATIVE AD DETAILS: -------");
  //   print(controller.headline);
  //   print(controller.body);
  //   print(controller.price);
  //   print(controller.store);
  //   print(controller.callToAction);
  //   print(controller.advertiser);
  //   print(controller.iconUri);
  //   print(controller.imagesUri);
  //   print("----END----");
  // }

  // @override
  // void dispose() {
  //   if (AppConfig.googleBannerOn) controller.dispose();
  //   super.dispose();
  //   razorpay.clear(); // Removes all listeners

  // }

  void handlerPaymentSuccess() {
    print(
        "Pament successssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");
    // Toast.sow("Pament success", context);
  }

  void handlerErrorFailure() {
    print(
        "Pament errorssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");
    //Toast.show("Pament error", context);
  }

  void handlerExternalWallet() {
    print(
        "External Walletsssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");
    //Toast.show("External Wallet", context);
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_qENDyMgfHKkgqr",
      "amount": "100000",
      "name": "Sample App",
      "description": "Payment for the some random product",
      "prefill": {"contact": "61861183", "email": "savykevin100@gmail.com"},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  // final List<Map<String, String>> videos = [
  //   {
  //     'title': 'Video Title 1',
  //     'link':
  //         'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
  //   },
  //   {
  //     'title': 'Video Title 2',
  //     'link':
  //         'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
  //   },
  //   {
  //     'title': 'Video Title 3',
  //     'link':
  //         'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
  //   },
  //   {
  //     'title': 'Video Title 4',
  //     'link':
  //         'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
  //   },
  //   // Add more videos as needed
  // ];

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'));

    _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: true,
    );

    /// Test payment gateway
    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);

    ///
    SharedPreferences.getInstance()
        .then((value) => value.setBool("is_fresh_install", false));

    AdvertisingId.id()
        .then((value) => print(" ${AppConfig.googleBannerOn} ididid $value"));

//! # native_admob_flutter: ^1.5.0+1 deprecated
    // if (AppConfig.googleBannerOn) {
    //   controller.load(keywords: ['valorant', 'games', 'fortnite']);
    //   controller.onEvent.listen((event) {
    //     if (event.keys.first == NativeAdEvent.loaded) {
    //       printAdDetails(controller);
    //       setState(() {
    //         //adLoaded = true;
    //       });
    //     }
    //   });
    // }
    _scrollController.addListener(() async {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          // You're at the top.
        } else {
          // You're at the bottom.
          print('Congrats... you reached the bottom....');
          if (!allPagesAreFetched && !loadingNewPage) {
            page++;
            // List<MainProduct> newProducts = [];
            setState(() {
              loadingNewPage = true;
              Timer(
                  Duration(milliseconds: 1),
                  () => _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.fastOutSlowIn,
                      ));
            });
            // newProducts = await Provider.of<Products>(context, listen: false)
            //     .fetchHomeLatestProducts();
            // setState(() {
            //   loadingNewPage = false;
            // });
            // print('The LEEEEEEEEENGTH ${newProducts.length}');
            // if (newProducts.length > 0) {
            //   // for (int i = 0; i < newProducts.length; i++) {
            //   latestProducts.addAll(newProducts);
            //   // }
            //   setState(() {
            //     _listLength++;
            //   });
            //
            //   if (newProducts.length < productLimit) {
            //     allPagesAreFetched = true;
            //   }
            // } else {
            //   allPagesAreFetched = true;
            // }
          }
        }
      }
    });
    // _nativeAdController.setTestDeviceIds(['74580191A8FF7F0BAD9FE7F6B7FDA9D0']);

    if (!AppConfig.googleBannerOn) {
      FacebookAudienceNetwork.init(
        // testingId: "2244587745860156_2351931271792469", //optional
        testingId: "745FD4A0981807548C46C1EDCBF8696B",
      ); //optional,
      //testingId: "b4fb76e00d3f078b6c88fc1da96926b6");
      // testingId: "c0f6a182-ab95-4a94-8a37-1e21d137fe04");
      // _nativeAdController.setNonPersonalizedAds(true);

      //if (!isFacebookAdsShow) {
      AdManager.loadInterstitialAd();
      isFacebookAdsShow = true;
      //}
    }

    if (AppConfig.FCM_COUNT % 10 == 0) _handleFirebaseToken();

    AppConfig.FCM_COUNT++;
    _handleFirebaseTokenRefresh();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  _handleFirebaseToken() async {
    AdvertisingId.id().then((deviceID) {
      final apiHelper = Provider.of<APIHelper>(context, listen: false);
      apiHelper
          .addFirebaseDeviceToken(
              userId: CurrentUser.id,
              deviceId: deviceID,
              name: CurrentUser.name,
              token: AppConfig.FCM_ID)
          .then((result) {
        if (result != null) {
          if (!result) _handleFirebaseToken();
        }
      });
    });
  }

  _handleFirebaseTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      AppConfig.FCM_ID = newToken;
      var pref = SharedPreferences.getInstance();
      pref.then((sharePref) {
        sharePref.setString("token_id", AppConfig.FCM_ID);
      });

      _handleFirebaseToken();
    });
  }

//! # native_admob_flutter: ^1.5.0+1 deprecated
  Widget _getAdContainer() {
    // return AppConfig.googleBannerOn
    //     ? Container(
    //   child: controller.isLoaded
    //       ? AdManager.nativeAdsView()
    //       : Container(
    //     child: Text("Banner"),
    //   ),
    // )
    return AppConfig.googleBannerOn
        ? Container(
            child: Text("Banner"),
          )
        : Container(
            alignment: Alignment(0.5, 1),
            child: FacebookNativeAd(
              //need a new placement id for advanced native ads
              placementId: (AdManager.fbNativePlacementId)!,
              adType: NativeAdType.NATIVE_AD,
              listener: (result, value) {
                print("Native Banner Ad: $result --> $value");
              },
            ),
          );
  }

  //this function is used to reformate the location in case it doesn't exist
  //using the product's country, state, and cityId
  String getProductLocation(Product product) {
    //creating a local variable so it would be easy to manibulate
    String location = "";
    if (product.location.isEmpty || product.location == null) {
      //the location doesn't exist
      //I am treing to combinate a new one
      location += product.cityId + ", " + product.state;
    } else {
      //the location exist
      //so I will only use it
      location = product.location;
    }
    //returning back the location
    return location;
  }

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;

    final productsProvider = Provider.of<Products>(context);

    if (featuredProducts.length == 0 && latestProducts.length == 0) {
      categories = productsProvider.categoriesItems;
      featuredProducts = productsProvider.featuredAndUrgentItems;
      latestProducts = productsProvider.items;

      firstBuild = categories.length == 0 ? true : false;
    }

    if (loadingNewPage) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 90,
        shape: AppBarBottomShape(),
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: kToolbarHeight / 2,
            ),
            InkWell(
              onTap: () {
                CurrentUser.fromSearchScreen = false;
                Navigator.of(context).pushNamed(LocationSearchScreen.routeName);
              },
              child: Container(
                padding: EdgeInsets.all(5),
                child: Row(
                  textDirection: CurrentUser.textDirection,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),
                    Text(
                      CurrentUser.location.name ??
                          CurrentUser.location.cityName,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              textDirection: CurrentUser.textDirection,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      CurrentUser.prodLocation = Location();
                      CurrentUser.fromSearchScreen = false;
                      print("Home Click::");
                      // print('Tapped the search bar');
                      Navigator.of(context).pushNamed(SearchAdScreen.routeName);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            width: 1,
                            color: Colors.white,
                          )),
                      child: Row(
                        textDirection: CurrentUser.textDirection,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          Flexible(
                            child: Container(
                              child:
                                  Text(langPack['What are you looking for?']!,
                                      textDirection: CurrentUser.textDirection,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(NotificationsScreen.routeName);
                  },
                ),
              ],
            ),
          ],
        ),
        backgroundColor: HexColor(),
        elevation: 2,
      ),
      body: Container(
        color: Colors.white,
        child: RefreshIndicator(
          onRefresh: () {
            setState(() {
              productsProvider.clearProductsCache();
              categories = <Category>[];
              latestProducts = <Product>[];
              featuredProducts = <Product>[];
              _listLength = 1;
              firstBuild = true;
              page = 1;
              allPagesAreFetched = false;
            });
            return Future.delayed(Duration(milliseconds: 400));
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    left: 15,
                    right: 0,
                  ),
                  child: Row(
                    textDirection: CurrentUser.textDirection,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        langPack['Categories']!,
                        textDirection: CurrentUser.textDirection,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: TextButton(
                          child: Text(
                            langPack['All']!,
                            textDirection: CurrentUser.textDirection,
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                AllCategoriesScreen.routeName,
                                arguments: {
                                  'newAd': false,
                                  'editAd': false,
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                //    ListView.builder(
                //        itemCount: videos.length,
                //        itemBuilder: (BuildContext context, int index) {
                //          return
                //          SizedBox(
                //   width: double.infinity, // Use maximum available width
                //   height: 300.0, // Set your desired height
                //   child: Container(
                //     padding: EdgeInsets.all(8.0),
                //     decoration: BoxDecoration(
                //       color: Colors.black,
                //       borderRadius: BorderRadius.circular(8.0),
                //     ),
                //     child: Column(
                //       children: [
                //         Padding(
                //           padding: const EdgeInsets.only(bottom: 8.0),
                //           child: Text(
                //             videos[index]['title']!,
                //             style: TextStyle(
                //               fontSize: 18,
                //               fontWeight: FontWeight.bold,
                //               color: Colors.white,
                //             ),
                //           ),
                //         ),
                //         VideoPlayerScreen(videoLink: videos[index]['link']!),
                //       ],
                //     ),
                //   ),
                // );
                //        },
                //      ),
                // SizedBox(
                //     width: double.infinity, // Use maximum available width
                //     height: 300.0, // Set your desired height
                //     child: Container(
                //       padding: EdgeInsets.all(8.0),
                //       decoration: BoxDecoration(
                //         // color: Colors.black,
                //         borderRadius: BorderRadius.circular(8.0),
                //       ),
                //       child: Column(
                //         children: [
                //           Padding(
                //             padding: const EdgeInsets.only(bottom: 8.0),
                //             child: Text(
                //               videos[0]['title']!,
                //               style: TextStyle(
                //                 fontSize: 18,
                //                 fontWeight: FontWeight.bold,
                //                 color: Colors.white,
                //               ),
                //             ),
                //           ),
                //           VideoPlayerScreen(videoLink: videos[0]['link']!),
                //         ],
                //       ),
                //     ),
                //   ),

                if (firstBuild)
                  FutureBuilder(
                      future: Provider.of<Products>(context, listen: false)
                          .fetchCategories(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return Center(
                              child: Container(
                                width: 100,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.grey,
                                  // color: Colors.black,
                                ),
                              ),
                            );
                            break;
                          default:
                            // Completed with error
                            if (snapshot.hasError)
                              return Container(
                                  child: Text(snapshot.error.toString()));
                            for (int j = 0; j < snapshot.data!.length; j++) {
                              categories.add(snapshot.data![j]);
                            }
                            return Padding(
                                padding: const EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  left: 20,
                                  right: 30,
                                ),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                    // gridDelegate:
                                    //     SliverGridDelegateWithFixedCrossAxisCount(
                                    //   childAspectRatio: 1,
                                    //   crossAxisCount: 3,
                                    //   mainAxisSpacing: 10,
                                    //   crossAxisSpacing: 10,
                                    // ),
                                    itemCount: 9,
                                    itemBuilder: (ctx, i) =>
                                        snapshot.data![i].name.isEmpty
                                            ? SizedBox()
                                            : CategoryTile(
                                                category: snapshot.data![i],
                                              ),
                                  ),
                                ));
                        }
                      }),

                if (!firstBuild)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 0,
                      left: 20,
                      right: 30,
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.12,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,

                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //   childAspectRatio: 1,
                        //   crossAxisCount: 3,
                        //   mainAxisSpacing: 10,
                        //   crossAxisSpacing: 10,
                        // ),
                        itemCount: 9,
                        itemBuilder: (ctx, i) => CategoryTile(
                          category: categories[i],
                        ),
                      ),
                    ),
                  ),

                FutureBuilder(
                    future: Provider.of<Products>(context)
                        .fetchHomeLatestProducts(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(
                            child: Container(
                              width: 100,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey,
                                // color: Colors.black,
                              ),
                            ),
                          );
                          break;
                        default:
                          // Completed with error
                          if (snapshot.hasError)
                            return Container(
                                child: Text(snapshot.error.toString()));

                          print(
                              "Here is length of data fetched===================${snapshot.data?.length}======================================================================");
                          return ListView.builder(
                            itemCount: snapshot.data?.length ?? 0,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              print(
                                  "Here is length of the list ==============================${snapshot.data!.length}");
                              return Column(
                                children: [
                                  Divider(
                                      // height: 50,
                                      ),
                                  VideoPlayerScreen(
                                    // index: index,
                                    videoTitle: snapshot.data![index].name,
                                    videoUrl: snapshot.data![index].video,
                                    pictureUrl: snapshot.data![index].picture,
                                    mediaType: snapshot.data![index].mediaType,
                                  ),
                                ],
                              );
                            },
                          );
                      }
                    }),

                // Divider(
                //     // height: 50,
                //     ),
                // VideoPlayerScreen(),
                // Divider(
                //     // height: 50,
                //     ),
                // VideoPlayerScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  // final int index;
  final String videoTitle;
  final String videoUrl;
  final String pictureUrl;
  final String mediaType;
  const VideoPlayerScreen({
    Key? key,
    // required this.index,
    required this.videoTitle,
    required this.videoUrl,
    required this.pictureUrl,
    required this.mediaType,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  @override
  void initState() {
    super.initState();
    if (widget.mediaType == 'video') {
      print(
          "HEre is the video url ====================================== ${widget.videoUrl}");
      print(
          "HEre is the image url ====================================== ${widget.pictureUrl}");

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      )..initialize().then((_) {
          setState(() {});
        });

      _chewieController = ChewieController(
        videoPlayerController: _controller,
        aspectRatio: 16 / 9, // Adjust based on your video aspect ratio
        autoPlay: true,
        looping: true,
        showControls: true, // Set to false to hide controls initially
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _provider = Provider.of<VideoProvider>(context);
    return SizedBox(
      // height: 320,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.videoTitle,
              style: TextStyle(fontSize: 15),
            ),
          ),
          widget.mediaType == ''
              ? SizedBox()
              : widget.mediaType == 'video'
                  ? AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Chewie(
                        controller: _chewieController,
                      ),
                    )
                  : Container(
                      // height: 80,
                      // width: 80,
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: Colors.blue,
                        ),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          widget.pictureUrl,
                          fit: BoxFit.cover,
                          cacheHeight: 100,
                          // cacheWidth: 100,
                        ),
                      ),
                    ),
          SizedBox(
            height: widget.mediaType == '' ? 0 : 5,
          ),
          widget.mediaType == ''
              ? SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        onPressed: () {
                          //   _provider.setLike(
                          //       !_provider.isLiked[widget.index], widget.index);
                        },
                        icon: Icon(
                          // _provider.isLiked[widget.index]
                          //     ? Icons.thumb_up
                          //     :
                          Icons.thumb_up_alt_outlined,
                          color: Colors.blue,
                        )),
                    IconButton(
                        onPressed: () {
                          // _provider.showCommentSheet(
                          //     !_provider.commentSheet[widget.index], widget.index);
                        },
                        icon: CircleAvatar(
                            backgroundColor:
                                // _provider.commentSheet[widget.index]
                                //     ? Colors.grey.shade200
                                //     :
                                Colors.transparent,
                            radius: 17,
                            child: Icon(Icons.comment))),
                    IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            constraints: BoxConstraints(maxHeight: 200),
                            builder: (context) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Share',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Users',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios_rounded)
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.ios_share_rounded)),
                    IconButton(
                        onPressed: () {
                          // _provider.changeFavorite(
                          //     !_provider.favorite[widget.index], widget.index);
                        },
                        icon: Icon(
                          // _provider.favorite[widget.index]
                          //     ? Icons.favorite
                          //     :
                          Icons.favorite_border,
                          color: Colors.red,
                        )),
                  ],
                ),
          // AnimatedContainer(
          //   margin: EdgeInsets.symmetric(horizontal: 15),
          //   padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          //   decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(20),
          //       color: Colors.white,
          //       boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey)]),
          //   height: _provider.commentSheet[widget.index] ? 150 : 0,
          //   duration: Duration(milliseconds: 250),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: <Widget>[
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: <Widget>[
          //           Row(
          //             children: <Widget>[
          //               Container(
          //                   height: 35,
          //                   width: 35,
          //                   decoration: BoxDecoration(
          //                       shape: BoxShape.circle,
          //                       border:
          //                           Border.all(width: 2, color: Colors.blue)),
          //                   child: ClipOval(
          //                       child: Image.network(
          //                     'https://images.unsplash.com/photo-1439778615639-28529f7628bc?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          //                     fit: BoxFit.cover,
          //                     cacheHeight: 100,
          //                     // cacheWidth: 100,
          //                   ))),
          //               SizedBox(
          //                 width: 10,
          //               ),
          //               Column(
          //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: <Widget>[
          //                   Text(
          //                     'John Wick',
          //                     style: TextStyle(
          //                         fontSize: 13, fontWeight: FontWeight.w500),
          //                   ),
          //                   Text(
          //                     'Great Video',
          //                     style: TextStyle(
          //                         fontSize: 12, fontWeight: FontWeight.w400),
          //                   )
          //                 ],
          //               ),
          //             ],
          //           ),
          //           Text(
          //             '1h',
          //             style: TextStyle(
          //               color: Colors.black54,
          //               fontSize: 12,
          //             ),
          //           )
          //         ],
          //       ),
          //       SizedBox(
          //         height: 12,
          //       ),
          //       SizedBox(
          //           height: 45,
          //           child: Row(
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             children: [
          //               Container(
          //                   height: 40,
          //                   width: 40,
          //                   decoration: BoxDecoration(
          //                       shape: BoxShape.circle,
          //                       border:
          //                           Border.all(width: 2, color: Colors.blue)),
          //                   child: ClipOval(
          //                       child: Image.network(
          //                     'https://images.unsplash.com/photo-1439778615639-28529f7628bc?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          //                     fit: BoxFit.cover,
          //                     cacheHeight: 100,
          //                     // cacheWidth: 100,
          //                   ))),
          //               SizedBox(
          //                 width: 5,
          //               ),
          //               Flexible(
          //                   child: TextField(
          //                 style: TextStyle(fontSize: 13),
          //                 decoration: InputDecoration(
          //                     hintText: 'Add Comment',
          //                     suffixIcon: IconButton(
          //                         onPressed: () {},
          //                         icon: Icon(
          //                           Icons.send,
          //                           color: Colors.blue,
          //                         )),
          //                     contentPadding:
          //                         EdgeInsets.symmetric(horizontal: 15),
          //                     border: OutlineInputBorder(
          //                         borderRadius: BorderRadius.circular(50),
          //                         borderSide: BorderSide(color: Colors.blue)),
          //                     focusedBorder: OutlineInputBorder(
          //                         borderRadius: BorderRadius.circular(50),
          //                         borderSide: BorderSide(color: Colors.blue)),
          //                     enabledBorder: OutlineInputBorder(
          //                         borderRadius: BorderRadius.circular(
          //                           50,
          //                         ),
          //                         borderSide: BorderSide(color: Colors.blue))),
          //               )),
          //             ],
          //           ))
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
