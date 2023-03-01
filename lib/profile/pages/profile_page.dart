import 'package:fcm_apps/event/event_contact.dart';
import 'package:fcm_apps/event/event_person.dart';
import 'package:fcm_apps/models/Person/person.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key, this.person, this.myUid}) : super(key: key);
  final Person person;
  final String myUid;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isContact = false;

  void checkContact() async {
    bool isContact = await EventContact.checkIsMyContact(
      myUid: widget.myUid,
      personUid: widget.person.uid,
    );
    setState(() {
      _isContact = isContact;
    });
  }

  @override
  void initState() {
    checkContact();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('ProfilePerson'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 30),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: FadeInImage(
                placeholder: const AssetImage('assets/logo_flikchat.png'),
                image: NetworkImage(widget.person.photo),
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/logo_flikchat.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Name'),
            subtitle: Text(widget.person.name),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(widget.person.email),
          ),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),
          ElevatedButton(
            child: Text(_isContact ? 'Delete Contact' : 'Add Contact'),
            onPressed: () {
              if (_isContact) {
                EventContact.deleteContact(
                  myUid: widget.myUid,
                  personUid: widget.person.uid,
                );
                checkContact();
              } else {
                EventPerson.getPerson(widget.person.uid).then((person) {
                  EventContact.addContact(myUid: widget.myUid, person: person);
                  checkContact();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
