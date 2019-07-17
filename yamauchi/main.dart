import 'package:flutter/material.dart';
//import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
//https://flutter.ctrnost.com/tutorial/tutorial03/
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(new MaterialApp(
  title: "Home",
  home: new Home(),
));
/*
mainメソッドの箇所に書かれている「=>」はワンライナーで書くときの記述方式です。 通常の書き方だと以下のようになります。
void main()  {
          runApp(MyApp());
        }
*/
class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomeState();
  }
}

class HomeState extends State<Home> {
  int currentIndex = 0;
  final List<Widget> tabs = [
    Main(),
    SampleTabItem("Search", Colors.red),
    Recruitment(),
    SampleTabItem("Settings", Colors.red),
  ];

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("雀士Matching App"),
        backgroundColor: Colors.pink[300],
      ),
      body: tabs[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.pink[300],
        currentIndex: currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            backgroundColor: Colors.pink[300],
            title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(const IconData(59574, fontFamily: 'MaterialIcons')),
            backgroundColor: Colors.pink[300],
            title: new Text('Search'),
          ),
          BottomNavigationBarItem(
              icon: new Icon(Icons.person),
              backgroundColor: Colors.pink[300],
              title: new Text('Recruitment')
          ),
          BottomNavigationBarItem(
              icon: new Icon(Icons.settings),
              backgroundColor: Colors.pink[300],
              title: new Text("Settings")
          ),
        ],
      ),
    );
  }
}

class Main extends StatefulWidget {
  const Main() : super();
  // アロー関数を用いて、Stateを呼ぶ
  @override
  MainState createState() => new MainState();
}
class MainState extends State<Main>{
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

class PrefData {
  String prefCode;
  String prefName;

  PrefData.fromJson(Map<String, dynamic> json)
      : prefCode = json['pref_cd'],
        prefName = json['pref_name'];
}
class LineData {
  String lineCode;
  String lineName;

  LineData.fromJson(Map<String, dynamic> json)
      : lineCode = json['line_cd'],
        lineName = json['line_name'];
}

class Recruitment extends StatefulWidget {
  const Recruitment() : super();
  // アロー関数を用いて、Stateを呼ぶ
  @override
  RecruitmentState createState() => new RecruitmentState();
}
class RecruitmentState extends State<Recruitment>{
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _defaultValue1 = 'りんご';
  String _defaultValue2 = '---';
  String _defaultValue3 = '---';
  Map line,station;
  List<PrefData> prefDataList;
  List<String> prefList,lineList,stationList;
  String prefFile;
  List<String> _list2 = <String>['---'];
  List<String> _list = <String>['りんご', 'オレンジ', 'みかん', 'ぶどう'];

  void main() {
    loadAsset().then((String value){
      setState(() {
        prefFile = value;
      });
    });
    Map<String, dynamic> pref = jsonDecode(prefFile);
    (pref as Map<String,dynamic>).forEach((key,value){
      print(key);
      print(value);
    });
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('lib/pref2.json');
  }


  void _handleChange1(String newValue) {
    setState(() {
      _defaultValue1 = newValue;
    });
  }
  void _handleChange2(String newValue) {
    setState(() {
      _defaultValue2 = newValue;

    });
  }
  void _handleChange3(String newValue) {
    setState(() {
      _defaultValue3 = newValue;
    });
  }
  //フォーム送信用
  void _submission() {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();
      Scaffold
          .of(context)
          .showSnackBar(SnackBar(content: Text('Processing Data')));
      print(this._name);
      print(this._email);
    }
  }

  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: <Widget>[
                new TextFormField(
                  enabled: true,
                  maxLength: 20,
                  maxLengthEnforced: false,
                  obscureText: false,
                  autovalidate: false,
                  decoration: const InputDecoration(
                    hintText: 'お名前を教えてください',
                    labelText: '名前 *',
                  ),
                  validator: (String value) {
                    return value.isEmpty ? '必須入力です' : null;
                  },
                  onSaved: (String value) {
                    this._name = value;
                  },
                ),
                new TextFormField(
                  maxLength: 100,
                  autovalidate: true,
                  decoration: const InputDecoration(
                    hintText: '連絡先を教えてください。',
                    labelText: 'メールアドレス *',
                  ),
                  onSaved: (String value) {
                    this._email = value;
                  },

                ),
                //県名
                DropdownButton<String>(
                  value: _defaultValue1,
                  onChanged: _handleChange1,
                  items: _list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                //県名
                DropdownButton<String>(
                  value: _defaultValue2,
                  onChanged: _handleChange2,
                  items: _list2.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                //駅名
                DropdownButton<String>(
                  value: _defaultValue3,
                  onChanged: _handleChange3,
                  items: _list2.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                RaisedButton(
                  onPressed: _submission,
                  child: Text('保存'),
                )
              ]
            )
        )
    );
  }

}

class SampleTabItem extends StatelessWidget {
  final String title;
  final Color color;

  const SampleTabItem(this.title, this.color) : super();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: this.color,
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

//class ControlEvent {
//  String key;
//  int userId;
//  int recruitMember;
//  String nearestStation1;
//  String nearestStation2;
//  String nearestStation3;
//  DateTime startingTime;
//  DateTime endingTime;
//
//  ControlEvent();
//
//  ControlEvent.fromSnapShot(DataSnapshot snapshot):
//        key = snapshot.key,
//        userId = snapshot.value["userId"],
//        recruitMember = snapshot.value["recruitMember"],
//        nearestStation1 = snapshot.value["nearestStation1"],
//        nearestStation2 = snapshot.value["nearestStation2"],
//        nearestStation3 = snapshot.value["nearestStation3"],
//        startingTime = new DateTime.fromMillisecondsSinceEpoch(snapshot.value["startingTime"]),
//        endingTime = new DateTime.fromMillisecondsSinceEpoch(snapshot.value["endingTime"]);
//}