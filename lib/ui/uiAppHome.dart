import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cat_it/services/db.dart';
import 'package:cat_it/services/weatherDialog.dart';
import 'package:cat_it/ui/uiAddItem.dart';
import 'package:cat_it/ui/uiEditProduct.dart';
import 'package:cat_it/ui/uiViewer.dart';
import 'package:weather/weather.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyThreads',//TODO chnage name to CatIt ?
      theme: ThemeData(
        // This is the theme of your application.

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'MyThreads'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final db = DatabaseHelper.instance;
  var dbMap;
  var dbMapFav;
  String leading1, leading2;
  List<String> favList = List(); //diplsay fav 'cat' horizontal
  List<String> columnList = List(); //list of columns in the database
  List<Tab> catTabList = List<Tab>();
  List<Widget> contTabList = List<Widget>();
  String weatherToday = "MyThreads";
  String weatherIcon = '';
  WeatherStation weatherStation =
  new WeatherStation("996cc4f3b136aea607960591dd64e7a5");

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Tab>[
      Tab(text: 'Welcome\nadd an item to begin'), //TODO proper intro
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
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: weatherIcon == ''
                      ? [Text("")]
                      : [
                    Image.network(
                      'http://openweathermap.org/img/wn/$weatherIcon@2x.png',
                      fit: BoxFit.contain,
                      height: 32,
                    ),
                    InkWell(
                      child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            weatherToday,
                            style: new TextStyle(fontSize: 17.64),
                          )),
                      onTap: () {
                        showDialogWeather(context);
                      },
                    ),
                  ],
                ),
                leading: PopupMenuButton<String>(
                  onSelected: (value) => value == 'Settings'
                      ? _delTables()
                      : null, //TODO settings page

                  itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<String>>[
                    // const PopupMenuItem<String>(
                    //   child: Text('Shop'),
                    //   value: 'Shop',
                    // ),
                    // const PopupMenuItem<String>(
                    //   child: Text('Backup'),
                    //   value: 'Backup',
                    // ),
                    const PopupMenuItem<String>(
                      child: Text('Settings'),
                      value: 'Settings',
                    ),
                    const PopupMenuItem<String>(
                      child: Text('Info'),
                    ),
                  ],
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      Fluttertoast.showToast(
                        msg: 'search pressed',
                        toastLength: Toast.LENGTH_LONG,
                      );
                    },
                  ),
                  //TODO Website login
                  // IconButton(
                  //   icon: Icon(Icons.account_circle),
                  //   onPressed: () {
                  //     Fluttertoast.showToast(
                  //       msg: 'account pressed',
                  //       toastLength: Toast.LENGTH_LONG,
                  //     );
                  //   },
                  // ),
                ],
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
                        1, // DYNAMIC sizing
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

  _delTables() async {
    print('_delTables executed');
    // await db.deleteAllTablePack();
    //  await db.deleteAllTableFav();
    //  await db.deleteAllTable();
    // await db.deleteAllTableFavRows();
  }

  _query() async {
    final allRows = await db.queryAllRows();
    final allRowsFav = await db.queryAllRowsFav();

    columnList.clear();
    final allColumns = await db.queryColumns();
    allColumns.forEach((column) {
      // print('${column['name']}');
      columnList.add('${column['name']}');
    });
    if(columnList.length >=4){
      leading1 = columnList[4];
      //leading2 = columnList[5];
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

    Weather weather = (await weatherStation.currentWeather());
    if ('${weather.weatherMain}' != null &&
        '${weather.tempMin.celsius.round()}' != null &&
        '${weather.tempMax.celsius.round()}' != null) {
      weatherToday =
      '${weather.weatherMain} ${weather.tempMin.celsius.round()}°C/${weather.tempMax.celsius.round()}°C';
      if ('${weather.weatherIcon}' != null) {
        weatherIcon = weather.weatherIcon;
      }
    }
  }

  //loads the items into the correct tabs
  loadList() {
    contTabList.clear();
    for (int i = 0; i < catTabList.length; i++) {
      //run for number of available tabs
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
                // trailing: Icon(Icons.arrow_right),
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

// _delItem(id, name) async {
//   await db.deleteFavName('$name');
//   await db.delete(id);
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => MyApp()),
//   );
// }

// _updateItem(id, name, cat, size, fit, weather, rating, desc, pic) async {
//   await db.updateQuery(id, name, cat, size, fit, weather, rating, desc, pic);
//   await db.updateQueryFavName(id, name);

//   print('item updated');
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => MyApp()),
//   );
// }
}
