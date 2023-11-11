import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grouper/util.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({Key? key}) : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  bool isLoggedIn = false;
  String userName = '';
  int userId = -1;
  int users = 0;
  List<Group> groups = [];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    Util.loadLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as Map;
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
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: Text(args['groupCode']));
  }
}
