import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workos_arabic/constants/constants.dart';
import 'package:workos_arabic/inner_screens/add_task.dart';
import 'package:workos_arabic/inner_screens/profile.dart';
import 'package:workos_arabic/screens/all_workers.dart';
import 'package:workos_arabic/screens/tasks.dart';
import 'package:workos_arabic/user_state.dart';

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
            decoration: BoxDecoration(color: Colors.cyan),
            child: Column(
              children: [
                Flexible(
                    child: Image.network(
                        'https://image.flaticon.com/icons/png/128/1055/1055672.png')),
                SizedBox(
                  height: 20,
                ),
                Flexible(
                    child: Text(
                  'Work OS Arabic',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Constants.darkBlue,
                      fontSize: 22,
                      fontStyle: FontStyle.italic),
                ))
              ],
            )),
        SizedBox(
          height: 30,
        ),
        _listTiles(
            label: 'All tasks',
            fct: () {
              _navigateToTaskScreen(context);
            },
            icon: Icons.task_outlined),
        _listTiles(
            label: 'My account',
            fct: () {
              _navigateToProfileScreen(context);
            },
            icon: Icons.settings_outlined),
        _listTiles(
            label: 'Registered workes',
            fct: () {
              _navigateToAllWorkerScreen(context);
            },
            icon: Icons.workspaces_outline),
        _listTiles(
            label: 'Add task',
            fct: () {
              _navigateToAddTaskScreen(context);
            },
            icon: Icons.add_task_outlined),
        Divider(
          thickness: 1,
        ),
        _listTiles(
            label: 'Logout',
            fct: () {
              _logout(context);
            },
            icon: Icons.logout_outlined),
      ],
    ));
  }

  void _navigateToProfileScreen(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userID: uid,
        ),
      ),
    );
  }

  void _navigateToAllWorkerScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AllWorkersScreen(),
      ),
    );
  }

  void _navigateToAddTaskScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(),
      ),
    );
  }

  void _navigateToTaskScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TasksScreen(),
      ),
    );
  }

  void _logout(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    'https://image.flaticon.com/icons/png/128/1252/1252006.png',
                    height: 20,
                    width: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Sign out'),
                ),
              ],
            ),
            content: Text(
              'Do you wanna Sign out',
              style: TextStyle(
                  color: Constants.darkBlue,
                  fontSize: 20,
                  fontStyle: FontStyle.italic),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: Text('Cancel'),
              ),
              TextButton(
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (ctx) => UserState(),
                      ),
                    );
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          );
        });
  }

  Widget _listTiles(
      {required String label, required Function fct, required IconData icon}) {
    return ListTile(
      onTap: () {
        fct();
      },
      leading: Icon(
        icon,
        color: Constants.darkBlue,
      ),
      title: Text(
        label,
        style: TextStyle(
            color: Constants.darkBlue,
            fontSize: 20,
            fontStyle: FontStyle.italic),
      ),
    );
  }
}
