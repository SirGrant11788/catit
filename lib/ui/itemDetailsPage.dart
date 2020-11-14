import 'dart:io';
import 'package:cat_it/models/Item.dart';
import 'package:cat_it/models/ItemAttribute.dart';
import 'package:cat_it/ui/itemSharePage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cat_it/services/db.dart';
import 'package:cat_it/ui/homePage.dart';

class EditProductPage extends StatefulWidget {
  final dynamic editDb;
  final List<String> colDb;

  EditProductPage(this.editDb, this.colDb);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final db = DatabaseHelper();
  String temp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        leading: FlatButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
            icon: Icon(
              Icons.arrow_back,
              size: 20.0,
            ),
            label: Text('')),
        title: Text(widget.editDb['name']),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              deleteItem(widget.editDb['_id'], widget.editDb['name']);
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: navigateToItemSharePage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          InkWell(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color: Colors.blue)),
              child: widget.editDb['pic'].toString() != "" ||
                      widget.editDb['pic'].toString() != null
                  ? Image.file(new File(
                      widget.editDb['pic'].toString().substring(6).replaceAll("'", "")))
                  : CircleAvatar(child: Icon(Icons.accessibility)),
            ),
            onTap: () {
              _pickImageFromCamera(widget.editDb['_id'], 'pic'); //id,col
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.8,
            child: ListView.builder(
              itemCount: widget.colDb.length,
              itemBuilder: (BuildContext context, int index) {
                return widget.colDb[index] != '_id' &&
                        widget.colDb[index] != 'pic' &&
                    widget.editDb[widget.colDb[index]] != '' &&
                    widget.editDb[widget.colDb[index]] != null
                    ? Container(
                        padding: const EdgeInsets.all(8.0),
                        width: MediaQuery.of(context).size.width,
                        child: TextFormField(
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 1.0),
                              ),
                              border: OutlineInputBorder(),
                              hintText: '${widget.editDb[widget.colDb[index]]}',
                              labelText:
                                  '${widget.editDb[widget.colDb[index]]}',
                              suffixIcon: IconButton(
                                  icon: Icon(Icons.save),
                                  onPressed: () {
                                    updateItem(widget.editDb['_id'],
                                        widget.colDb[index], '$temp');
                                    Fluttertoast.showToast(
                                      msg:
                                          '${widget.editDb[widget.colDb[index]]} changed to $temp',
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                    temp = null;
                                  })),
                          onChanged: (value) {
                            temp = null; //stop form fields crossing
                            temp = value;
                          },
                        ))
                    : Container();
              },
            ),
          ),
        ]),
      ),
    );
  }

  deleteItem(id, name) async {
    Fluttertoast.showToast(
      msg: '${widget.editDb['name']} Deleted',
      toastLength: Toast.LENGTH_LONG,
    );

    await db.delete(int.parse(id));
    await db.deleteFavName('$name');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  updateItem(id, col, name) async {
    await db.updateItemQuery(id, col, name);
    if (col == 'name') {
      await db.updateQueryFavName(id, name);
    }
  }

  Future _pickImageFromCamera(id, col) async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    await db.updateItemQuery(id, col, '${image.uri}');
  }

  Item getItem() {
    // TODO: Pass through attribute values when the correct data from the db is retrieved
    List<ItemAttribute> attributes = [];
    if (widget.editDb.length > 4) {
      for (int i = 4; i < widget.colDb.length; i++) {
        attributes.add(ItemAttribute(name: widget.colDb[i], value: widget.colDb[i]));
      }
    }

    return Item(
      id: widget.editDb['_id'],
      name: widget.editDb['name'],
      description: widget.editDb['desc'],
      category: widget.editDb['cat'],
      attributes: attributes
    );
  }

  navigateToItemSharePage() {
    Item item = getItem();

    Navigator.push(context, MaterialPageRoute(builder: (context) => ItemSharePage(item: item)));
  }
}