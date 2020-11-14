import 'dart:io';
import 'package:cat_it/ui/itemScanPage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cat_it/services/db.dart';
import 'package:cat_it/ui/homePage.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  DatabaseHelper database = DatabaseHelper();

  List<String> allAttributes = [];
  List<String> attributes = [];

  List<TextEditingController> attributeControllers = [];
  TextEditingController newCategoryNameTextController = TextEditingController();
  TextEditingController newAttributeTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();

  List<DropdownMenuItem<String>> categoryOptions = [];
  String selectedCategory;

  File itemImage;
  final imagePicker = ImagePicker();

  void dispose() {
    newCategoryNameTextController.dispose();
    newAttributeTextController.dispose();
    nameTextController.dispose();
    descriptionTextController.dispose();
    attributeControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void initState() {
    getAttributesAndCategoryOptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text('Add Item'),
                actions: [
                  IconButton(icon: Icon(Icons.get_app), onPressed: navigateToItemScanPage, )
                ],
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddItemPage()
              ),
            );
          }),
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 2.0,
            child: FlatButton(),
          ),
              body: SingleChildScrollView(
                child: Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RawMaterialButton(
                        onPressed: getImage,
                        child: itemImage == null
                            ? Icon(
                          Icons.camera_enhance,
                          color: Colors.blue,
                          size: 35.0,
                        )
                            : Icon(
                          Icons.camera_alt,
                          color: Colors.red,
                          size: 35.0,
                        ),
                        shape: CircleBorder(),
                        elevation: 2.0,
                        fillColor: Colors.white,
                        padding: const EdgeInsets.all(15.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: nameTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Item Name',
                          labelText: 'Item Name',
                        ),
                        maxLines: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: descriptionTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Description',
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ListTile(
                        title: Text('Select Category:'),
                        trailing: DropdownButton(
                          value: selectedCategory,
                          hint: Text(
                            'Category',
                            textAlign: TextAlign.center,
                          ),
                          onChanged: ((String newValue) {
                            if (newValue == 'Add New Category') {
                              showCategoryNameDialog(context, null).then((result) {
                                setState(() {
                                  categoryOptions.add(DropdownMenuItem<String>(value: result, child: Text(result)));
                                  selectedCategory = result;
                                });
                              });
                            } else {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            }
                          }),
                          items: categoryOptions,
                        ),
                      ),
                    ),
                    Row(children: <Widget>[
                      Expanded(
                        child: new Container(
                            margin: const EdgeInsets.only(left: 10.0, right: 5.0),
                            child: Divider(
                              color: Colors.black,
                              height: 36,
                            )),
                      ),
                      FlatButton(
                        onPressed: () {
                          showAttributeDialog(context).then((result) {
                            setState(() {
                              attributeControllers.add(new TextEditingController());
                              attributes.add(result);
                            });
                          });
                        },
                        child: Text(
                          'ADD ANOTHER ATTRIBUTE',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: new Container(
                            margin: const EdgeInsets.only(left: 5.0, right: 10.0),
                            child: Divider(
                              color: Colors.black,
                              height: 36,
                            )),
                      ),
                    ]),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3.7,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: attributes.length,
                        itemBuilder: (BuildContext context, int index) {
                          return attributes[index] != '_id' &&
                              attributes[index] != 'pic' &&
                              attributes[index] != 'desc' &&
                              attributes[index] != 'cat' &&
                              attributes[index] != 'name'
                              ? Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    TextFormField(
                                        controller: attributeControllers[index],
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: '${attributes[index]}',
                                          labelText: '${attributes[index]}',
                                        )
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () { removeAttribute(index); }
                                    )
                                  ],
                                ),
                              )
                              : Container();
                        },
                      ),
                    )
                  ]),
              ),
              );
  }

  void getAttributesAndCategoryOptions() async {
    final attributesResult = await database.queryColumns();
    final allCategories = await database.queryAllRows();

    setState(() {
      attributesResult.forEach((attribute) {
        allAttributes.add(attribute['name'].toString());
        attributeControllers.add(TextEditingController());
      });
      allCategories.forEach((category) {
        if (categoryOptions.indexWhere((element) => element.value == category['cat']) == -1) {
          categoryOptions.add(DropdownMenuItem<String>(value: category['cat'], child: Text(category['cat'])));
        }
      });
      categoryOptions.add(DropdownMenuItem<String>(value: 'Add New Category', child: Text('Add New Category')));
    });
  }

  void removeAttribute(int index) {
    setState(() {
      this.attributes.removeAt(index);
      this.attributeControllers.removeAt(index);
    });
  }

  Future getImage() async {
    final pickedFile = await imagePicker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        itemImage = File(pickedFile.path);
      }
    });
  }

  void saveItem() async {
    final itemName = nameTextController.text;

    await database.insert({
      DatabaseHelper.columnName: itemName,
      DatabaseHelper.columnCat: selectedCategory,
      DatabaseHelper.columnDesc: descriptionTextController.text,
      DatabaseHelper.columnPic: itemImage.uri.toString(),
    });

    List<String> attributesNew = attributes.where((attribute) => !allAttributes.contains(attribute)).toList();
    if (attributesNew.length != 0 || attributesNew.length != null) {
      for (int i = 0; i < attributesNew.length; i++) {
        await database.insertColumn(attributesNew[i].toString());
      }
    }

    if (attributes.length != 0 || attributes.length != null) {
      for (int i = 0; i < attributes.length; i++) {
        if (attributes[i] != '_id' &&
            attributes[i] != 'name' &&
            attributes[i] != 'desc' &&
            attributes[i] != 'cat' &&
            attributes[i] != 'pic' &&
            attributeControllers[i].text != '' &&
            attributeControllers[i].text != null) {
          await database.insertQuery(
              attributes[i].toString(),
              attributeControllers[i].text.toString(),
              itemName
          );
        }
      }
    }

    Fluttertoast.showToast(
      msg: 'Item $itemName Added',
      toastLength: Toast.LENGTH_SHORT,
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
  }

  bool validateForm() {
    return (nameTextController.text != null && selectedCategory != null && itemImage != null);
  }

  showCategoryNameDialog(BuildContext context, String value) {
    if (value is String && value.length > 0) newCategoryNameTextController.text = value;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('CATEGORY'),
            content: TextField(
              controller: newCategoryNameTextController,
              decoration: InputDecoration(hintText: 'e.g. Pants'),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('SAVE'),
                onPressed: () {
                  Navigator.pop(context, newCategoryNameTextController.text);
                  newCategoryNameTextController.clear();
                },
              ),
            ],
          );
        });
  }

  showAttributeDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ATTRIBUTE'),
            content: TextField(
              controller: newAttributeTextController,
              decoration: InputDecoration(hintText: 'Attribute'),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('SAVE'),
                onPressed: () {
                  Navigator.pop(context, newAttributeTextController.text);
                  newAttributeTextController.clear();
                },
              ),
            ],
          );
        });
  }

  void navigateToItemScanPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ItemScanPage())).then((item) {
      setState(() {
        nameTextController.text = item.name;
        descriptionTextController.text = item.description;

        attributes = [];
        attributeControllers = [];
        item.attributes.forEach((attribute) {
          attributes.add(attribute.name);
          attributeControllers.add(TextEditingController());
          attributeControllers[attributeControllers.length-1].text = attribute.value;
        });

        if (categoryOptions.indexWhere((element) => element.value == item.category) != -1) {
          selectedCategory = item.category;
        } else {
          showCategoryNameDialog(context, item.category).then((result) {
            setState(() {
              categoryOptions.add(DropdownMenuItem<String>(value: result, child: Text(result)));
              selectedCategory = result;
            });
          });
        }
      });
    });
  }
}