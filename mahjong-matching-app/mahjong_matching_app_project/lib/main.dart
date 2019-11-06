import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'EventSearch.dart';
import 'Recritment.dart';
import 'NewHome.dart';
import 'Entity.dart';
import 'package:firebase_database/firebase_database.dart';

//ホーム画面のrun
void main() => runApp(new MaterialApp(
      title: "Home",
      home: new Home(),
    ));

/*----------------------------------------------

ホーム(BottomNavigationBar)クラス

----------------------------------------------*/
class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomeState();
  }
}

class HomeState extends State<Home> {
  int currentIndex = 0;
  PageParts set = new PageParts();

  List<Widget> tabs = [
    NewHomeManage(),
    //EventManage(key: PageStorageKey('EventManage'),),
    EventManage(),
    RecruitmentPage("createNew"),
    SampleTabItem("Message", Color(0xff160840)),
  ];
  Map<Widget, GlobalKey<NavigatorState>> navigatorKeys = {
    NewHomeManage(): GlobalKey<NavigatorState>(),
    EventManage(): GlobalKey<NavigatorState>(),
    RecruitmentPage("createNew"): GlobalKey<NavigatorState>(),
    SampleTabItem("Message", Color(0xff160840)): GlobalKey<NavigatorState>(),
  };

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[currentIndex].currentState.maybePop(),
      child: Scaffold(
        appBar: new AppBar(
          title:
              new Text("Matching App", style: TextStyle(color: set.fontColor)),
          backgroundColor: set.baseColor,
        ),
//        body: Stack(children: <Widget>[
//          _buildOffstageNavigator(NewHomeManage()),
//          _buildOffstageNavigator(EventManage()),
//          _buildOffstageNavigator(RecruitmentPage("createNew")),
//          _buildOffstageNavigator(SampleTabItem("Message", Color(0xff160840))),
//        ]),
        body: tabs[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          type: BottomNavigationBarType.fixed,
          fixedColor: set.fontColor,
          unselectedItemColor: Colors.white,
          backgroundColor: set.baseColor,
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              backgroundColor: set.baseColor,
              title: new Text('Home'),
            ),
            BottomNavigationBarItem(
              icon:
                  new Icon(const IconData(59574, fontFamily: 'MaterialIcons')),
              backgroundColor: set.baseColor,
              title: new Text('Search'),
            ),
            BottomNavigationBarItem(
                icon: new Icon(Icons.person),
                backgroundColor: set.baseColor,
                title: new Text('Recruitment')),
            BottomNavigationBarItem(
                icon: new Icon(Icons.message),
                backgroundColor: set.baseColor,
                title: new Text("Message")),
          ],
        ),
      ),
    );
  }

//  Widget _buildOffstageNavigator(Widget widget) {
//    return Offstage(
//      offstage: tabs[currentIndex] != widget,
////      child: Navigator(
////        navigatorKey: navigatorKeys[widget],
////        tabItem: tabItem,
////      ),
//      child:Navigator(
//        key:  navigatorKeys[widget],
//        initialRoute: TabNavigatorRoutes.root,
//        onGenerateRoute: (routeSettings) {
//          return MaterialPageRoute(
//              builder: (context) => routeBuilders[routeSettings.name](context));
//        });
//        ,
//    );
//  }
}

//class TabNavigator extends StatelessWidget {
//  TabNavigator({this.navigatorKey, this.widget});
//  final GlobalKey<NavigatorState> navigatorKey;
//  final Widget widget;
//
//  @override
//  Widget build(BuildContext context) {
//    var routeBuilders = _routeBuilders(context);
//    return Navigator();
//  }
//}

/*----------------------------------------------

ホーム(メインページ)クラス

----------------------------------------------*/
class Main extends StatefulWidget {
  const Main() : super();

  // アロー関数を用いて、Stateを呼ぶ
  @override
  MainState createState() => new MainState();
}

class MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: new Container(
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text('メイン',
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}

class SampleTabItem extends StatelessWidget {
  final String title;
  final Color color;
  PageParts set = PageParts();

  SampleTabItem(this.title, this.color) : super();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: set.backGroundColor,
      body: new Container(
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(this.title,
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}
