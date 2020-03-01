import 'package:flutter/material.dart';
import 'package:flutter_app2/Entity/EventDetail.dart';
import 'package:flutter_app2/Entity/PageParts.dart';
import 'package:flutter_app2/Entity/User.dart';
import 'package:intl/intl.dart';

import 'ProfilePage.dart';
import 'TalkPage.dart';
import 'package:flutter/gestures.dart';

/*----------------------------------------------

イベントの詳細ページ出力クラス(Stateless)

----------------------------------------------*/

class EventSearchResultDetailPage extends StatelessWidget {
  EventDetail event;
  User user;
  EventSearchResultDetailPage({Key key, this.user, this.event}) : super(key: key);
  PageParts set = new PageParts();
  var formatter = new DateFormat('yyyy年 M月d日(E) HH時mm分');

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        backgroundColor: set.baseColor,
        title: Text('イベント詳細',
            style: TextStyle(
              color: set.pointColor,
            )),
      ),
      backgroundColor: set.backGroundColor,
      body: Container(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[
            //イベント詳細
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("募集人数：${event.recruitMember}",
                      style: TextStyle(color: set.pointColor, fontSize: 18)),
                  Text("駅　　　：${event.station}",
                      style: TextStyle(color: set.pointColor, fontSize: 18)),
                  Text("開始時間：${event.startingTime}",
                      style: TextStyle(color: set.pointColor, fontSize: 17)),
                  Text("終了時間：${event.endingTime}",
                      style: TextStyle(color: set.pointColor, fontSize: 17)),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(text: "主催者：", style: TextStyle(color: set.pointColor, fontSize: 18)),
                      TextSpan(
                          text: event.userName,
                          style: TextStyle(color: set.fontColor, fontSize: 17),
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).push<Widget>(
                                MaterialPageRoute(
                                  settings: const RouteSettings(name: "/Profile"),
                                  builder: (context) =>
                                      new ProfilePage(user: user, userId: event.userId),
                                ),
                              );
                            }),
                    ]),
                  ),
                  Text("コメント：${event.comment}",
                      style: TextStyle(color: set.pointColor, fontSize: 18)),
                  _actionWidget(context),
                ],
              ),
            ),

            //戻るボタン
            set.backButton(
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionWidget(BuildContext context) {
    if (event.userId == user.userId) {
      return Container(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            Center(
              child: set.iconButton(message: "削除", icon: Icons.delete, onPressed: null),
            ),
            Center(
              child: set.iconButton(message: "修正", icon: Icons.check, onPressed: null),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: set.iconButton(
              message: "メッセージを送る",
              icon: Icons.mail,
              onPressed: () {
                Navigator.of(context).push<Widget>(MaterialPageRoute(
                    settings: const RouteSettings(name: "/Talk"),
                    builder: (context) => new TalkPage(user: user, opponentId: event.userId)));
              }),
        ),
      );
    }
  }
}
