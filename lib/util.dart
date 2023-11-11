import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class User {
  final String userName;
  final int userId;
  User(this.userId, this.userName);

  @override
  String toString() {
    return 'User: $userName, $userId';
  }
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

class Util {
  static Future<User> loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = (prefs.getString('userName') ?? '');
    final userId = (prefs.getInt('userId') ?? -1);
    return User(userId, userName);
  }
  static Future<void> updateLoginStatus(isLoggedIn, userId, userName) async {
    final prefs = await SharedPreferences.getInstance();
    if (isLoggedIn) {
      prefs.setBool('loginStatus', true);
      prefs.setInt('userId', userId);
      prefs.setString('userName', userName);
    } else {
      prefs.setBool('loginStatus', false);
      prefs.remove('userId');
      prefs.remove('userName');
    }
  }

  static Future<List<Group>> loadGroups(userId) async {
    final supabase = Supabase.instance.client;
    List<Group> temp = [];
    final response = await supabase
        .from('user_group_link')
        .select('groupid, groups(group_name, group_code)')
        .eq('userid', userId);
    print(response);
    for (var i in response) {
      temp.add(Group(
          i['groupid'], i['groups']['group_name'], i['groups']['group_code']));
    }
    return temp;
  }

  static Future<Map<String, dynamic>> checkLoginData(
      String email, String password) async {
    final supabase = Supabase.instance.client;
    final data = await supabase
        .from('users')
        .select('id,password,name')
        .eq('email', email);
    try {
      if (data.length == 0) {
        return {'success': false};
      } else {
        if (data[0]['password'] == password) {
          return {
            'success': true,
            'userId': data[0]['id'],
            'name': data[0]['name']
          };
        } else {
          return {'success': false};
        }
      }
    } catch (e) {
      print(e.toString());
      return {'success': false};
    }
  }
}