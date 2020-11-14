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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseHelper database = DatabaseHelper();
  List<String> dbs;
  bool isLoadingData = false;
  var dbMap;
  var dbMapFav;
  String leading1, leading2;
  List<String> favList = [];
  List<String> columnList = [];
  List<Tab> categoryTabs = [];
  List<Widget> contTabList = [];
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

    return DefaultTabController(
            length: categoryTabs.length == 0 ? _kTabs.length : categoryTabs.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text('CatIt'),
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
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add),
                  mini: true,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.list_alt, color: Colors.blue),
                      iconSize: 32.0,
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
                  ],
                ),
              ),
              body: (isLoadingData == false) ? new ListView(
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
                                left: BorderSide(width: 1.0, color: Colors.blue),
                                right: BorderSide(width: 1.0, color: Colors.blue),
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
                      tabs: categoryTabs.length == 0 ? _kTabs : categoryTabs,
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
                      categoryTabs.length == 0 ? _kTabPages : contTabList,
                    ),
                  ),
                ],
              ) : Center(child: CircularProgressIndicator(backgroundColor: Colors.blueAccent))
            ),
          );
  }

  _query() async {
    setState(() {
      isLoadingData = true;
    });

    final allRows = await database.queryAllRows();
    final allRowsFav = await database.queryAllRowsFav();
    final allColumns = await database.queryColumns();

    setState(() {
      columnList.clear();
      allColumns.forEach((column) {
        columnList.add(column['name']);
      });
      if(columnList.length >=4){
        leading1 = columnList[4];
      }
      categoryTabs.clear();
      allRows.forEach((row) {
        if (!categoryTabs.toString().contains(row['cat'])) {
          categoryTabs.add(Tab(text: row['cat']));
        }
      });

      favList.clear();
      allRowsFav.forEach((element) {
        if (!favList.toString().contains(element['fav'])) {
          favList.add(element['fav']);
        }
      });

      dbMap = allRows;
      dbMapFav = allRowsFav;

      loadList();

      isLoadingData = false;
    });
  }

  loadList() {
    contTabList.clear();
    for (int i = 0; i < categoryTabs.length; i++) {
      contTabList.add(
        ListView.builder(
          itemCount: dbMap.length,
          itemBuilder: (ctx, index) {
            return categoryTabs[i].text == dbMap[index]['cat']
                ? new Card(
              child: new ListTile(
                leading: '${dbMap[index]['pic'].toString()}' != "" ||
                    '${dbMap[index]['pic'].toString()}' != null
                    ? Image.file(new File(
                    '${dbMap[index]['pic'].toString().substring(6).replaceAll("'", "")}'))
                    : CircleAvatar(child: Icon(Icons.accessibility)),
                title: Text(dbMap[index]['name']),
                subtitle: columnList[4] != null
                    ? Text(dbMap[index]['desc'])
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
    List dbsTemp = [];
    dbsTemp.addAll(dbs);

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



