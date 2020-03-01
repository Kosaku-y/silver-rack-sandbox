import 'dart:async';
import 'package:flutter_app2/Entity/User.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_app2/Repository/LoginRepository.dart';

class LoginBloc {
  //final _currentTempUserController = PublishSubject<TempUser>();
  final _currentTempUserController = BehaviorSubject<User>.seeded(null);
  //loginPage側で現在のTmpUserを流す用のStream
  final _googleLoginController = StreamController();
  //loginRepositoryからGoogleログイン受け取るためのStream
  final _stateController = StreamController();

  final loginRepository = LoginRepository();

  LoginBloc() {
    //現在のステータス確認,毎回コールされる
    _stateController.stream.listen((onData) async {
      try {
        var currentUser = await loginRepository.isSignedIn();
        if (currentUser != null) {
          var user = await loginRepository.checkFireBaseLogin(currentUser);
          _currentTempUserController.add(user);
          print("firebaseログイン完了:bloc");
        } else {
          print("firebaseログイン失敗:bloc");
        }
      } catch (_) {}
    });

    //Googleログインが必要な時にコールされる
    _googleLoginController.stream.listen((onData) async {
      try {
        var fireBaseUser = await loginRepository.signInWithGoogle();
        if (fireBaseUser != null) {
          var user = await loginRepository.checkFireBaseLogin(fireBaseUser);
          _currentTempUserController.add(user);
          print("googleログイン完了:bloc");
        } else {
          print("googleログイン失敗:bloc");
        }
      } catch (_) {}
    });
  }

  Sink get googleLoginSink => _googleLoginController.sink;
  Sink get stateSink => _stateController.sink;

  ValueObservable<User> get currentTempUserStream => _currentTempUserController.stream;
  Stream get googleLoginStream => _googleLoginController.stream;

  void dispose() {
    _stateController.close();
    _googleLoginController.close();
    _currentTempUserController.close();
  }
}
