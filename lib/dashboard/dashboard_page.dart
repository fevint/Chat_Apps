// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:fcm_apps/forgot_password/forgot_password_page.dart';
import 'package:fcm_apps/fragment/list_chat_room.dart';
import 'package:fcm_apps/fragment/list_contant.dart';
import 'package:fcm_apps/login/login_page.dart';

import 'package:fcm_apps/utils/prefs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../event/event_person.dart';
import '../event/event_storage.dart';
import '../models/Person/person.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Person myPerson;
  int indexFragmen = 0;
  List<Widget> listFragmen = [
    const ListChatRoom(),
    const ListContant(),
  ];

  void getPerson() async {
    Person person = await Prefs.getPerson();
    setState(() {
      myPerson = person;
    });
    print(myPerson.email);

    if (myPerson != null) {
      print(myPerson.email);
      print('person not null');
    } else {
      print('person null');
    }
  }

  void pickAndCropPhoto() async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    if (pickedFile != null) {
      File croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          iosUiSettings: const IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      if (croppedFile != null) {
        EventStorage.editPhoto(
          filePhoto: File(croppedFile.path),
          oldUrl: myPerson.photo,
          uid: myPerson.uid,
        );
        EventPerson.getPerson(myPerson.uid).then((person) {
          Prefs.setPerson(person);
        });
      }
    }
    getPerson();
  }

  @override
  void initState() {
    getPerson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: indexFragmen,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: const Text('Chat Apps'),
          bottom: const TabBar(tabs: [
            Tab(
              text: 'Chat Room',
            ),
            Tab(
              text: 'Contact',
            )
          ]),
        ),
        drawer: menuDrawer(),
        body: TabBarView(children: listFragmen),
      ),
    );
  }

  void logout() async {
    var value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('You sure for logout?'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'logout'),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (value == 'logout') {
      Prefs.clear();
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  Widget menuDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/appstore.png'),
                    image: NetworkImage(myPerson == null ? '' : myPerson.photo),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/appstore.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        myPerson == null ? '' : myPerson.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        myPerson == null ? '' : myPerson.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => EditProfile(person: my),
              //   ),
              // ).then((value) => getPerson());
            },
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForgotPassword()),
              );
            },
            leading: const Icon(Icons.lock),
            title: const Text('Reset Password'),
            trailing: const Icon(Icons.navigate_next),
          ),
          ListTile(
            onTap: () {
              pickAndCropPhoto();
            },
            leading: const Icon(Icons.image),
            title: const Text('Edit Photo'),
            trailing: const Icon(Icons.navigate_next),
          ),
          const Divider(height: 1, thickness: 1),
          ListTile(
            onTap: () {
              // deleteAccount();
            },
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete Account'),
          ),
          const Divider(height: 1, thickness: 1),
          ListTile(
            onTap: () {
              logout();
            },
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
