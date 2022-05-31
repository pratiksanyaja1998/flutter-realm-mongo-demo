import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';

import 'HomeScreen.dart';
import 'LoginScreen.dart';
import 'config_reader.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await ConfigReader.initialize();

  await RealmApp.init(ConfigReader.appID);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final MongoRealmClient client = MongoRealmClient();
  final RealmApp app = RealmApp();

  @override
  void initState() {
    super.initState();
    // init();
  }

  Future<void> countData() async {
    var collection = client.getDatabase("Demo-database").getCollection("demo-collection");

    try {
      var size = await collection.count();
      print("size=$size");
    } on PlatformException catch (e) {
      print("Error! ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mongo Realm Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
        stream: client.auth.authListener(),
        builder: (context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            // show loading indicator
              return const Scaffold(body: Center(child: CircularProgressIndicator()));

            case ConnectionState.active:
            // log error to console
              if (snapshot.error != null) {
                print("error");
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: "ariel",
                    ),
                  ),
                );
              }
              // redirect to the proper page
              return snapshot.hasData ? HomeScreen() : LoginScreen();

            default:
              return Container();
          }
        },
      ),
    );
  }
}

// enum LoginState { login, register }
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final formKey = GlobalKey<FormState>();
//
//   var _email;
//   var _password;
//
//   var client = MongoRealmClient();
//   var app = RealmApp();
//   var _state = LoginState.login;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Welcome To MongoRealm"),
//       ),
//       body: Center(
//         child: Form(
//           key: formKey,
//           child: _loginForm(),
//         ),
//       ),
//     );
//   }
//
//   Widget _loginForm() {
//     return SingleChildScrollView(
//       child: Container(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Container(
//               width: 300,
//               child: TextFormField(
//                 initialValue: _email,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 autocorrect: false,
//                 validator: (val) => val!.isEmpty ? "Name can't be empty." : null,
//                 onSaved: (val) => _email = val,
//               ),
//             ),
//             SizedBox(height: 12),
//             Container(
//               width: 300,
//               child: TextFormField(
//                 initialValue: _password,
//                 decoration: InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//                 autocorrect: false,
//                 validator: (String? val) {
//                   if (val!.isEmpty) return "Password can't be empty.";
//
//                   if (val.length < 6)
//                     return "Password must be at least 6 charcaters long";
//
//                   return null;
//                 },
//                 onSaved: (val) => _password = val,
//               ),
//             ),
//             SizedBox(height: 36),
//             Container(
//               width: 200,
//               child: RaisedButton(
//                 color: Colors.red,
//                 child: Text((_state == LoginState.login) ? 'Login' : 'Register',
//                     style: TextStyle(color: Colors.white)),
//                 onPressed: _submitForm,
//               ),
//             ),
//             Container(
//               width: 200,
//               child: RaisedButton(
//                 color: Colors.green,
//                 child: Text(
//                     "Go to ${(_state == LoginState.login) ? 'register' : 'login'}",
//                     style: TextStyle(color: Colors.white)),
//                 onPressed: () {
//                   setState(() {
//                     _state = (_state == LoginState.login)
//                         ? LoginState.register
//                         : LoginState.login;
//                   });
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _submitForm() async {
//     print("--Submiit form");
//     final form = formKey.currentState;
//     if (form!.validate()) {
//       form.save();
//
//       //hides keyboard
//       FocusScope.of(context).requestFocus(FocusNode());
//
//       if (_state == LoginState.login) {
//         try {
//
//           CoreRealmUser mongoUser = await app.login(//WithCredential(
//               Credentials.emailPassword(_email, _password)
// //            AnonymousCredential()
//           );
//
//           if(mongoUser == null){
//             bool isUser = await app.registerUser(_email,_password);
//             print("--User Registered successfully");
//             CoreRealmUser mongoUser = await app.login(//WithCredential(
//                 Credentials.emailPassword(_email, _password)
// //            AnonymousCredential()
//             );
//           }
//
//           if (mongoUser != null) {
//             // String userId = mongoUser.id;
// //            Navigator.pushReplacement(
// //                context, MaterialPageRoute(builder: (_) => HomeScreen()));
//
//           print("Welcome back! $mongoUser");
//           Navigator.push(context, MaterialPageRoute(builder: (context) =>  HomeScreen()),);
//
//             // Fluttertoast.showToast(
//             //     msg: "Welcome back!",
//             //     toastLength: Toast.LENGTH_SHORT,
//             //     gravity: ToastGravity.BOTTOM,
//             //     timeInSecForIosWeb: 1);
//           } else {
//             return buildErrorDialog(context, "wrong email or password");
//           }
//         } on Exception catch (e) {
//           bool isUser = await app.registerUser(_email,_password);
//           print("--User Registered successfully");
//           CoreRealmUser mongoUser = await app.login(//WithCredential(
//               Credentials.emailPassword(_email, _password)
// //            AnonymousCredential()
//           );
//           print("--exception accureed! $e");
//         }
//       } else if (_state == LoginState.register) {}
//     }
//   }
// }
//
// Future buildErrorDialog(BuildContext context, _message) {
//   return showDialog(
//     builder: (context) {
//       return AlertDialog(
//         title: Text('Something went wrong...'),
//         content: Text(_message),
//         actions: <Widget>[
//           FlatButton(
//               child: Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               })
//         ],
//       );
//     },
//     context: context,
//   );
// }

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final client = MongoRealmClient();
//   final app = RealmApp();
//   var _students = <Student>[];
//
//   // MongoCollection("Demo-database","demo-collection");
//
//   late MongoCollection _collection;
//
//   final _filterOptions = <String>[
//     "name",
//     "year",
//     "grades",
//   ];
//
//   final _operatorsOptions = <String>[
//     ">",
//     ">=",
//     "<",
//     "<=",
// //    "between"
//   ];
//
//   String? _selectedFilter;
//   String? _selectedOperator;
//
//   //
//   final formKey = GlobalKey<FormState>();
//   late String _newStudFirstName;
//   late String _newStudLastName;
//   late int _newStudYear;
//
//   @override
//   void initState() {
//
//     super.initState();
//
//     _collection = client.getDatabase("Demo-database").getCollection("demo-collection");
//
// //   client.callFunction("sum", args: [3, 4]).then((value) {
// //     print(value);
// //   });
//   }
//
//   @override
//   void didChangeDependencies() async {
//     super.didChangeDependencies();
//
//     _collection = client.getDatabase("Demo-database").getCollection("demo-collection");
//     try {
//       await _fetchStudents();
//     } catch (e) {
//       print("------------------------object-- $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     List<Widget> list = _students.map((s) => StudentItem(s)).toList();
//     return SafeArea(
//       top: false,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("Home Screen"),
//           actions: <Widget>[
//             FlatButton(
//               child: Icon(Icons.refresh, color: Colors.white),
//               onPressed: _fetchStudents,
//             ),
//             FlatButton(
//               child: Icon(Icons.exit_to_app, color: Colors.white),
//               onPressed: () async {
//                 try {
//                   // if (!kIsWeb) {
//                   //   final FacebookLogin fbLogin = FacebookLogin();
//                   //
//                   //   bool loggedAsFacebook = await fbLogin.isLoggedIn;
//                   //   if (loggedAsFacebook) {
//                   //     await fbLogin.logOut();
//                   //   }
//                   // }
//                 } catch (e) {}
//
//                 await app.logout();
//               },
//             )
//           ],
//         ),
//         body: Container(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             children: <Widget>[
//               _filterRow(),
//               SizedBox(height: 20),
//               _header(),
//               if(list.isNotEmpty)
//                 Expanded(child: ListView.builder(
//                   itemBuilder: (context, index) => list[index],
//                   itemCount: list.length,
//                 )),
//             ],
//           ),
//         ),
//         bottomSheet: Container(
//           margin: const EdgeInsets.only(bottom: 4),
//           child: Form(
//             key: formKey,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 Expanded(
//                   flex: 3,
//                   child: TextFormField(
//                     decoration: InputDecoration(labelText: 'First Name'),
//                     autocorrect: false,
//                     validator: (val) => val!.isEmpty ? "can't be empty." : null,
//                     onSaved: (val) => _newStudFirstName = val!,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   flex: 3,
//                   child: TextFormField(
//                     decoration: InputDecoration(labelText: 'Last Name'),
//                     autocorrect: false,
//                     validator: (val) => val!.isEmpty ? "can't be empty." : null,
//                     onSaved: (val) => _newStudLastName = val!,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   flex: 1,
//                   child: TextFormField(
//                     decoration: InputDecoration(labelText: 'Year'),
//                     autocorrect: false,
//                     validator: (val) => val!.isEmpty ? "can't be empty." : null,
//                     onSaved: (val) => _newStudYear = int.parse(val!),
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   flex: 2,
//                   child: RaisedButton(
//                       child: Text("Add"), onPressed: _insertNewStudent),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _header() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Expanded(
//               flex: 2,
//               child: Text(
//                 "Name",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               )),
//           Expanded(
//               flex: 1,
//               child:
//               Text("Year", style: TextStyle(fontWeight: FontWeight.bold))),
//           Expanded(
//               flex: 1,
//               child: Text("Grades Avg.",
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//         ],
//       ),
//     );
//   }
//
//   _filterRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         DropdownButton(
//           value: _selectedFilter,
//           items: _filterOptions
//               .map((name) => DropdownMenuItem<String>(
//             value: name,
//             child: Text(name),
//           ))
//               .toList(),
//           onChanged: (value) {
//             setState(() {
//               _selectedFilter = value as String?;
//             });
//           },
//         ),
//         SizedBox(width: 20),
//         DropdownButton(
//           value: _selectedOperator,
//           items: _operatorsOptions
//               .map((name) => DropdownMenuItem<String>(
//             value: name,
//             child: Text(name),
//           ))
//               .toList(),
//           onChanged: (value) {
//             setState(() {
//               _selectedOperator = value as String?;
//             });
//           },
//         ),
//         SizedBox(width: 20),
//         Container(
//           width: 100,
//           child: TextField(
//             maxLines: 1,
//           ),
//         ),
//         SizedBox(width: 20),
//         Expanded(
//           flex: 1,
//           child: RaisedButton(
//             child: Text("Filter"),
//             onPressed: () {
//               // todo: implemnt this
//             },
//           ),
//         )
//       ],
//     );
//   }
//
//   /// Functions ///
//   _fetchStudents() async {
//
//     var user = await app.currentUser;
//
//     print("- - - - - - - -"+user.profile.toString());
//
//     print("-----------------------Fetch Students-------------------------");
//     List documents = await _collection.find(
// //      projection: {
// //        "field": ProjectionValue.INCLUDE,
// //      }
//     );
//     print("=-=-=-=="+documents.toString());
//     _students.clear();
//     documents.forEach((document) {
//       print("=-=-=-=="+document.toString());
//       _students.add(Student.fromDocument(document));
//     });
//     setState(() {});
//   }
//
//   _insertNewStudent() async {
//     var form = formKey.currentState;
//
//     if (form!.validate()) {
//       form.save();
//
//       var newStudent = Student(
//         firstName: _newStudFirstName,
//         lastName: _newStudLastName,
//         year: _newStudYear,
//         grades: [100]
//       );
//       // var id = await _collection.insertOne(newStudent.asDocument());
//       // print("inserted_id=$id");
//
//       print("document--- ${newStudent.asDocument().toJson().toString()}");
//
//       var docsIds = await _collection.insertMany([
//         newStudent.asDocument(),
//         newStudent.asDocument()
//       ]);
//
//       for(var id in docsIds.values){
//         print("inserted_id=$id");
//       }
//
//       setState(() {
//         form.reset();
//       });
//     }
//   }
// }
//
// class StudentItem extends StatelessWidget {
//   final Student student;
//
//   StudentItem(this.student);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Expanded(
//             flex: 2,
//             child: Text(
//               "${student.firstName} ${student.lastName}",
//               style: TextStyle(fontSize: 20),
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Text(
//               "${student.year}",
//               style: TextStyle(fontSize: 18),
//             ),
//           ),
//           Expanded(
//               flex: 1,
//               child: Text(
//                   [student.gradesAvg].toString(),
//                 style: TextStyle(fontSize: 18),
//               )),
//         ],
//       ),
//     );
//   }
// }
//
// class Student {
//   final String? firstName;
//   final String? lastName;
//   final int? year;
//   List<int>? grades = [1,2];
//
//   Student({this.lastName, this.firstName, this.grades, this.year});
//
//   double get gradesAvg {
//     var sum = 0;
//     grades?.forEach((grade) {
//       sum += grade;
//     });
//     return grades == null || grades!.isEmpty ? 0 : sum / grades!.length;
//   }
//
//   static fromDocument(MongoDocument document) {
//     print("----${document.toJson().toString()}");
//     return Student(
//         firstName: document.get("user_name") ?? "",
//         lastName: document.get("lastName") ?? "",
//         grades: (document.get("grades") == null
//             ? <int>[]
//             : (document.get("grades") as List)
//             .map((e) => int.parse("$e"))
//             .toList()),
//         year: document.get("year") ?? 1);
//   }
//
//   MongoDocument asDocument() {
//     return MongoDocument({
//       "firstName": this.firstName,
//       "lastName": this.lastName,
//       "grades": this.grades ?? [],
//       "year": this.year,
//     });
//   }
// }
