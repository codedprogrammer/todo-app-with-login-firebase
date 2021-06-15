import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_firebase/page/notes_page.dart';
import 'package:todo_firebase/todo_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //To get the form values of the user
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _email, _password;

  //Check if the user is already logged in. If so, redirect to the homepage
  checkAuthentification() async {
    //onAuthStateChanged was used for previous version instead of authStateChanges()
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotesPage(),
          ),
        );
      }
    });
    @override
    void initState() {
      super.initState();
      this.checkAuthentification();
    }
  }

  //When user enters an email and a valid password, validate the current form state
  login() async {
    if (_formKey.currentState!.validate()) {
      //Save the current state of the form/Save the credential of the user(EMAIL & PASSWORD)
      _formKey.currentState!.save();
      try {
        //TODO: Checkout UserCredential and User
        UserCredential user = await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('ERROR'),
              content: Text(e.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  // showError(String errormessage) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('ERROR'),
  //           content: Text(errormessage),
  //         );
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 30.0,
                    horizontal: 20.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            'assets/images/todoImage1.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          child: TextFormField(
                            validator: (input) {
                              if (input!.isEmpty)
                                return 'Enter an Email Address';
                            },
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onSaved: (input) => _email = input!,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Container(
                          child: TextFormField(
                            validator: (input) {
                              if (input!.length < 6)
                                return 'Provide a minimum of 6 characters';
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            obscureText: true,
                            onSaved: (input) => _password = input!,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        ElevatedButton(
                          onPressed: login,
                          child: Text(
                            'LOGIN',
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
                      ],
                    ),
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
