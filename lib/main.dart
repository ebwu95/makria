import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(ZoomAFK());
}

String name = "";

class ZoomAFK extends StatelessWidget {
  ZoomAFK({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      theme: ThemeData(
        fontFamily: 'VarelaRound',
        primarySwatch: Colors.blue,
      ),
      home: const FirstPage(title: 'Welcome'),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      */
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Image(
              image: AssetImage('assets/Makria-removebg-preview.png'),
            ),
          ),
          Container(
              child: TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const SecondPage(title: "Enter Your Details");
              }));
            },
            child: const Text("Start"),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              primary: Colors.black,
              side: BorderSide(color: Colors.black),
              minimumSize: Size(120, 80),
            ),
          )),
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      */
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Enter Your First Name',
            style: TextStyle(
              fontSize: 50.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Colors.black,
            ),
          ),
          Center(
            child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'You Must Enter Your First Name',
                          hintText: 'Enter Your First Name',
                        ),
                        onChanged: (String text) {
                          name = text;
                          print('Your First Name is $name');
                        },
                      ),
                    ),
                  ],
                )),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const MyApp();
                    }));
                  },
                  child: const Text("Become Makria"),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    primary: Colors.black,
                    side: BorderSide(color: Colors.black),
                    minimumSize: Size(120, 80),
                  ),
                ),
              ],
            ),
            /*child: TextButton(
              onPressed: () {},
              child: const Text("Go to Afk Page"),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                primary: Colors.black,
                side: BorderSide(color: Colors.black),
                minimumSize: Size(120, 80),
              ),
            )*/
          ),
        ],
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Align(
          alignment: Alignment.bottomCenter,
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Go to back to second page"))),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(title: 'Makria'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imageLink = 'assets/off_button.png';
  String buttonText =
      'Makria is currently enabled. Click on the VPN button to turn it on';
  int status = 0; //0 = off, 1 = on, 2 = on and alert

  void _onButtonPressed(String value) {
    setState(() {
      imageLink = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        title: Text(widget.title),
      ),
      */
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: Text(
                '$buttonText',
                style: TextStyle(
                  fontSize: 20.0,
                  letterSpacing: 1.0,
                  color: Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: Image.asset(imageLink),
              iconSize: 500,
              onPressed: () {
                if (status == 0) {
                  _onButtonPressed('assets/on_button.png');
                  buttonText =
                      'Makria is currently enabled. Click on the VPN button to turn it on';
                  status = 1;
                } else if (status == 1) {
                  _onButtonPressed('assets/off_button.png');
                  buttonText =
                      'Makria is currently disabled and will alert you if your name is detected.';
                  status = 0;
                }
              },
            ),
            FloatingActionButton(
              onPressed: () {
                if (status == 1) {
                  Future.delayed(const Duration(seconds: 13), () {
                    _onButtonPressed('assets/on_button.png');
                    status = 1;
                  });
                } else
                  null;
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                primary: Colors.black,
                side: BorderSide(color: Colors.black),
                minimumSize: Size(120, 80),
              ),
              child: const Text(
                'Rename',
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const SecondPage(title: "Enter Your Details");
                }));
              },
            ),
          ],
        ),
      ),
    );
  }
}
