
// ignore_for_file: avoid_print, invalid_return_type_for_catch_error

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Person/person.dart';

class EventPerson {
  static Future<String> checkEmail(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('person')
        .where('email', isEqualTo: email)
        .get()
        .catchError((onError) => print(onError));
    if (querySnapshot != null && querySnapshot.docs.isNotEmpty) {
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0].data()['uid'];
      } else {
        return '';
      }
    }
    return '';
  }

  static void addPerson(Person person) {
    try {
      FirebaseFirestore.instance
          .collection('person')
          .doc(person.uid)
          .set(person.toJson())
          .then((value) => null)
          .catchError((onError) => print(onError));
    } catch (e) {
      print(e);
    }
  }

  static void updatePersonToken(String myUid, String token) async {
    try {
      // update profile
      FirebaseFirestore.instance
          .collection('person')
          .doc(myUid)
          .update({
            'token': token,
          })
          .then((value) => null)
          .catchError((onError) => print(onError));
      // update contact
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('person').get();
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        queryDocumentSnapshot.reference
            .collection('contact')
            .where('uid', isEqualTo: myUid)
            .get()
            .then((value) {
          for (var docContact in value.docs) {
            docContact.reference
                .update({
                  'token': token,
                })
                .then((value) => null)
                .catchError((onError) => print(onError));
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<Person> getPerson(String uid) async {
    Person person;
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('person')
          .doc(uid)
          .get()
          .catchError((onError) => print(onError));
      person = Person.fromJson(documentSnapshot.data());
    } catch (e) {
      print(e);
    }
    return person;
  }

  static Future<String> getPersonToken(String uid) async {
    String token = '';
    try {
      DocumentSnapshot response = await FirebaseFirestore.instance
          .collection('person')
          .doc(uid)
          .get()
          .catchError((onError) => print(onError));
      token = response.data()['token'];
    } catch (e) {
      print(e);
    }
    return token;
  }

  static void deleteAccount(String myUid) async {
    try {
      // delete in person
      FirebaseFirestore.instance
          .collection('person')
          .doc(myUid)
          .delete()
          .then((value) => null)
          .catchError((onError) => print(onError));
      // delete in contact
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('person').get();
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        queryDocumentSnapshot.reference
            .collection('contact')
            .where('uid', isEqualTo: myUid)
            .get()
            .then((value) {
          for (var docContact in value.docs) {
            docContact.reference
                .delete()
                .then((value) => null)
                .catchError((onError) => print(onError));
          }
        });
      }
      // delete in room
      QuerySnapshot querySnapshot2 =
          await FirebaseFirestore.instance.collection('person').get();
      for (var queryDocumentSnapshot in querySnapshot2.docs) {
        queryDocumentSnapshot.reference
            .collection('room')
            .where('uid', isEqualTo: myUid)
            .get()
            .then((value) {
          for (var docRoom in value.docs) {
            docRoom.reference
                .delete()
                .then((value) => null)
                .catchError((onError) => print(onError));
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
