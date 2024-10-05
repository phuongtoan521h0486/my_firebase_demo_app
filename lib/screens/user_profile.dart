import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:my_firebase_demo_app/providers/sign_in_provider.dart';
import 'package:my_firebase_demo_app/screens/login_screen.dart';
import 'package:my_firebase_demo_app/utils/next_screen.dart';
import 'package:provider/provider.dart';

import '../utils/map_sign_in_type.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future getData() async {
    final signInProvider = context.read<SignInProvider>();
    await signInProvider.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final signInProvider = context.watch<SignInProvider>();
    final user = signInProvider.myUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("User Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: GradientBoxBorder(
                        gradient: LinearGradient(
                            colors: [Color(0xFF1855FD), Color(0xFF5C5CFD)]),
                        width: 4,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
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
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: const Color(0xFF1855FD)),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    label: Text("Name"),
                    prefixIcon: Icon(Icons.person),
                  ),
                  readOnly: true,
                  initialValue: user.name,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    label: Text("Email"),
                    prefixIcon: Icon(Icons.email),
                  ),
                  readOnly: true,
                  initialValue: user.email,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1855FD),
                        side: BorderSide.none,
                        shape: const StadiumBorder()),
                    child: const Text("Edit Profile",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text("Powered by", style: TextStyle(fontSize: 12)),
                        const SizedBox(
                          width: 5,
                        ),
                        Icon(
                          getIconSignInType(user.provider.toString()),
                          size: 12,
                        )
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        signInProvider.signOut(user.provider!);
                        nextScreenReplace(context, const LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          elevation: 0,
                          foregroundColor: Colors.red,
                          shape: const StadiumBorder(),
                          side: BorderSide.none),
                      child: const Text("Sign out"),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
