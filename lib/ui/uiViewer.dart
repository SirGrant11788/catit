import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cat_it/services/db.dart';
import 'package:cat_it/ui/uiAppHome.dart';
import 'package:weather/weather.dart';

class ViewerPage extends StatefulWidget {
  @override
  _ViewerPageState createState() {
    return _ViewerPageState();
  }
}

class _ViewerPageState extends State<ViewerPage> {
  final db = DatabaseHelper.instance;
  TextEditingController _textFieldControllerDialog = TextEditingController();
  List<DropdownMenuItem<String>> favList = List();
  String _btnSelectedValFav;
  var dbMap;
  var dbMapFav;
  List<Widget> catListWidget = List<Widget>();
  List<ChoiceChip> chipCat = List<ChoiceChip>();
  List catList = List();
  List<String> prefListCat = List();

  String weatherToday = "MyThreads";
  String weatherIcon = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _query(),
        builder: (context, snapshot) {
          return Scaffold(
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
              title: Text('Title')
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: chipCat),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      new Center(
                        child: new Container(
                          width: MediaQuery.of(context).size.height *
                              0.5172, //0.5294
                          color: Colors.blueGrey[50],
                          height: MediaQuery.of(context).size.height * 0.8425,
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: catList.length,
                              itemBuilder: (context, index) {
                                return !prefListCat
                                    .contains(catList[index].text)
                                    ? Container(
                                  width:
                                  MediaQuery.of(context).size.width *
                                      0.6,
                                  child: Card(
                                    child: Container(
                                      width: MediaQuery.of(context)
                                          .size
                                          .height *
                                          0.1,
                                      color: Colors.blueGrey[70],
                                      height: MediaQuery.of(context)
                                          .size
                                          .height *
                                          0.2,
                                      child: Center(
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                            PageScrollPhysics(), //stepping through the scroll
                                            scrollDirection:
                                            Axis.horizontal,
                                            itemCount: dbMap.length,
                                            itemBuilder: (context, ind) {
                                              return catList[index]
                                                  .text ==
                                                  dbMap[ind]['cat']
                                                  ? Container(
                                                width: (MediaQuery.of(
                                                    context)
                                                    .size
                                                    .width /
                                                    1.019),
                                                child: Card(
                                                  color: Colors
                                                      .blue[50],
                                                  child: ListTile(
                                                    title: Row(
                                                      children: <
                                                          Widget>[
                                                        Container(
                                                          //info of item
                                                          width: (MediaQuery.of(context).size.width /
                                                              1.05) /
                                                              3, //1.019
                                                          child:
                                                          RichText(
                                                            text: TextSpan(
                                                                style: TextStyle(
                                                                  fontSize: 14.0,
                                                                  color: Colors.black,
                                                                ),
                                                                children: <TextSpan>[
                                                                  new TextSpan(
                                                                    text: '${dbMap[ind]['name'].toString()}\n',
                                                                    style: new TextStyle(
                                                                      fontSize: 14.0,
                                                                    ),
                                                                  ),
                                                                  new TextSpan(text: '${dbMap[ind]['size'].toString()} ${dbMap[ind]['fit'].toString()}\n', style: new TextStyle(fontSize: 12.0, color: Colors.black87)),
                                                                  new TextSpan(text: '${dbMap[ind]['desc'].toString()}', style: new TextStyle(fontSize: 11.0, color: Colors.black54)),
                                                                ]),
                                                            textAlign:
                                                            TextAlign.center,
                                                            softWrap:
                                                            true,
                                                          ),
                                                        ),
                                                        '${dbMap[ind]['pic'].toString()}' !=
                                                            "" ||
                                                            '${dbMap[ind]['pic'].toString()}' !=
                                                                null
                                                            ? Container(
                                                            width: (MediaQuery.of(context).size.width / 1.019) /
                                                                3,
                                                            child: Image
                                                                .file(
                                                              new File('${dbMap[ind]['pic'].toString().substring(6).replaceAll("'", "")}'),
                                                              height: MediaQuery.of(context).size.height * 0.18,
                                                            ))
                                                            : Container(
                                                            width: (MediaQuery.of(context).size.width / 1.019) /
                                                                3,
                                                            child:
                                                            CircleAvatar(child: Icon(Icons.accessibility))),
                                                        Container(
                                                          width: (MediaQuery.of(context).size.width /
                                                              1.019) /
                                                              4.19,
                                                          child:
                                                          Column(
                                                            children: <
                                                                Widget>[
                                                              Container(
                                                                width:
                                                                (MediaQuery.of(context).size.width / 1.019) / 3,
                                                                height:
                                                                (MediaQuery.of(context).size.width / 1.019) / 15,
                                                                child:
                                                                DropdownButton(
                                                                  icon: Icon(Icons.favorite),
                                                                  iconSize: 12,
                                                                  elevation: 16,
                                                                  isExpanded: false,
                                                                  style: TextStyle(fontSize: 10, color: Colors.black),
                                                                  value: _btnSelectedValFav,
                                                                  hint: Text(
                                                                    'Fav',
                                                                    style: TextStyle(fontSize: 10),
                                                                  ),
                                                                  onChanged: ((String newValue) {
                                                                    if (newValue == 'Add New Fav') {
                                                                      _showDialog(context, 'Fav', 'e.g. Formal Dinner').then((val) {
                                                                        favList.add(DropdownMenuItem<String>(value: '$val', child: Text('$val')));
                                                                      });
                                                                    } else {
                                                                      setState(() {
                                                                        _btnSelectedValFav = newValue;
                                                                      });
                                                                    }
                                                                  }),
                                                                  items: favList,
                                                                ),
                                                              ),
                                                              _btnSelectedValFav != null
                                                                  ? Container(
                                                                  height: (MediaQuery.of(context).size.width / 28) / 1,
                                                                  width: (MediaQuery.of(context).size.width / 1.019) / 4.19,
                                                                  child: RaisedButton(
                                                                    color: Colors.blue[200],
                                                                    child: Text(
                                                                      'SAVE',
                                                                      style: TextStyle(fontSize: 8),
                                                                    ),
                                                                    onPressed: () {
                                                                      _insert('$ind', '${dbMap[ind]['name'].toString()}', _btnSelectedValFav);
                                                                    },
                                                                  ))
                                                                  : Container(
                                                                height: (MediaQuery.of(context).size.width / 28) / 1,
                                                                width: (MediaQuery.of(context).size.width / 1.019) / 4.19,
                                                              ),
                                                              Container(
                                                                width:
                                                                (MediaQuery.of(context).size.width / 1.019) / 3,
                                                                height:
                                                                (MediaQuery.of(context).size.width / 1.019) / 3.9,
                                                                child:
                                                                ListView.builder(
                                                                  shrinkWrap: true,
                                                                  itemCount: dbMapFav.length,
                                                                  itemBuilder: (BuildContext context, int i) {
                                                                    return dbMapFav[i]['fav_name'].toString() == dbMap[ind]['name'].toString()
                                                                        ? Dismissible(
                                                                      key: UniqueKey(),
                                                                      onDismissed: (DismissDirection dir) {
                                                                        _delFav(dbMapFav[i]['_id_fav']);
                                                                      },
                                                                      background: Container(
                                                                        color: Colors.red,
                                                                        child: Icon(Icons.delete),
                                                                        alignment: Alignment.centerLeft,
                                                                      ),
                                                                      secondaryBackground: Container(
                                                                        color: Colors.red,
                                                                        child: Icon(Icons.delete),
                                                                        alignment: Alignment.centerRight,
                                                                      ),
                                                                      child: ListTile(
                                                                        title: Text(
                                                                          '${dbMapFav[i]['fav'].toString()}',
                                                                          style: TextStyle(fontSize: 10, color: Colors.black),
                                                                        ),
                                                                      ),
                                                                    )
                                                                        : Container();
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                                  : Container();
                                            }),
                                      ),
                                    ),
                                  ),
                                )
                                    : Container();
                              }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  _delFav(favId) async {
    await db.deleteFav(favId);
    setState(() {});
  }

  _query() async {
    final allRows = await db.queryAllRows();
    final allRowsFav = await db.queryAllRowsFav();
    dbMap = allRows;
    dbMapFav = allRowsFav;
    catList.clear();
    allRows.forEach((row) {
      if (!catList.toString().contains('${row['cat']}')) {
        catList.add(Tab(text: '${row['cat']}'));
      }
    });
    chipCat.clear();
    for (int i = 0; i < catList.length; i++) {
      chipCat.add(
        ChoiceChip(
          label: Text('${catList[i].text}'),
          selected: prefListCat.contains('${catList[i].text}') == false,
          onSelected: (value) {
            setState(() {
              if (prefListCat.contains('${catList[i].text}') == true) {
                prefListCat.remove('${catList[i].text}');
              } else {
                prefListCat.add('${catList[i].text}');
              }
            });
          },
        ),
      );
    }

    List<String> tempFavList = List();
    if (favList.length == 0) {
      allRowsFav.forEach((row) {
        allRowsFav.forEach((row) {
          if (!tempFavList.toString().contains('${row['fav']}')) {
            tempFavList.add('${row['fav']}');
            favList.add(DropdownMenuItem<String>(
                value: '${row['fav']}',
                child: Text('${row['fav']}',
                    style: TextStyle(fontSize: 10, color: Colors.black))));
          }
        });
      });
      favList.add(DropdownMenuItem<String>(
          value: 'Add New Fav',
          child: Text(
            'Add New Fav',
            style: TextStyle(fontSize: 10, color: Colors.black),
          )));
    }
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

  void _insert(itemID, itemName, fav) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: '$itemID',
      DatabaseHelper.columnFavName: '$itemName',
      DatabaseHelper.columnFav: '$fav',
    };
    await db.insertFav(row);

    Fluttertoast.showToast(
      msg: 'Item $itemName Added To $fav',
      toastLength: Toast.LENGTH_SHORT,
    );

    setState(() {
      _btnSelectedValFav = null;
    });
  }
}