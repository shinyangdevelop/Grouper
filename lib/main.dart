import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:grouper/login_page.dart';
import 'package:grouper/register_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: '/config/.ENV');
  await Supabase.initialize(
      url: dotenv.env['URL']!, anonKey: dotenv.env['Key']!);

  runApp(Grouper());
}

class Group {
  final String groupName;
  final String groupCode;
  final int groupId;

  Group(this.groupId, this.groupName, this.groupCode);

  @override
  String toString() {
    return 'Group: $groupName, $groupCode, $groupId';
  }
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
  List<Group> groups = [];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadLoginStatus();
  }

  Future<List<Group>> loadGroups() async {
    List<Group> temp = [];
    final response = await supabase
        .from('user_group_link')
        .select('groupid, groups(group_name, group_code)')
        .eq('userid', userId);
    for (var i in response) {
      temp.add(Group(
          i['groupid'], i['groups']['group_name'], i['groups']['group_code']));
    }
    print(temp);
    groups = temp;
    return temp;
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FutureBuilder<List<Group>>(
                future: loadGroups(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            print('tapped');
                            Navigator.pushNamed(context, '/group',
                                arguments: groups[index]);
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(25, 15, 25, 15),
                            padding: EdgeInsets.fromLTRB(10, 25, 25, 10),
                            color: Colors.grey[900],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    groups[index].groupName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(flex: 5, child: Container()),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'Group code: ${groups[index].groupCode}',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                            ));
                      });
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const SpinKitWave(
                  color: Colors.white,
                  size: 50.0,
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
