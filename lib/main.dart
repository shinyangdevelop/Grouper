import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grouper/join_create_group.dart';
import 'package:grouper/util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:grouper/login_page.dart';
import 'package:grouper/register_page.dart';
import 'package:grouper/group_page.dart';

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
        '/group': (context) => GroupPage(),
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
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    Util.loadLoginStatus().then((value) => {
          isLoggedIn = value.userId != -1,
          userName = value.userName,
          userId = value.userId,
        });
  }

  Future<Map<String, dynamic>> getFutureData() async {
    Map<String, dynamic> data = {};
    final user = await Util.loadLoginStatus();
    data['isLoggedIn'] = user.userId != -1;
    data['user'] = user;
    data['groups'] = await Util.loadGroups(user.userId);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    print('build begin');
    print('isLoggedIn: $isLoggedIn, userId: $userId, userName: $userName');
    return FutureBuilder(
      future: getFutureData(),
      builder: (context, snapshot) {
        List<Group> groups = snapshot.data?['groups'];
        if (snapshot.hasData && snapshot.data != null) {
          print("groups: ${groups.length}");
          if (snapshot.data!['isLoggedIn']) {
            dynamic groupWidget = Container();
            if (snapshot.data!['groups'] == null) {
              groupWidget = SpinKitWave(
                color: Colors.white,
                size: 50.0,
              );
            } else if (snapshot.data!['groups'].length == 0) {
              groupWidget = SpinKitPianoWave(
                color: Colors.white,
                size: 50.0,
              );
            } else {
              print('a');
              groupWidget = ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!['groups'].length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {
                          print('tapped');
                          Navigator.pushNamed(context, '/group', arguments: {
                            'groupCode':
                                snapshot.data!['groups'][index].groupCode
                          });
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
                      print('logout');
                      await Util.updateLoginStatus(false, null, null);
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 800,
                        child: SingleChildScrollView(
                          child: groupWidget,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final result = await JoinCreateGroup
                                          .showCreateGroupDialog(context);
                                      if (!mounted) return;
                                      if (result) {
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(SnackBar(
                                              content: Text('Group created')));
                                      }
                                    },
                                    child: Text('Join Group'),
                                  )),
                              Expanded(
                                flex: 1,
                                child: Placeholder(),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      JoinCreateGroup.showCreateGroupDialog(
                                          context);
                                      if (!mounted) return;
                                    },
                                    child: Text('Create Group'),
                                  )),
                            ]),
                      ),
                    ],
                  )),
                ],
              ),
            );
          } else {
            return LoginPage();
          }
        } else {
          return Scaffold(
            body: Center(
              child: SpinKitWave(
                color: Colors.white,
                size: 50.0,
              ),
            ),
          );
        }
      },
    );
  }
}
