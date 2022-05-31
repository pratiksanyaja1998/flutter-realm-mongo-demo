
import 'package:flutter/material.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';
import 'package:mongo_realm_demo/LoginScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final client = MongoRealmClient();
  final app = RealmApp();
  String? ref;
  var _students = <Student>[];

  // MongoCollection("Demo-database","demo-collection");

  late MongoCollection _collection;

  final _filterOptions = <String>[
    "name",
    "year",
    "grades",
  ];

  final _operatorsOptions = <String>[
    ">",
    ">=",
    "<",
    "<=",
//    "between"
  ];

  String? _selectedFilter;
  String? _selectedOperator;

  //
  final formKey = GlobalKey<FormState>();
  late String _newStudFirstName;
  late String _newStudLastName;
  late int _newStudYear;

  @override
  void initState() {
    super.initState();
    _collection = client.getDatabase("Demo-database").getCollection("demo-collection");

//   client.callFunction("sum", args: [3, 4]).then((value) {
//     print(value);
//   });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    _collection = client.getDatabase("Demo-database").getCollection("demo-collection");
    try {
      await _fetchStudents();
    } catch (e) {
      print("------------------------object-- $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> list = _students.map((s) => StudentItem(s)).toList();
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Home Screen"),
            actions: <Widget>[
              FlatButton(
                child: Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchStudents,
              ),
              FlatButton(
                child: Icon(Icons.exit_to_app, color: Colors.white),
                onPressed: () async {
                  // try {
                  //   // if (!kIsWeb) {
                  //   //   final FacebookLogin fbLogin = FacebookLogin();
                  //   //
                  //   //   bool loggedAsFacebook = await fbLogin.isLoggedIn;
                  //   //   if (loggedAsFacebook) {
                  //   //     await fbLogin.logOut();
                  //   //   }
                  //   // }
                  // } catch (e) {}

                  await app.logout();
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  LoginScreen()),);
                },
              )
            ],
          ),
          body: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                _filterRow(),
                SizedBox(height: 20),
                _header(),
                if(list.isNotEmpty)
                  Expanded(child: ListView.builder(
                    itemBuilder: (context, index) => list[index],
                    itemCount: list.length,
                  )),
              ],
            ),
          ),
          bottomSheet: Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: Form(
              key: formKey,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'First Name'),
                      autocorrect: false,
                      validator: (val) => val!.isEmpty ? "can't be empty." : null,
                      onSaved: (val) => _newStudFirstName = val!,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Last Name'),
                      autocorrect: false,
                      validator: (val) => val!.isEmpty ? "can't be empty." : null,
                      onSaved: (val) => _newStudLastName = val!,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Year'),
                      autocorrect: false,
                      validator: (val) => val!.isEmpty ? "can't be empty." : null,
                      onSaved: (val) => _newStudYear = int.parse(val!),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: RaisedButton(
                        child: Text("Add"), onPressed: _insertNewStudent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Expanded(
              flex: 2,
              child: Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          Expanded(
              flex: 1,
              child:
              Text("Year", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text("Grades Avg.",
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  _filterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DropdownButton(
          value: _selectedFilter,
          items: _filterOptions
              .map((name) => DropdownMenuItem<String>(
            value: name,
            child: Text(name),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedFilter = value as String?;
            });
          },
        ),
        SizedBox(width: 20),
        DropdownButton(
          value: _selectedOperator,
          items: _operatorsOptions
              .map((name) => DropdownMenuItem<String>(
            value: name,
            child: Text(name),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedOperator = value as String?;
            });
          },
        ),
        SizedBox(width: 20),
        Container(
          width: 100,
          child: TextField(
            maxLines: 1,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: RaisedButton(
            child: Text("Filter"),
            onPressed: () {
              // todo: implemnt this
            },
          ),
        )
      ],
    );
  }

  /// Functions ///
  _fetchStudents() async {

    var user = await app.currentUser;

    ref = user.id;

    print("- - - - - - - -"+user.profile.toString());

    print("-----------------------Fetch Students-------------------------");
    List documents = await _collection.find(
      filter: {
        "ref": ref,
      },
//      projection: {
//        "field": ProjectionValue.INCLUDE,
//      }
    );
    print("=-=-=-=="+documents.toString());
    _students.clear();
    documents.forEach((document) {
      print("=-=-=-=="+document.toString());
      _students.add(Student.fromDocument(document));
    });
    setState(() {});
  }

  _insertNewStudent() async {
    var form = formKey.currentState;

    if (form!.validate()) {
      form.save();

      var newStudent = Student(
          ref: ref,
          firstName: _newStudFirstName,
          lastName: _newStudLastName,
          year: _newStudYear,
          grades: [100]
      );
      // var id = await _collection.insertOne(newStudent.asDocument());
      // print("inserted_id=$id");

      print("document--- ${newStudent.asDocument().toJson().toString()}");

      var docsIds = await _collection.insertOne(
        newStudent.asDocument()
      );

      // for(var id in docsIds){
        print("inserted_id=$docsIds");
      // }

      setState(() {
        form.reset();
      });
    }
  }
}

class StudentItem extends StatelessWidget {
  final Student student;

  StudentItem(this.student);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              "${student.firstName} ${student.lastName}",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "${student.year}",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
              flex: 1,
              child: Text(
                [student.gradesAvg].toString(),
                style: TextStyle(fontSize: 18),
              )),
        ],
      ),
    );
  }
}

class Student {
  final String? ref;
  final String? firstName;
  final String? lastName;
  final int? year;
  List<int>? grades = [1,2];

  Student({this.ref, this.lastName, this.firstName, this.grades, this.year});

  double get gradesAvg {
    var sum = 0;
    grades?.forEach((grade) {
      sum += grade;
    });
    return grades == null || grades!.isEmpty ? 0 : sum / grades!.length;
  }

  static fromDocument(MongoDocument document) {
    print("----${document.toJson().toString()}");
    return Student(
        ref: document.get("ref") ?? "",
        firstName: document.get("user_name") ?? "",
        lastName: document.get("lastName") ?? "",
        grades: (document.get("grades") == null
            ? <int>[]
            : (document.get("grades") as List)
            .map((e) => int.parse("$e"))
            .toList()),
        year: document.get("year") ?? 1);
  }

  MongoDocument asDocument() {
    return MongoDocument({
      "ref": this.ref,
      "firstName": this.firstName,
      "lastName": this.lastName,
      "grades": this.grades ?? [],
      "year": this.year,
    });
  }
}