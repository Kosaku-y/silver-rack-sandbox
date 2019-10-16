import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_cupertino_data_picker/flutter_cupertino_data_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Entity.dart';


/*----------------------------------------------

イベント管理用クラス

----------------------------------------------*/
class EventManage extends StatelessWidget {
  @override
  //EventManage({Key key}) : super(key: key);
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EventManagePage(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new EventManagePage(),
      },
    );
  }
}


/*----------------------------------------------

イベント検索フォームページクラス

----------------------------------------------*/
class EventManagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new EventManagePageState();
  }
}
class EventManagePageState extends State<EventManagePage> {
  final _formKey = GlobalKey<FormState>();
  List lineData = [""];
  List stationData = [""];
  Pref pref;
  Line line;
  Station station;
  String _selectPref;
  String _selectLine;
  String _selectStation;
  String _eventId;
  int changePref = 0;
  int changeLine = 0;
  int changeStation = 0;
  Map lineMap;
  Map stationMap;

  TextEditingController _prefController = new TextEditingController(text: '');
  TextEditingController _lineController = new TextEditingController(text: '');
  TextEditingController _stationController = new TextEditingController(text: '');
  TextEditingController _eventIdController = new TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
            padding: const EdgeInsets.all(30.0),
            child: SingleChildScrollView(
                child: Column(
                    children: <Widget>[
                      Material(child: Text("検索条件を入力してください")),
                      _prefPicker(),
                      _linePicker(),
                      _stationPicker(),
                      RaisedButton(
                        onPressed: () => _submission(),
                        child: Text('検索する'),
                      ),
                      RaisedButton(
                          onPressed: () => _delete(), child: Text('期限切れ削除')),
                      RaisedButton(
                        onPressed: () => _correction(),
                        child: Text('イベント修正'),
                      )
                    ]
                )
            )
        )
    );
  }

  //ログ出力用メソッド
  void printMap(String actionName, Map map) {
    print("\n-----------$actionName Data-----------\n"
        "eventId:" + map["eventId"].toString() + "\n"
        "member:" + map["recruitMember"] + "\n"
        "station:" + map["station"] + "\n"
        "start:" + DateTime.fromMillisecondsSinceEpoch(map["startingTime"]).toString() + "\n"
        "end:" + DateTime.fromMillisecondsSinceEpoch(map["endingTime"]).toString() + "\n"
        "remarks:" + map["remarks"] + "\n"
        "-------------------------------\n");
  }

  //イベント修正
  void _correction() {}


  //期限切れイベント削除用メソッド
  void _delete() {
    DateTime now = DateTime.now();
    final _mainReference =
        FirebaseDatabase.instance.reference().child("Events");
    _mainReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((k, v) {
        v.forEach((k1, v1) {
          v1.forEach((k2, v2) {
            if (DateTime.fromMillisecondsSinceEpoch(v2["endingTime"])
                .isBefore(now)) {
              _mainReference.child(k).child(k1).child(k2).remove();
              printMap("remove", v2);
            }
          });
        });
      });
    });
  }

  //フォーム送信用メソッド
  void _submission() {
    if (this._formKey.currentState.validate()) {
      //Navigator.of(context).pushNamed("/subpage");
      if(_eventId != null){

      }else {
        Navigator.push(
            this.context,
            MaterialPageRoute(
              // パラメータを渡す
                builder: (context) =>
                new EventSearchResultPage(_selectPref, _selectLine, _selectStation)));
      }
    }
  }

  //都道府県Picker
  Widget _prefPicker() {
    return new GestureDetector(
      onTap: () {
        DataPicker.showDatePicker(
          context,
          showTitleActions: true,
          locale: 'en',
          datas: Pref.pref.keys.toList(),
          title: '都道府県',
          onConfirm: (value) {
            if (value != "") {
              setState(() {
                _prefController.text = value;
                _selectPref = value;
                _prefChange(value);
              });
            }
          },
        );
      },
      child: AbsorbPointer(
        child: new TextFormField(
          enableInteractiveSelection: false,
          controller: _prefController,
          decoration: InputDecoration(
            icon: Icon(Icons.place),
            hintText: 'Choose a prefecture',
            labelText: '都道府県',
          ),
          validator: (String value) {
            if (changePref == 2) {
              return '再選択してください';
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }

  //路線Picker
  Widget _linePicker() {
    return new GestureDetector(
      onTap: () {
        DataPicker.showDatePicker(
          context,
          showTitleActions: true,
          locale: 'en',
          datas: lineData,
          title: '路線',
          onConfirm: (value) {
            if (value != "") {
              setState(() {
                _lineController.text = value;
                _lineChange(value);
              });
            }
          },
        );
      },
      child: AbsorbPointer(
        child: new TextFormField(
          enableInteractiveSelection: false,
          controller: _lineController,
          decoration: InputDecoration(
            icon: Icon(Icons.train),
            hintText: 'Choose a line',
            labelText: '路線',
          ),
          validator: (String value) {
            if (changeLine == 2) {
              return '再選択してください';
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }

  //駅Picker
  Widget _stationPicker() {
    return new GestureDetector(
      onTap: () {
        DataPicker.showDatePicker(
          context,
          showTitleActions: true,
          locale: 'en',
          datas: stationData,
          title: '駅',
          onConfirm: (value) {
            if (value != "") {
              setState(() {
                _stationController.text = value;
                _selectStation = value;
                changeStation = 1;
              });
            }
          },
        );
      },
      child: AbsorbPointer(
        child: new TextFormField(
          enableInteractiveSelection: false,
          controller: _stationController,
          decoration: InputDecoration(
            icon: Icon(Icons.subway),
            hintText: 'Choose a station',
            labelText: '駅名',
          ),
          validator: (String value) {
            if (changeStation == 2) {
              return '再選択してください';
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }

  //イベントIDで検索する用のテキストエリア (管理者用)
  Widget eventIdform(){
    return  new TextFormField(
      controller: _eventIdController,
      decoration: InputDecoration(
        icon: Icon(Icons.format_list_numbered),
        hintText: 'input eventID',
        labelText: 'イベントID(管理者用)',
      ),
      validator: (String value) {
          return null;},
        onSaved: (String value){
          _eventId = value;
        }
    );
  }

  //県Pickerが選択された時の処理メソッド
  void _prefChange(String newValue) {
    setState(() {
      changePref = 1;
      //県、路線、駅、組み合わせ矛盾チェック
      if (changeLine != 0 || changeStation != 0) {
        changeLine = 2;
        changeStation = 2;
      }
      int prefNum = int.parse(Pref.pref[newValue]);
      lineMap = new Map<String, int>();
      var url = 'http://www.ekidata.jp/api/p/' + prefNum.toString() + '.json';
      //APIコール
      http.get(url).then((response) {
        var body = response.body.substring(50, response.body.length - 58);
        var mapLine = jsonDecode(body);
        mapLine["line"].forEach((i) {
          lineMap[i["line_name"]] = i["line_cd"];
        });
        //lineMap.forEach((key,value) => lineData.add(key));
        lineData = lineMap.keys.toList();
      });
    });
  }

  //路線チェンジ用
  void _lineChange(String newValue) {
    setState(() {
      //県、路線、駅、組み合わせ矛盾チェック
      if (changeLine == 0) {
        changeLine = 1;
      } else if (changeLine == 1) {
        if (changeStation != 0) {
          changeStation = 2;
        }
      } else {
        changeLine = 1;
      }
      _selectLine = newValue;
      int lineNum = lineMap[newValue];
      stationMap = new Map<String, int>();

      //APIコール
      var url = 'http://www.ekidata.jp/api/l/' + lineNum.toString() + '.json';
      http.get(url).then((response) {
        var body = response.body.substring(50, response.body.length - 58);
        var mapStation = jsonDecode(body);
        mapStation["station_l"].forEach((i) {
          stationMap[i["station_name"]] = i["station_cd"];
        });
        //lineMap.forEach((key,value) => lineData.add(key));
        stationData = stationMap.keys.toList();
      });
    });
  }
}

/*----------------------------------------------

イベント検索　結果表示クラス

----------------------------------------------*/
class EventSearchResultPage extends StatefulWidget {
  String pref;
  String line;
  String station;

  EventSearchResultPage(this.pref, this.line, this.station);

  @override
  EventSearchResultPageState createState() =>
      new EventSearchResultPageState(this.pref, this.line, this.station);
}

/*----------------------------------------------

イベント検索　結果表示ページ出力（リスト表示）クラス

----------------------------------------------*/
class EventSearchResultPageState extends State<EventSearchResultPage> {
  String pref;
  String line;
  String station;
  final _mainReference = FirebaseDatabase.instance.reference().child("Events");

  EventSearchResultPageState(this.pref, this.line, this.station);

  var formatter =new DateFormat('yyyy年 M月d日(E) HH時mm分'); // 日時を指定したフォーマットで指定するためのフォーマッター
  EventCreate em = new EventCreate();
  List<EventEntity> entries = new List();

  @override
  //初期コールメソッド
  initState() {
    super.initState();
    setState(() {
      //createList();
      if (pref != null && line == null && station == null) {
        _mainReference.child(pref).onChildAdded.listen(_onEntryAdded);
      } else if (pref != null && line != null && station != null) {
        //駅名検索
        _mainReference.child(pref).child(station).onChildAdded.listen(_onEntryAdded);
      } else if(pref == null && line == null && station == null){
        _mainReference.onChildAdded.listen(_onEntryAdded);
      }
    });
  }
  //------------_mainReferenceの子要素の回数呼ばれている所見あり-------------
  //->DBの階層をEventsとEventManagerをまとめることで解消できそう
  _onEntryAdded(Event e) {
    // 3
    setState(() {
      print("$pref,$line,$station");
      Map<dynamic, dynamic> values = e.snapshot.value;
      //都道府県検索
      if (pref != null && line == null && station == null) {
        values.forEach((k, v) {
          entries.add(new EventEntity.fromMap(v));
        });
      }
      //駅名検索
      else if (pref != null && line != null && station != null) {
        entries.add(new EventEntity.fromMap(e.snapshot.value));
      }
      //全件検索
      else if(pref == null && line == null && station == null){
        values.forEach((k, v) {
          v.forEach((k1, v1) {
            entries.add(new EventEntity.fromMap(v1));
          });
        });
      }
      else{

      }
    });
  }

  //画面全体のビルド
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(20.0),
          child: new Column(
            children: <Widget>[
              Text('検索結果：' + entries.length.toString() + '件'),
              Expanded(
                child: ListView.builder(
                  //padding: const EdgeInsets.all(16.0),
                  itemBuilder: (BuildContext context, int index) {
                    return _buildRow(index);
                  },
                  itemCount: entries.length,
                ),
              ),
              Divider(
                height: 8.0,
              ),
//              Container(
//                  decoration: BoxDecoration(color: Theme.of(context).cardColor),
//                  child: _buildInputArea()
//              )
            ],
          )),
    );
  }

  //リスト要素生成
  Widget _buildRow(int index) {
    //リストの要素一つづつにonTapを付加して、詳細ページに飛ばす
    return new GestureDetector(
      onTap: () {
      Navigator.push(
          this.context,
          MaterialPageRoute(
            // パラメータを渡す
              builder: (context) => new EventDetailPage(entries[index])));
      },
      child: new SizedBox(
        child: new Card(
          child: new Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    entries[index].station + "駅",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
                Container(
                  child: Text(
                    entries[index].userId,
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ),
                Container(
                  child: Text(
                    "EventID :" + entries[index].eventId.toString(),
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*----------------------------------------------

イベント作成用クラス

----------------------------------------------*/
class EventCreate {
  var mainReference = FirebaseDatabase.instance.reference().child("Events");
  var managerReference =
      FirebaseDatabase.instance.reference().child("EventManager");
  int eventId;

  //イベント追加メソッド
  void addEvent(String pref, String line,EventEntity event) {
    managerReference.once().then((DataSnapshot snapshot) {
      //print(snapshot.value["eventId"].toString());
      eventId = int.parse(snapshot.value["eventId"]);
      String newEventId = (eventId + 1).toString();
      managerReference.set({"eventId": "$newEventId"});
      event.eventId = newEventId;
      mainReference.child(pref).child(event.station).child(eventId.toString()).set(
          event.toJson());
    });
  }
}


/*----------------------------------------------

イベントの詳細ページ出力クラス(Stateless)

----------------------------------------------*/

class EventDetailPage extends StatelessWidget {
  EventEntity event;
  EventDetailPage(this.event);
  var formatter = new DateFormat(
      'yyyy年 M月d日(E) HH時mm分');

  Widget build(BuildContext context) {
    return Container(
      child:Center(
        child: Column(children: <Widget>[
          //イベント詳細
          Material(
              child: Text("イベントID:" + event.eventId.toString() + "\n"
                  "最寄駅:"+event.station+"\n"
                  "募集人数:" + event.recruitMember + "\n"
                  "開始時刻:" + formatter.format(event.startingTime) + "\n"
                  "終了時刻:" + formatter.format(event.endingTime) + "\n"
                  "備考:" + event.remarks + "\n",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.black,
                    fontSize: 20,
                  )
              )
          ),
          //戻るボタン
          RaisedButton(
            onPressed:(){
              Navigator.pop(context);
            },
            child: Text('戻る'),
          ),
        ]),
      ),
    );
  }
}
