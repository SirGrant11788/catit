import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cat_it/services/db.dart';
import 'package:cat_it/ui/uiAppHome.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final db = DatabaseHelper.instance;
  List<String> attributes = [];
  List<String> attributesNew = [];

  List<TextEditingController> attributeControllers = [];
  TextEditingController newCategoryNameTextController = TextEditingController();
  TextEditingController newAttributeTextController = TextEditingController();
  TextEditingController itemNameTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();

  List<DropdownMenuItem<String>> categories = [];
  String selectedCategory;

  File itemImage;
  final imagePicker = ImagePicker();

  void dispose() {
    newCategoryNameTextController.dispose();
    newAttributeTextController.dispose();
    itemNameTextController.dispose();
    descriptionTextController.dispose();
    attributeControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void initState() {
    getAttributesAndCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text('Add Item'),
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
                        controller: itemNameTextController,
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
                              showCategoryNameDialog(context).then((result) {
                                setState(() {
                                  categories.add(DropdownMenuItem<String>(value: result, child: Text(result)));
                                  selectedCategory = result;
                                });
                              });
                            } else {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            }
                          }),
                          items: categories,
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
                              attributesNew.add(result);
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
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          child: Text('SAVE'),
                          color: Colors.blue,
                          highlightColor: Colors.grey,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          onPressed: () {
                            if (validateForm()) {
                              addItem();
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Please complete Photo, Name and Category fields',
                                toastLength: Toast.LENGTH_LONG,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ]),
              ),
              );
  }

  void getAttributesAndCategories() async {
    final allAttributes = await db.queryColumns();
    final allCategories = await db.queryAllRows();

    setState(() {
      allAttributes.forEach((attribute) {
        attributes.add(attribute['name'].toString());
        attributeControllers.add(TextEditingController());
      });
      categories = allCategories.map((category) => DropdownMenuItem<String>(value: category['cat'], child: Text(category['cat']))).toList();
      categories.add(DropdownMenuItem<String>(value: 'Add New Category', child: Text('Add New Category')));
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

  void addItem() async {
    final itemName = itemNameTextController.text;

    await db.insert({
      DatabaseHelper.columnName: itemName,
      DatabaseHelper.columnCat: selectedCategory,
      DatabaseHelper.columnDesc: descriptionTextController.text,
      DatabaseHelper.columnPic: itemImage.uri,
    });

    if (attributesNew.length != 0 || attributesNew.length != null) {
      for (int i = 0; i < attributesNew.length; i++) {
        await db.insertColumn(attributesNew[i].toString());
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
          await db.insertQuery(
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
    return (itemNameTextController.text != null && selectedCategory != null && itemImage != null);
  }

  showCategoryNameDialog(BuildContext context) {
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
}