import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sign_in_provider.dart';
import '../utils/next_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final signInProvider = context.watch<SignInProvider>();
    signInProvider.getDataFromSharedPreferences();
    final user = signInProvider.myUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Task Tracking"),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: user!.imageUrl != null
                  ? Image(
                fit: BoxFit.fill,
                image: CachedNetworkImageProvider(
                    user.imageUrl.toString()),
              )
                  : Image.asset(
                'assets/images/user_avatar_default.png',
                fit: BoxFit.fill,
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => {
                },
                child: Text('Profile'),
              ),
              PopupMenuItem(
                onTap: () {
                  signInProvider.signOut(user.provider!);
                  nextScreenReplace(context, const LoginScreen());
                },
                child: Text('Sign out'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Checkbox(value: false, onChanged: (value) {},),
            onTap: () {},
            title: Text("Task 1"),
            subtitle: Row(children: [
              Icon(Icons.calendar_month),
              Text("25/03/2003 - 25/03/2025")
            ],),
            trailing: Column(
              children: [
                Text("In progress"),
                Text("Priority"),
              ],
            ),
          ),
  

        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF0C23FE),
          onPressed: () {
            print("Add new Task");
          },
          child: Icon(Icons.add)),
    );
  }
}
