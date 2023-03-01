import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcm_apps/chat_room/pages/chat_room_page.dart';
import 'package:fcm_apps/event/event_contact.dart';
import 'package:fcm_apps/event/event_person.dart';
import 'package:fcm_apps/models/Person/person.dart';
import 'package:fcm_apps/utils/prefs.dart';
import 'package:flutter/material.dart';

import '../models/Room/room.dart';

class ListContant extends StatefulWidget {
  const ListContant({Key key}) : super(key: key);

  @override
  State<ListContant> createState() => _ListContantState();
}

class _ListContantState extends State<ListContant> {
  TextEditingController emailController = TextEditingController();
  Person myPerson;
  Stream<QuerySnapshot> streamContact;
  void getMyPerson() async {
    Person person = await Prefs.getPerson();
    setState(() {
      myPerson = person;
    });
    streamContact = FirebaseFirestore.instance
        .collection('person')
        .doc(myPerson.uid)
        .collection('contact')
        .snapshots(includeMetadataChanges: true);
  }

  void addNewContact() async {
    var value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          contentPadding: const EdgeInsets.all(16),
          title: const Text('Add Contact'),
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'email@gmail.com',
              ),
              textAlignVertical: TextAlignVertical.bottom,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 'add');
              },
              child: const Text('Tambah'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Kembali'),
            ),
          ],
        );
      },
    );
    if (value == 'add') {
      String personUid = await EventPerson.checkEmail(emailController.text);
      if (personUid != null) {
        EventPerson.getPerson(personUid).then((person) {
          EventContact.addContact(myUid: myPerson.uid, person: person);
        });
      }
    }
    emailController.clear();
  }

  @override
  void initState() {
    super.initState();
    getMyPerson();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: streamContact,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data != null && snapshot.data.docs.isNotEmpty) {
              List listContant = snapshot.data.docs;
              return ListView.separated(
                itemCount: listContant.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    thickness: 1,
                    height: 1,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  Person person = Person.fromJson(listContant[index].data());
                  return itemContact(person);
                },
              );
            } else {
              return const Center(
                child: Text('Daftar Contact Kosong'),
              );
            }
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              addNewContact();
            },
          ),
        ),
      ],
    );
  }

  Widget itemContact(Person person) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ProfilePerson(
          //       person: person,
          //       myUid: _myPerson.uid,
          //     ),
          //   ),
          // );
        },
        child: SizedBox(
          width: 40,
          height: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: FadeInImage(
              placeholder: const AssetImage('assets/appstore.png'),
              image: NetworkImage(person.photo),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/appstore.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
      ),
      title: Text(person.name),
      subtitle: Text(person.email),
      trailing: IconButton(
        icon: const Icon(Icons.message),
        onPressed: () {
          Room room = Room(
            email: person.email,
            inRoom: false,
            lastChat: '',
            lastDateTime: 0,
            lastUid: '',
            name: person.name,
            photo: person.photo,
            type: '',
            uid: person.uid,
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatRoomPage(room: room)),
          );
        },
      ),
    );
  }
}
