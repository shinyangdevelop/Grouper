import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:grouper/loginPage.dart';
import 'package:grouper/registerPage.dart';

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
    print('welcome');
    return MaterialApp(
      title: 'Grouper',
      initialRoute: '/main',
      routes: {
        '/main': (context) => MainPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
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
  int users = 0;
  List<int> groups = [];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadLoginStatus();
  }

  Future<void> loadGroups() async {
    final response = await supabase
        .from('users')
        .select('joined_groups')
        .eq('id', userId);
    groups = response.data[0]['joined_groups'];
    print(response);
  }

  void loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = (prefs.getBool('loginStatus') ?? false);
      userName = (prefs.getString('userName') ?? '');
      userId = (prefs.getInt('userId') ?? -1);
    });
  }

  Future<void> updateLoginStatus(
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
    print('build begin');
    if (!isLoggedIn) {
      print('redirect to loginPage');
      return LoginPage();
    }
    loadGroups();
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
              print('logout');
              updateLoginStatus(false, null, null);
              Navigator.pushNamed(context, '/login');
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
