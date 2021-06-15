import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_firebase/welcome_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({Key? key}) : super(key: key);

  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isloggedin = false;

  //Check if the user is already logged in. If so, redirect to todo display page
  checkAuthentification() async {
    //onAuthStateChanged was used for previous version instead of authStateChanges()
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(),
          ),
        );
      }
    });
  }

  getUser() async {
    //TODO: Checkout UserCredential and User
    User? firebaseUser = await _auth.currentUser;
    await firebaseUser?.reload();
    firebaseUser = await _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isloggedin = true;
      });
    }
  }

  createTodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('MyTodos').doc(input);

    //MAPPING
    Map<String, String> todos = {'todosTitle': input};
    documentReference.set(todos).whenComplete(() => print('$input created'));
  }

  deleteTodos() {}

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();
  }

  signOut() async {
    _auth.signOut();
  }

  List todos = [];
  String input = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Todo Lists'),
      ),
      drawer: Drawer(
        elevation: 40.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40.0,
                            //child: Image.asset(''),
                            backgroundColor: Colors.red,
                          ),
                          Spacer(),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 35.0,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      'Welcome ${user?.displayName} you are logged in as ${user?.email}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(55.0),
                    child: ElevatedButton(
                      onPressed: signOut,
                      child: Text(
                        'SIGN OUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.lightGreen,
                        ),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 30,
                          ),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('todo').snapshots(),
        builder: (context, AsyncSnapshot snapshots) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshots.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot = snapshots.data.docs[index];
              return Dismissible(
                key: Key(index.toString()),
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(documentSnapshot[index]),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          todos.removeAt(index);
                        });
                      },
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  title: Text('Add TodoList'),
                  content: TextField(
                    onChanged: (String value) {
                      input = value;
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        // ignore: unnecessary_statements
                        createTodos;
                        Navigator.pop(context);
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              });
        },
        backgroundColor: Colors.lightGreen,
        splashColor: Colors.red,
        child: Icon(
          Icons.add,
          size: 40.0,
        ),
      ),
    );
  }
}

// SafeArea(
// child: SingleChildScrollView(
// child: Container(
// child: Center(
// child: !isloggedin
// ? CircularProgressIndicator()
//     : Column(
// children: <Widget>[
// ListView.builder(
// itemCount: todos.length,
// itemBuilder: (BuildContext context, int index) {
// return Dismissible(
// key: (Key(todos[index])),
// child: Card(
// child: ListTile(
// title: Text(todos[index]),
// ),
// ),
// );
// },
// ),
// ],
// ),
// ),
// ),
// ),
// ),

// ListView.builder(
// itemCount: todos.length,
// itemBuilder: (BuildContext context, int index) {
// return Dismissible(
// key: (Key(todos[index])),
// child: Card(
// elevation: 4,
// margin: EdgeInsets.all(8),
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(16),
// ),
// child: ListTile(
// title: Text(todos[index]),
// trailing: IconButton(
// onPressed: () {
// setState(() {
// todos.removeAt(index);
// });
// },
// icon: Icon(Icons.delete),
// color: Colors.red,
// ),
// ),
// ),
// );
// },
// ),

//AsyncSnapshot
