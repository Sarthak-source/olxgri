import 'dart:io';

import 'package:com.agrobs/screens/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import './custom_fields_screen.dart';
import './location_search_screen.dart';
import './tabs_screen.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../models/location.dart';
import '../models/product_image.dart';
import '../pickers/user_image_picker.dart';
import '../providers/languages.dart';

class NewAdScreen extends StatefulWidget {
  static const routeName = '/new-ad';

  @override
  _NewAdScreenState createState() => _NewAdScreenState();
}

class _NewAdScreenState extends State<NewAdScreen> {
  late File _userImageFile;
  final _formKey = GlobalKey<FormState>();
  bool _hidePhone = false;
  bool _negotiable = false;
  String _title = '';
  String _description = '';
  List<Map<String, String>> _additionalInfo = [];
  late double _price;
  String _phoneNumber = '';
  String _prodId = '';
  List<String> _itemScreen = [];
  String _city = '';
  String _countryCode = '';
  String _latitude = '';
  String _longitute = '';
  String _location = '';
  String _state = '';
  List<ProductImage> productImages = [];
  List<File> imagesList = [];

  void _pickedImage(List<File> images) {
    // _userImageFile = image;
    //
    for (int i = 0; i < images.length; i++) {
      productImages.add(ProductImage(
        file: images[i],
        isLocal: true,
        url: '',
        urlPrefix: '',
      ));
    }
  }

  void _removeImage(int index) {
    try {
      print("current $index");
      productImages.removeAt(index);
      imagesList.removeAt(index);
    } catch (e) {
      print(e);
    }
  }

  void togglePhoneSwitch(bool value) {
    if (_hidePhone == false) {
      setState(() {
        _hidePhone = true;
        //textValue = 'Switch Button is ON';
      });
      print('Switch Button is ON');
    } else {
      setState(() {
        _hidePhone = false;
        //textValue = 'Switch Button is OFF';
      });
      print('Switch Button is OFF');
    }
  }

  void toggleNegotiableSwitch(bool value) {
    if (_negotiable == false) {
      setState(() {
        _negotiable = true;
        //textValue = 'Switch Button is ON';
      });
      print('Switch Button is ON');
    } else {
      setState(() {
        _negotiable = false;
        //textValue = 'Switch Button is OFF';
      });
      print('Switch Button is OFF');
    }
  }

  Future _trySubmit(BuildContext ctx, cat, subCat) async {
    // final isValid = _formKey.currentState!.validate();

    final apiHelper = Provider.of<APIHelper>(ctx, listen: false);

    // The method "save()" calls all the "onSaved" methods
    // from each TextFormField
    _formKey.currentState!.save();
    print("Form is start submit================================");
    try {
      final response = await apiHelper.postUserProduct(
        userId: CurrentUser.id,
        title: _title,
        description: _description,
        price: _price.toString(),
        categoryId: cat.id,
        subCategoryId: subCat.id,
        additionalInfo: _additionalInfo,
        city: CurrentUser.prodLocation.cityId,
        countryCode: CurrentUser.prodLocation.countryCode,
        hidePhone: _hidePhone ? '1' : '0',
        latitude: CurrentUser.prodLocation.latitude,
        longitude: CurrentUser.prodLocation.longitude,
        location: CurrentUser.prodLocation.name,
        negotiable: _negotiable ? '1' : '0',
        phone: _phoneNumber,
        state: CurrentUser.prodLocation.stateId,
        productImages: productImages,
      );

      // Navigator.of(context).pop();
      print(
          "Here is response comes from the apu============================================${response}");

      return response;
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
      print(
          "Here is error comes============================================$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    final Map pushedMap = ModalRoute.of(context)!.settings.arguments as dynamic;
    return LoaderOverlay(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          foregroundColor: Colors.grey[800],
          backgroundColor: HexColor(),
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            langPack['Place an Ad']!,
            textDirection: CurrentUser.textDirection,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        bottomNavigationBar: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            textDirection: CurrentUser.textDirection,
            children: [
              TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<ContinuousRectangleBorder>(
                      ContinuousRectangleBorder()),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[200]!),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[800]!),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: MaterialStateProperty.all<Size>(Size(
                      MediaQuery.of(context).size.width / 2,
                      Platform.isIOS ? 60 : 40)),
                ),
                child: Text(
                  langPack['Cancel']!,
                  textDirection: CurrentUser.textDirection,
                ),
                onPressed: () async {
                  Navigator.pushNamedAndRemoveUntil(context,
                      TabsScreen.routeName, (Route<dynamic> route) => false);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<ContinuousRectangleBorder>(
                      ContinuousRectangleBorder()),
                  backgroundColor: MaterialStateProperty.all<Color>(HexColor()),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: MaterialStateProperty.all<Size>(Size(
                      MediaQuery.of(context).size.width / 2,
                      Platform.isIOS ? 60 : 40)),
                ),
                child: Text(
                  langPack['Post']!,
                  textDirection: CurrentUser.textDirection,
                ),
                onPressed: () async {
                  try {
                    if (_additionalInfo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill the additional info'),
                        ),
                      );
                    } else if (CurrentUser.prodLocation.cityId == '' ||
                        CurrentUser.prodLocation.stateId == '') {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please select state and city'),
                      ));
                    } else {
                      context.loaderOverlay.show();

                      final message = await _trySubmit(
                        context,
                        pushedMap['chosenCat'],
                        pushedMap['chosenSubCat'],
                      );

                      print(
                          "here is the message received from the response==========================================================$message");

                      context.loaderOverlay.hide();
                      if (message != null && message['status'] == 'success') {
                        print(
                            "here is the message received from the response==========================================================$message");
                        // Navigator.pushNamedAndRemoveUntil(
                        //     context,
                        //     TabsScreen.routeName,
                        //     (Route<dynamic> route) => false);

                        CurrentUser.prodLocation = Location();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Success')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message.toString())));
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                    ;
                  }
                },
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 15,
                left: 15,
                right: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.grey[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          langPack['This will be listed in']!,
                          textDirection: CurrentUser.textDirection,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Text(
                          '${pushedMap['chosenCat'].name} > ${pushedMap['chosenSubCat'].name}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      textDirection: CurrentUser.textDirection,
                      children: [
                        TextFormField(
                          key: ValueKey('title'),
                          cursorColor: Colors.grey[800],
                          textDirection: CurrentUser.textDirection,
                          decoration: InputDecoration(
                              hintTextDirection: CurrentUser.textDirection,
                              labelText: langPack[
                                  'First, enter a short title to describe your listing']),
                          maxLength: 50,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 10) {
                              return 'Title must be at least 10 characters long';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            _title = value!;
                          },
                        ),
                        SizedBox(
                          height: 9,
                        ),
                        TextFormField(
                          key: ValueKey('description'),
                          textDirection: CurrentUser.textDirection,
                          cursorColor: Colors.grey[800],
                          decoration: InputDecoration(
                            labelText: langPack['Description'],
                            hintTextDirection: CurrentUser.textDirection,
                          ),
                          maxLines: null,
                          maxLength: 1000,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 10) {
                              return 'Description must be at least 10 characters long';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            _description = value!;
                          },
                        ),
                        SizedBox(
                          height: 9,
                        ),
                        UserImagePicker(
                          imagePickFn: _pickedImage,
                          imagesList: productImages,
                          deleteImageFn: _removeImage,
                          netImage: null,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextButton.icon(
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey[800]!),
                          ),
                          icon: Icon(Icons.location_on),
                          label: Consumer<CurrentUser>(
                              child: Text(
                                langPack['Location']!,
                                textDirection: CurrentUser.textDirection,
                              ),
                              builder: (ctx, data, child) {
                                if (data.prodLocationGetter.name == '') {
                                  return SizedBox(child: child);
                                }
                                return Text(data.prodLocationGetter.name);
                              }),
                          onPressed: () async {
                            CurrentUser.uploadingAd = true;
                            CurrentUser.fromSearchScreen = false;
                            await Navigator.of(context)
                                .pushNamed(LocationSearchScreen.routeName);
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          key: ValueKey('price'),
                          cursorColor: Colors.grey[800],
                          textDirection: CurrentUser.textDirection,
                          decoration: InputDecoration(
                            labelText: langPack['Price'],
                            hintTextDirection: CurrentUser.textDirection,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a price';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            _price = double.parse(value!);
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        if (!_hidePhone)
                          TextFormField(
                            key: ValueKey('phoneNumber'),
                            cursorColor: Colors.grey[800],
                            textDirection: CurrentUser.textDirection,
                            decoration: InputDecoration(
                              labelText: langPack['Phone number'],
                              hintTextDirection: CurrentUser.textDirection,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              // if (value.isEmpty || value.length < 10) {
                              //   return 'Title must be at least 10 characters long';
                              // } else {
                              //   return null;
                              // }
                              return null;
                            },
                            onSaved: (value) {
                              _phoneNumber = value!;
                            },
                          ),
                        Row(
                          textDirection: CurrentUser.textDirection,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              langPack['Hide phone number']!,
                              textDirection: CurrentUser.textDirection,
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            Switch(
                              value: _hidePhone,
                              onChanged: togglePhoneSwitch,
                              activeColor: Colors.grey[800],
                            ),
                          ],
                        ),
                        Row(
                          textDirection: CurrentUser.textDirection,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              langPack['Negotiable']!,
                              textDirection: CurrentUser.textDirection,
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            Switch(
                              value: _negotiable,
                              onChanged: toggleNegotiableSwitch,
                              activeColor: Colors.grey[800],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FutureBuilder(
                          future: Provider.of<APIHelper>(context, listen: false)
                              .getCustomDataByCategory(
                            categoryId: pushedMap['chosenCat'].id,
                            subCategoryId: pushedMap['chosenSubCat'].id,
                          ),
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                firstLoad) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.data != null &&
                                snapshot.data.length > 0) {
                              // print('pushedMap[' ']' * 100);
                              // print(pushedMap['customData'].runtimeType);
                              // print(pushedMap['customData']);
                              // print(pushedMap['customData'][0]['title']);

                              print(
                                  "Here is the all the data_-----------------------------------------${snapshot.data}");
                              if (firstLoad) {
                                for (var i = 0; i < snapshot.data.length; i++) {
                                  dynamic matchingField =
                                      _additionalInfo.firstWhere(
                                    (element) {
                                      return element['title']?.toLowerCase() ==
                                          snapshot.data[i]['title']
                                              .toLowerCase();
                                    },
                                    orElse: () => <String,
                                        String>{}, // Provide an empty map as the default value
                                  ); // or return a default Map<String, String>
                                  _additionalInfo.add({
                                    'id': snapshot.data[i]['id'] ?? '',
                                    'type': snapshot.data[i]['type'] ?? '',
                                    'title': snapshot.data[i]['title'] ?? '',
                                    'value': matchingField['value'] != null &&
                                            matchingField != null
                                        ? matchingField['value']
                                        : '',
                                  });
                                }
                                firstLoad = false;
                              }
                              return SingleChildScrollView(
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: ScrollPhysics(),
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (ctx, ind) {
                                          switch (snapshot.data[ind]['type']) {
                                            case 'text-field':
                                              return buildTextField(
                                                  snapshot, ind);
                                              break;
                                            case 'textarea':
                                              return Text('textarea');
                                              break;
                                            case 'radio-buttons':
                                              return buildRadioButtons(
                                                  snapshot, ind);
                                              break;
                                            case 'checkboxes':
                                              return buildCheckBox(
                                                  snapshot, ind);
                                              break;
                                            case 'drop-down':
                                              return buildDropDwonList(
                                                  snapshot, ind);
                                              break;
                                            default:
                                              return Text('Default case');
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Center(
                                child: Text('Has no additional data'));
                          },
                        ),

                        // todo

                        SizedBox(
                          height: 20,
                        ),
                        // TextButton(
                        //   style: ButtonStyle(
                        //     backgroundColor:
                        //         MaterialStateProperty.all(HexColor()),
                        //     foregroundColor:
                        //         MaterialStateProperty.all(Colors.white),
                        //   ),
                        //   onPressed: () async {
                        //     final result = await Navigator.of(context)
                        //         .pushNamed(CustomFieldsScreen.routeName,
                        //             arguments: {
                        //           'chosenCatId': pushedMap['chosenCat'].id,
                        //           'chosenSubCatId':
                        //               pushedMap['chosenSubCat'].id,
                        //           'customData': _additionalInfo,
                        //         });
                        //     _additionalInfo = result as dynamic;
                        //   },
                        //   child: Text('+ ${langPack['Additional Info']}'),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // List<Map<String, String>> customData = [];
  bool firstLoad = true;

  Widget buildDropDwonList(AsyncSnapshot<dynamic> snapshot, int ind) {
    RegExp exp = RegExp('\<option value=\"[0-9]+\"\>');
    RegExp exp2 = RegExp('\<\/option\>');
    String dropDownString = snapshot.data[ind]['selectbox'].replaceAll(exp, '');
    print("here is data of drop down at 1st stage$dropDownString");
    dropDownString = dropDownString.replaceAll(exp2, ',');
    print("here is data of drop down at 2st stage$dropDownString");

    dropDownString = dropDownString.substring(0, dropDownString.length - 1);

    print("here is data of drop down at 3st stage$dropDownString");

    //saving each item value to send it back to the server
    List<String> value = snapshot.data[ind]['selectbox']
        .toString()
        .replaceAll(RegExp("[^0-9|]"), " ")
        .split(" ")
      ..removeWhere((element) => element == "");

    final dropDownList = dropDownString.split(',');

    final thisIndex = _additionalInfo
        .indexWhere((element) => element['id'] == snapshot.data[ind]['id']);

    String title = "";

    if (value.indexOf(_additionalInfo[thisIndex]['value']!) != -1) {
      title = dropDownList[value.indexOf(_additionalInfo[thisIndex]['value']!)];
    } else {
      title = "";
    }

    print(
        "Here is snapshot for the drop down button+++++++++++++++++++++++++++${_additionalInfo[thisIndex]['value']}");

    print(
        "Here is list =================================================++++++++$dropDownList");

    return Column(
      children: [
        StatefulBuilder(
          builder: (ctx, setSta) {
            return SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Row(
                children: [
                  Text(
                    snapshot.data[ind]['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      onChanged: (value) {
                        setState(() {
                          _additionalInfo[thisIndex]['value'] = value!;
                        });
                      },
                      hint: Text(
                        title,
                        softWrap: true,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      items: dropDownList.map<DropdownMenuItem<String>>(
                        (String dropDwonListItem) {
                          return DropdownMenuItem<String>(
                            child: Text(dropDwonListItem),
                            //the value for the server
                            value: value[
                                //getting the value index by the item
                                dropDownList.indexWhere(
                                    (element) => element == dropDwonListItem)],
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Divider(),
      ],
    );
  }

  Widget buildRadioButtons(AsyncSnapshot<dynamic> snapshot, int ind) {
    RegExp exp = RegExp(
        '\<div class\=\"(.*?)\"\>\<input class\=\"(.*?)\" type\=\"[a-z]+\" name\=\"(.*?)\" id\=\"[0-9]+\" value\=\"[0-9]+\"  \/\>\<label for\=\"[0-9]+\"\>');
    RegExp exp2 = RegExp('\<\/label\>\<\/div\>');

    //saving each item value to send it back to the server
    List<String> value = getValues(snapshot.data[ind]['radio'].toString());

    String radioString = snapshot.data[ind]['radio'].replaceAll(exp, '');
    radioString = radioString.replaceAll(exp2, ',');
    radioString = radioString.substring(0, radioString.length - 1);

    final radioList = radioString.split(',');
    final matchingRadio = _additionalInfo.firstWhere(
      (element) => element['id'] == snapshot.data[ind]['id'],
      orElse: () => null!,
    );
    final thisIndex = _additionalInfo
        .indexWhere((element) => element['id'] == snapshot.data[ind]['id']);

    print("CustomFieldScreen build radio value: $value");
    print(
        "CustomFieldScreen build radio customData: ${_additionalInfo[thisIndex]['value']}");
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          snapshot.data[ind]['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        StatefulBuilder(
          builder: (ctx, setSt) {
            return GridView.builder(
              itemCount: radioList.length,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                childAspectRatio: 22 / 9,
              ),
              itemBuilder: (ctx, i) {
                return TextButton.icon(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all(Colors.grey[800]),
                  ), //
                  onPressed: () {
                    setState(() {
                      //setting the value for the server
                      _additionalInfo[thisIndex]['value'] = value[i];
                    });
                  },
                  icon: Icon(
                    matchingRadio != null &&
                                matchingRadio['value'] == value[i] ||
                            matchingRadio['value'] == radioList[i]
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  label: Text(radioList[i]),
                );
              },
            );
          },
        ),
        Divider(),
      ],
    );
  }

  Widget buildTextField(AsyncSnapshot<dynamic> snapshot, int ind) {
    final matchingTextField = _additionalInfo.firstWhere(
      (element) => element['title'] == snapshot.data[ind]['title'],
      orElse: () => null!,
    );
    return Column(
      children: [
        Row(
          children: [
            Text(
              snapshot.data[ind]['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: StatefulBuilder(
                builder: (ctx, setS) {
                  return TextFormField(
                    key: ValueKey(matchingTextField['value']),
                    initialValue: matchingTextField != null
                        ? matchingTextField['value']
                        : null,
                    decoration: InputDecoration(
                      labelText: snapshot.data[ind]['title'],
                    ),
                    onChanged: (value) {
                      final thisIndex = _additionalInfo.indexWhere((element) =>
                          element['id'] == snapshot.data[ind]['id']);

                      _additionalInfo[thisIndex]['value'] = value;
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget buildCheckBox(AsyncSnapshot<dynamic> snapshot, int ind) {
    RegExp exp = RegExp(
        '\<div class\=\"(.*?)\"\>\<input class\=\"(.*?)\" type\=\"[a-z]+\" name\=\"(.*?)\" id\=\"[0-9]+\" value\=\"[0-9]+\"  \/\>\<label for\=\"[0-9]+\"\>');
    RegExp exp2 = RegExp('\<\/label\>\<\/div\>');

    //saving each item value to send it back to the server
    String value = getValues(snapshot.data[ind]['checkbox'].toString()).first;
    String checkboxString = snapshot.data[ind]['checkbox'].replaceAll(exp, '');
    checkboxString = checkboxString.replaceAll(exp2, ',');
    checkboxString = checkboxString.substring(0, checkboxString.length - 1);
    //checking if the snapshot data is valid or no
    if (!snapshot.data[ind]['checkbox'].toString().contains(exp)) {
      checkboxString = "";
    }
    final thisIndex = _additionalInfo
        .indexWhere((element) => element['id'] == snapshot.data[ind]['id']);
    if (checkboxString.isNotEmpty)
      return Expanded(
        child: CheckboxListTile(
          value: _additionalInfo[thisIndex]['value'] != "" &&
              _additionalInfo[thisIndex]['value'] == value,
          onChanged: (checked) {
            setState(() {
              _additionalInfo[thisIndex]['value'] == checked ? value : "";
            });
          },
          title: Text(checkboxString),
          tristate: _additionalInfo[thisIndex]['value'] == "" &&
              _additionalInfo[thisIndex]['value'] == value,
        ),
      );
    return Container();
  }

  List<String> getValues(String snapShotData) {
    final result = snapShotData.split(" ")
      ..removeWhere((element) => !element.startsWith("value"));

    for (int i = 0; i < result.length; i++) {
      result[i] = result[i].replaceAll(RegExp("[^0-9]"), '');
    }
    return result;
  }
}
