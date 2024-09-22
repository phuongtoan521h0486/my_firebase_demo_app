import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:my_firebase_demo_app/providers/sign_in_provider.dart';
import 'package:my_firebase_demo_app/screens/login_screen.dart';
import 'package:my_firebase_demo_app/utils/next_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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
                      child: Image(
                        fit: BoxFit.fill,
                          image: CachedNetworkImageProvider(signInProvider.myUser!.imageUrl!),
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
                      label: Text("Name"), prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                      label: Text("Email"), prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                      label: Text("Phone"), prefixIcon: Icon(Icons.phone)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                      label: Text("Provider"),
                      prefixIcon: Icon(Icons.language)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    label: const Text("Password"),
                    prefixIcon: const Icon(Icons.fingerprint),
                    suffixIcon: IconButton(
                        icon: const Icon(FontAwesomeIcons.eyeSlash),
                        onPressed: () {}),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      signInProvider.signOut((signInProvider.myUser!.provider)!);
                      nextScreenReplace(context, const LoginScreen());
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1855FD),
                        side: BorderSide.none,
                        shape: const StadiumBorder()),
                    child: const Text("Sign Out",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
