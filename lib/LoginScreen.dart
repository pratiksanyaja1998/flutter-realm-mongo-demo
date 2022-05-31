import 'package:flutter/material.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';

import 'HomeScreen.dart';

enum LoginState { login, register }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  var _email;
  var _password;

  var client = MongoRealmClient();
  var app = RealmApp();
  var _state = LoginState.login;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Welcome To MongoRealm"),
        ),
        body: Center(
          child: Form(
            key: formKey,
            child: _loginForm(),
          ),
        ),
      ),
    );
  }

  Widget _loginForm() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              child: TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email'),
                autocorrect: false,
                validator: (val) => val!.isEmpty ? "Name can't be empty." : null,
                onSaved: (val) => _email = val,
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: 300,
              child: TextFormField(
                initialValue: _password,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                autocorrect: false,
                validator: (String? val) {
                  if (val!.isEmpty) return "Password can't be empty.";

                  if (val.length < 6)
                    return "Password must be at least 6 charcaters long";

                  return null;
                },
                onSaved: (val) => _password = val,
              ),
            ),
            SizedBox(height: 36),
            Container(
              width: 200,
              child: RaisedButton(
                color: Colors.red,
                onPressed: _submitForm,
                child: const Text('Login',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            Container(
              width: 200,
              child: RaisedButton(
                color: Colors.green,
                child: const Text(
                    "register",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  setState(() {
                    _state = LoginState.register;
                    _submitForm();
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    print("--Submiit form");
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();

      //hides keyboard
      FocusScope.of(context).requestFocus(FocusNode());

      if (_state == LoginState.login) {
        try {
          CoreRealmUser mongoUser = await app.login(//WithCredential(
              Credentials.emailPassword(_email, _password)
//            AnonymousCredential()
          );
          if (mongoUser != null) {
            // String userId = mongoUser.id;
            print("---------Welcome back! $mongoUser");
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  HomeScreen()),);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("wrong email or password"),
            ));
            return buildErrorDialog(context, "wrong email or password");
          }
        } on Exception catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("wrong email or password"),
          ));
          print("--exception accureed! $e");
          return buildErrorDialog(context, "wrong email or password");
        }
      } else if (_state == LoginState.register) {
        try{
          bool isUser = await app.registerUser(_email,_password);
        }on Exception catch (e){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("email already registered"),
          ));
          print("--exception accureed! $e");
          _state = LoginState.login;
          return buildErrorDialog(context, "email already registered");
        }

    _state = LoginState.login;
      }
    }
  }
}

Future buildErrorDialog(BuildContext context, _message) {
  return showDialog(
    builder: (context) {
      return AlertDialog(
        title: Text('Something went wrong...'),
        content: Text(_message),
        actions: <Widget>[
          FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
      );
    },
    context: context,
  );
}