import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cat_it/services/db.dart';
import 'package:cat_it/ui/uiAppHome.dart';

class EditProductPage extends StatefulWidget {
  final dynamic editDb;
  final List<String> colDb;
  EditProductPage(this.editDb, this.colDb);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  DatabaseHelper database = DatabaseHelper();
  String temp;

  void initState() {
    super.initState();
    callDb();

  }
  callDb() async {
    database = DatabaseHelper();
  }

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
        title: Text('${widget.editDb['name']}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Fluttertoast.showToast(
                msg: '${widget.editDb['name']} Deleted',
                toastLength: Toast.LENGTH_LONG,
              );
              deleteItem('${widget.editDb['_id']}','${widget.editDb['name']}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          InkWell(
            child:
            Container(
              padding: const EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/3,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color: Colors.blue)),
              child: '${widget.editDb['pic'].toString()}' != "" ||
                  '${widget.editDb['pic'].toString()}' != null
                  ? Image.file(new File(
                  '${widget.editDb['pic'].toString().substring(6).replaceAll("'", "")}'))
                  : CircleAvatar(child: Icon(Icons.accessibility)),
            ),
            onTap: () {
              _pickImageFromCamera('${widget.editDb['_id']}','pic');//id,col
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/1.8,
            child: ListView.builder(
              itemCount: widget.colDb.length,
              itemBuilder: (BuildContext context, int index) {

                return widget.colDb[index] != '_id' && widget.colDb[index] != 'pic'?
                Container(
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
                          labelText: '${widget.editDb[widget.colDb[index]]}',
                          suffixIcon:IconButton(
                              icon: Icon(Icons.save),
                              onPressed: () {
                                updateItem('${widget.editDb['_id']}','${widget.colDb[index]}', '$temp');
                                Fluttertoast.showToast(
                                  msg: '${widget.editDb[widget.colDb[index]]} changed to $temp',
                                  toastLength: Toast.LENGTH_LONG,
                                );
                                temp=null;
                              })
                      ),
                      onChanged: (value) {
                        temp=null;//stop form fields crossing
                        temp=value;
                      },
                    ))
                    :Container();
              },
            ),
          ),
        ]),
      ),
    );
  }

  deleteItem(id,name) async {
    print('$id $name');

    await database.delete(int.parse(id));
    await database.deleteFavName('$name');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  updateItem(id,col,name) async {
    await database.updateItemQuery(id,col,name);
    if('$col'== 'name'){
      await database.updateQueryFavName(id,name);
    }
  }

  Future _pickImageFromCamera(id,col) async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    await database.updateItemQuery(id,col,'${image.uri}');
    print('$col:${image.uri} UPDATED');
  }
}