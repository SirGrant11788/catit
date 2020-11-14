import 'dart:io';
import 'package:cat_it/logic/globalDbSelect.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cat_it/services/db.dart';
import 'package:cat_it/ui/itemCreatePage.dart';
import 'package:cat_it/ui/itemDetailsPage.dart';
import 'package:cat_it/ui/uiViewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CatIt',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'CatIt'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseHelper database = DatabaseHelper();
  List<String> dbs;

  var dbMap;
  var dbMapFav;
  String leading1, leading2;
  List<String> favList = List();
  List<String> columnList = List();
  List<Tab> catTabList = List<Tab>();
  List<Widget> contTabList = List<Widget>();
  TextEditingController newCatalogueNameTextController = TextEditingController();

  void initState() {
    _query();
    getDbs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Tab>[
      Tab(text: 'Welcome\nadd an item to begin'),
    ];
    final _kTabs = <Tab>[
      Tab(text: 'WELCOME'),
    ];

    return FutureBuilder(
        future: _query(),
        builder: (context, snapshot) {
          return DefaultTabController(
            length: catTabList.length == 0 ? _kTabs.length : catTabList.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Title'),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      return value == 'catalogue'
                        ? _showCataloguesDialog(context)
                        : null;
                    }, //TODO settings page
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        child: Text('Catalogue'),
                        value: 'catalogue',
                      ),
                      const PopupMenuItem<String>(
                        child: Text('Info'),
                      ),
                    ];
                    },
                  ),
                ]
              ),
              body: new ListView(
                children: <Widget>[
                  new Container(
                    alignment: Alignment.center,
                    color: Colors.blueGrey[50],
                    height: favList.length != 0
                        ? MediaQuery.of(context).size.height / 3.3
                        : 0, //DYNAMIC size
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: favList.length,
                      itemBuilder: (BuildContext context, int ind) {
                        return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left:
                                BorderSide(width: 1.0, color: Colors.blue),
                                right:
                                BorderSide(width: 1.0, color: Colors.blue),
                                top: BorderSide(),
                              ),
                            ),
                            width: 160.0,
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: dbMapFav.length,
                                itemBuilder: (BuildContext context, int i) {
                                  return favList[ind] == dbMapFav[i]['fav']
                                      ? Card(
                                    child: Stack(
                                      children: <Widget>[
                                        '${dbMap[dbMapFav[i]['_id']]['pic'].toString()}' !=
                                            "" ||
                                            '${dbMap[dbMapFav[i]['_id']]['pic'].toString()}' !=
                                                null
                                            ? Image.file(new File(
                                            '${dbMap[dbMapFav[i]['_id']]['pic'].toString().substring(6).replaceAll("'", "")}'))
                                            : CircleAvatar(
                                            child: Icon(
                                                Icons.accessibility)),
                                        Container(
                                          alignment:
                                          Alignment.bottomCenter,
                                          color: Colors.blue[500]
                                              .withOpacity(0.5),
                                          child: Center(
                                            child: RichText(
                                              text: TextSpan(
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black,
                                                  ),
                                                  children: <TextSpan>[
                                                    new TextSpan(
                                                      text:
                                                      '${dbMap[dbMapFav[i]['_id']]['name']}\n',
                                                      style:
                                                      new TextStyle(
                                                        fontSize: 16.0,
                                                        color:
                                                        Colors.white,
                                                      ),
                                                    ),
                                                    new TextSpan(
                                                        text:
                                                        '${favList[ind]}',
                                                        style:
                                                        new TextStyle(
                                                          fontSize: 10.0,
                                                          color: Colors
                                                              .white,
                                                        )),
                                                  ]),
                                              textAlign: TextAlign.center,
                                              softWrap: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      : Container();
                                }));
                      },
                    ),
                  ),
                  new Container(
                    decoration: new BoxDecoration(
                        color: Theme.of(context).primaryColor),
                    alignment: Alignment.center,
                    child: TabBar(
                      isScrollable: true,
                      tabs: catTabList.length == 0 ? _kTabs : catTabList,
                    ),
                  ),
                  new Container(
                    alignment: Alignment.center,
                    color: Colors.blueGrey[50],
                    height: favList.length != 0
                        ? MediaQuery.of(context).size.height / 2.08
                        : MediaQuery.of(context).size.height /
                        1,
                    child: TabBarView(
                      children:
                      catTabList.length == 0 ? _kTabPages : contTabList,
                    ),
                  ),
                ],
              ),
              floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.accessibility_new),
                mini: true,
                onPressed: () {
                  if (dbMap != null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ViewerPage()));
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Add Items First',
                      toastLength: Toast.LENGTH_LONG,
                    );
                  }
                },
              ),
              bottomNavigationBar: BottomAppBar(
                shape: CircularNotchedRectangle(),
                notchMargin: 2.0,
                child: new Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddItemPage()), //AddProductPage()
                          );
                        }),
                    IconButton(
                      icon: Icon(Icons.shopping_basket),
                      onPressed: () {
                        //TODO website
                        Fluttertoast.showToast(
                          msg: 'button pressed. WEBSITE',
                          toastLength: Toast.LENGTH_LONG,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _query() async {
    final allRows = await database.queryAllRows();
    final allRowsFav = await database.queryAllRowsFav();

    columnList.clear();
    final allColumns = await database.queryColumns();
    allColumns.forEach((column) {
      columnList.add('${column['name']}');
    });
    if(columnList.length >=4){
      leading1 = columnList[4];
    }
    catTabList.clear();
    allRows.forEach((row) {
      if (!catTabList.toString().contains('${row['cat']}')) {
        catTabList.add(Tab(text: '${row['cat']}'));
      }
    });

    favList.clear();
    allRowsFav.forEach((element) {
      if (!favList.toString().contains('${element['fav']}')) {
        favList.add('${element['fav']}');
      }
    });

    dbMap = allRows;
    dbMapFav = allRowsFav;

    loadList();
  }

  loadList() {
    contTabList.clear();
    for (int i = 0; i < catTabList.length; i++) {
      contTabList.add(
        ListView.builder(
          itemCount: dbMap.length,
          itemBuilder: (ctx, index) {
            return catTabList[i].text == dbMap[index]['cat']
                ? new Card(
              child: new ListTile(
                leading: '${dbMap[index]['pic'].toString()}' != "" ||
                    '${dbMap[index]['pic'].toString()}' != null
                    ? Image.file(new File(
                    '${dbMap[index]['pic'].toString().substring(6).replaceAll("'", "")}'))
                    : CircleAvatar(child: Icon(Icons.accessibility)),
                title: Text('${dbMap[index]['name']}'),
                subtitle: columnList[4] != null
                    ? Text('${dbMap[index]['$leading1']}')
                    : Text(''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditProductPage(dbMap[index], columnList)),
                  );
                },
              ),
            )
                : new Container();
          },
        ),
      );
    }
  }

  _showCataloguesDialog(BuildContext context)  async {
    GlobalDbSelect dbSelect = GlobalDbSelect();
    List dbsTemp = dbs;
    dbsTemp.add('Add Catalogue');
              return showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Catalogue'),
                  content: Container(
                    width: double.minPositive,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: dbsTemp.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(dbsTemp[index].toString()),
                          onTap: () {
                            if(dbsTemp[index].toString() == 'Add Catalogue' ){
                              showCatalogueNameDialog(context, dbs);
                            }else{
                              dbSelect.dbNo = index;
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => MyApp()));
                            }
                          },
                        );
                      },
                    ),
                  ),
                );
              });
    }

  showCatalogueNameDialog(BuildContext context,List dbs) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('NEW CATALOGUE'),
            content: TextField(
              controller: newCatalogueNameTextController,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('SAVE'),
                onPressed: () {
                  if(newCatalogueNameTextController.text != null || newCatalogueNameTextController.text != '') {
                    dbs.add(newCatalogueNameTextController.text);
                    storeNewCatalogue(dbs);
                  }
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyApp()));
                },
              ),
            ],
          );
        });
  }

  storeNewCatalogue(List dbs) async {
    final localCache = await SharedPreferences.getInstance();
    localCache.setStringList('databases', dbs);
  }

    void getDbs() async {
      final localCache = await SharedPreferences.getInstance();
       dbs = localCache.getStringList('databases');
    }
  }



