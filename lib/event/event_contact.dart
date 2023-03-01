// ignore_for_file: avoid_print, invalid_return_type_for_catch_error

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcm_apps/models/Person/person.dart';

class EventContact {
  static void addContact({
    String myUid,
    Person person,
  }) {
    try {
      FirebaseFirestore.instance
          .collection('person')
          .doc('myUid')
          .collection('contact')
          .doc(person.uid)
          .set(person.toJson())
          .then((value) => null)
          .catchError((onError) => print(onError));
    } catch (e) {
      print(e);
    }
  }

  static void deleteContact({String myUid, String personUid}) {
    try {
      FirebaseFirestore.instance
          .collection('person')
          .doc(myUid)
          .collection('contact')
          .doc(personUid)
          .delete()
          .then((value) => null)
          .catchError((onError) => print(onError));
    } catch (e) {
      print(e);
    }
  }

  static Future<bool> checkIsMyContact({String myUid, String personUid}) async {
    bool isMyContact = false;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('person')
          .doc(myUid)
          .collection('contact')
          .where('uid', isEqualTo: personUid)
          .get()
          .catchError((onError) => print(onError));
      if (querySnapshot.docs.isNotEmpty) {
        isMyContact = true;
      }
    } catch (e) {
      print(e);
    }
    return isMyContact;
  }
}
