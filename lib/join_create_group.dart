import 'package:flutter/material.dart';
import 'package:grouper/util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JoinCreateGroup {
  static Future<bool> showCreateGroupDialog(BuildContext context) async {
    var result = false;
    final supabase = Supabase.instance.client;
    showDialog(
        context: context,
        builder: (context) {
          final groupNameController = TextEditingController();
          final groupCodeController = TextEditingController();
          return AlertDialog(
            title: Text('Create Group'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: groupNameController,
                  decoration: InputDecoration(hintText: 'Group Name'),
                ),
                TextField(
                  controller: groupCodeController,
                  decoration: InputDecoration(hintText: 'Group Code'),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    if (groupNameController.text.isEmpty ||
                        groupCodeController.text.isEmpty) {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                            SnackBar(content: Text('Please fill all fields')));
                      return;
                    }
                    final value = await supabase.from('groups').insert([
                      {
                        'group_name': groupNameController.text,
                        'group_code': groupCodeController.text
                      }
                    ]);
                    print(value);
                    final user = await Util.loadLoginStatus();
                    await supabase.from('user_group_link').insert([
                      {
                        'userid': user.userId,
                        'groupid': value.data['groupId'],
                      }
                    ]);
                    result = true;
                    Navigator.pop(context);
                  },
                  child: Text('Create')),
              TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red[800],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                      'Cancel'),
              ),
            ],
          );
        });
    return result;
  }
}
