import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:grouper/loginPage.dart';

Future<void> main() async {
  await dotenv.load(fileName: '/config/.ENV');
  await Supabase.initialize(
      url: dotenv.env['URL']!, anonKey: dotenv.env['Key']!);

  runApp(Grouper());
}

class Grouper extends StatelessWidget {
  const Grouper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grouper',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isLoggedIn = false;
  String userName = '';
  int userId = -1;

  @override
  void initState() {
    super.initState();
    loadAppStatus();
  }

  Future<void> loadAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = (prefs.getBool('loginStatus') ?? false);
      userName = (prefs.getString('userName') ?? '');
      userId = (prefs.getInt('userId') ?? -1);
    });
  }

  Future<void> updateAppStatus(
      bool loginStatus, int? userId_, String? userName_) async {
    final prefs = await SharedPreferences.getInstance();
    if (loginStatus) {
      setState(() {
        userName = userName_!;
        isLoggedIn = true;
        userId = userId_!;
        prefs.setBool('loginStatus', true);
        prefs.setInt('userId', userId_);
        prefs.setString('userName', userName_);
      });
    } else {
      userName = '';
      isLoggedIn = false;
      userId = -1;
      prefs.setBool('loginStatus', false);
      prefs.remove('userId');
      prefs.remove('userName');
    }
  }

  @override
  Widget build(BuildContext context) {
    loadAppStatus();
    if (!isLoggedIn) {
      return LoginPage();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Grouper'),
        centerTitle: true,
        elevation: 0.0,
        leadingWidth: 200,
        leading: FractionallySizedBox(
          heightFactor: 0.5,
          widthFactor: 4,
          child: Text(
            userName,
            textAlign: TextAlign.center,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              updateAppStatus(false, null, null);
            },
          ),
        ],
      ),
      body: Align(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: 100,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 50,
                        margin: EdgeInsets.fromLTRB(25, 15, 25, 15),
                        color: Colors.grey[900],
                        child: Center(child: Text('Entry ${index + 1}')),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
