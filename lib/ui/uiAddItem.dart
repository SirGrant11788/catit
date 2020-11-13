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
  List<String> columnList = List();
  List<String> columnListNew = List();
  List<TextEditingController> _controllers = new List();
  TextEditingController _textFieldControllerDialog = TextEditingController();
  TextEditingController _textFieldControllerDialogCol = TextEditingController();
  TextEditingController _textFieldControllerName = TextEditingController();
  TextEditingController _textFieldControllerDesc = TextEditingController();
  File _cameraImage;
  String _btnSelectedValCat;
  String temp;

  void initState() {
    super.initState();
    _textFieldControllerName.text = null;
    _textFieldControllerDesc.text = null;
    _btnSelectedValCat = null;
    _textFieldControllerDialogCol = null;
    _textFieldControllerDialog = null;
  }

  void dispose() {
    _textFieldControllerDialog.dispose();
    _textFieldControllerDialogCol.dispose();
    _textFieldControllerName.dispose();
    _textFieldControllerDesc.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<String>> catList = List();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _query(),
        builder: (context, snapshot) {
          return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text('Add Item'),
              ),
              body: SingleChildScrollView(
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new RawMaterialButton(
                      onPressed: () {
                        _pickImageFromCamera();
                      }, //add pic
                      child: _cameraImage == null
                          ? new Icon(
                        Icons.camera_enhance,
                        color: Colors.blue,
                        size: 35.0,
                      )
                          : new Icon(
                        Icons.camera_alt,
                        color: Colors.red,
                        size: 35.0,
                      ),
                      shape: new CircleBorder(),
                      elevation: 2.0,
                      fillColor: Colors.white,
                      padding: const EdgeInsets.all(15.0),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _textFieldControllerName,
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
                      controller: _textFieldControllerDesc,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Description',
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                  ),
                  Divider(
                    thickness: 2.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ListTile(
                      title: Text('Select Category:'),
                      trailing: DropdownButton(
                        value: _btnSelectedValCat,
                        hint: Text(
                          'Category',
                          textAlign: TextAlign.center,
                        ),
                        onChanged: ((String newValue) {
                          if (newValue == 'Add New Category') {
                            _showDialog(context, 'Category', 'e.g. Pants')
                                .then((val) {
                              catList.add(DropdownMenuItem<String>(
                                  value: '$val', child: Text('$val')));
                            });
                          } else {
                            setState(() {
                              _btnSelectedValCat = newValue;
                            });
                          }
                        }),
                        items: catList,
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2.0,
                  ),
                  //adding col
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
                        _showDialogCol(context).then((val) {
                          columnList.add('$val');
                          columnListNew.add('$val');
                        });
                      },
                      child: Text(
                        "ADD ANOTHER ATTRIBUTE",
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
                      itemCount: columnList.length,
                      itemBuilder: (BuildContext context, int index) {
                        _controllers.add(new TextEditingController());
                        return columnList[index] != '_id' &&
                            columnList[index] != 'pic' &&
                            columnList[index] != 'desc' &&
                            columnList[index] != 'cat' &&
                            columnList[index] != 'name'
                            ? TextFormField(
                          controller: _controllers[index],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '${columnList[index]}',
                            labelText: '${columnList[index]}',
                          ),
                          maxLines: 1,
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
                          if (_textFieldControllerName.text != null &&
                              _btnSelectedValCat != null &&
                              _cameraImage != null) {
                            _insert(
                                _textFieldControllerName.text,
                                _btnSelectedValCat,
                                _textFieldControllerDesc.text,
                                _cameraImage.uri,
                                columnListNew,
                                columnList,
                                _controllers);
                          } else {
                            Fluttertoast.showToast(
                              msg:
                              'Please complete Photo, Name and Category fields',
                              toastLength: Toast.LENGTH_LONG,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ]),
              ));
        });
  }

  _query() async {
    columnList.clear();
    final allColumns = await db.queryColumns();
    allColumns.forEach((column) {
      columnList.add('${column['name']}');
    });

    List<String> tempCatList = List();
    if (catList.length == 0) {
      final allRows = await db.queryAllRows();
      allRows.forEach((row) {
        for (int i = 0; i < catList.length; i++) {
          tempCatList.add('${catList[i].value}');
        }
        if (!tempCatList.toString().contains('${row['cat']}')) {
          catList.add(DropdownMenuItem<String>(
              value: '${row['cat']}', child: Text('${row['cat']}')));
        }
      });
      catList.add(DropdownMenuItem<String>(
          value: 'Add New Category', child: Text('Add New Category')));
    }
  }

  Future _pickImageFromCamera() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _cameraImage = image;
    });
  }

  void _insert(
      _textFieldControllerName,
      _btnSelectedValCat,
      _textFieldControllerDesc,
      _cameraImage,
      columnListNew,
      columnList,
      _controllers) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: '$_textFieldControllerName',
      DatabaseHelper.columnCat: '$_btnSelectedValCat',
      DatabaseHelper.columnDesc: '$_textFieldControllerDesc',
      DatabaseHelper.columnPic: '$_cameraImage',
    };
    final id = await db.insert(row);

    print('inserted row id: $id name: $_textFieldControllerName cat: $_btnSelectedValCat desc: $_textFieldControllerDesc pic: $_cameraImage');

    if (columnListNew.length != 0 || columnListNew.length != null) {
      for (int i = 0; i < columnListNew.length; i++) {
        await db.insertColumn(columnListNew[i].toString());
      }
    }

    if (columnList.length != 0 || columnList.length != null) {
      for (int i = 0; i < columnList.length; i++) {
        if (columnList[i] != '_id' &&
            columnList[i] != 'name' &&
            columnList[i] != 'desc' &&
            columnList[i] != 'cat' &&
            columnList[i] != 'pic' &&
            _controllers[i].text != '' &&
            _controllers[i].text != null) {
          await db.insertQuery(
              columnList[i].toString(),
              _controllers[i].text.toString(),
              '$_textFieldControllerName'); //note change from name to id

        }
      }
    }

    Fluttertoast.showToast(
      msg: 'Item $_textFieldControllerName Added',
      toastLength: Toast.LENGTH_SHORT,
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
  }

  _showDialog(BuildContext context, String title, String hint) {
    _textFieldControllerDialog.text = '';
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('$title'),
            content: TextField(
              controller: _textFieldControllerDialog,
              decoration: InputDecoration(hintText: "$hint"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('SAVE'),
                onPressed: () {
                  Navigator.pop(context, _textFieldControllerDialog.text);
                },
              ),
            ],
          );
        });
  }

  _showDialogCol(BuildContext context) {
    _textFieldControllerDialogCol.text = '';
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ATTRIBUTE'),
            content: TextField(
              controller: _textFieldControllerDialogCol,
              decoration: InputDecoration(hintText: "Attribute"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('SAVE'),
                onPressed: () {
                  Navigator.pop(context, _textFieldControllerDialogCol.text);
                },
              ),
            ],
          );
        });
  }
}