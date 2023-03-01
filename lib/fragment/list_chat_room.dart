import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcm_apps/chat_room/pages/chat_room_page.dart';
import 'package:fcm_apps/event/event_chat_room.dart';
import 'package:fcm_apps/models/Chat/chat.dart';
import 'package:fcm_apps/models/Person/person.dart';
import 'package:fcm_apps/utils/prefs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/Room/room.dart';

class ListChatRoom extends StatefulWidget {
  const ListChatRoom({Key key}) : super(key: key);

  @override
  State<ListChatRoom> createState() => _ListChatRoomState();
}

class _ListChatRoomState extends State<ListChatRoom> {
  Person myPerson;
  Stream<QuerySnapshot> streamRoom;

  void getMyPerson() async {
    Person person = await Prefs.getPerson();
    setState(() {
      myPerson = person;
    });

    streamRoom = FirebaseFirestore.instance
        .collection('person')
        .doc(myPerson.uid)
        .collection('room')
        .snapshots(includeMetadataChanges: true);
  }

  void deleteChatRoom(String personUid) async {
    var value = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          children: [
            ListTile(
              onTap: () => Navigator.pop(context, 'delete'),
              title: const Text('Delete Chat Room'),
            ),
            ListTile(
              onTap: () => Navigator.pop(context),
              title: const Text('CLose'),
            ),
          ],
        );
      },
    );
    if (value == 'delete') {
      EventChatRoom.deleteChatRoom(myUid: myPerson.uid, personUid: personUid);
    }
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
          stream: streamRoom,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data != null && snapshot.data.docs.isNotEmpty) {
              List listRoom = snapshot.data.docs;
              return ListView.separated(
                itemCount: listRoom.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    thickness: 1,
                    height: 1,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  Room room = Room.fromJson(listRoom[index].data());
                  return itemRoom(room);
                },
              );
            } else {
              return const Center(
                child: Text('Chat Kosong'),
              );
            }
          },
        ),
      ],
    );
  }

  Widget itemRoom(Room room) {
    String today = DateFormat('yyyy/MM/dd').format(DateTime.now());
    String yesterday = DateFormat('yyyy/MM/dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));
    DateTime roomDateTime =
        DateTime.fromMicrosecondsSinceEpoch(room.lastDateTime);
    String stringLastDateTime = DateFormat('yyyy/MM/dd').format(roomDateTime);
    String time = '';
    if (stringLastDateTime == today) {
      time = DateFormat('HH:mm').format(roomDateTime);
    } else if (stringLastDateTime == yesterday) {
      time = 'Yesterday';
    } else {
      time = DateFormat('yyyy/MM/dd').format(roomDateTime);
    }
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatRoomPage(room: room)),
          );
        },
        onLongPress: () {
          deleteChatRoom(room.uid);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Person person = Person(
                  //   email: room.email,
                  //   name: room.name,
                  //   photo: room.photo,
                  //   token: '',
                  //   uid: room.uid,
                  // );
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/appstore.png'),
                    image: NetworkImage(room.photo),
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(room.name),
                    Row(
                      children: [
                        SizedBox(
                          child: room.type == 'image'
                              ? Icon(Icons.image,
                                  size: 15, color: Colors.grey[700])
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          room.type == 'text'
                              ? room.lastChat.length > 20
                                  ? '${room.lastChat.substring(0, 20)}...'
                                  : room.lastChat
                              : ' <Image>',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  countUnreadMessage(room.uid, room.lastDateTime),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget countUnreadMessage(String personUid, int lastDateTime) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('person')
          .doc(myPerson.uid)
          .collection('room')
          .doc(personUid)
          .collection('chat')
          .snapshots(includeMetadataChanges: true),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const SizedBox();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }
        if (snapshot.data == null) {
          return const SizedBox();
        }
        List<QueryDocumentSnapshot> listChat = snapshot.data.docs;

        QueryDocumentSnapshot lastChat = listChat
            .where((element) => element.data()['dateTime'] == lastDateTime)
            .toList()[0];
        Chat lastDataChat = Chat.fromJson(lastChat.data());

        if (lastDataChat.uidSender == myPerson.uid) {
          return Icon(
            Icons.check,
            size: 20,
            color: lastDataChat.isRead ? Colors.blue : Colors.grey,
          );
        } else {
          int unRead = 0;
          for (var doc in listChat) {
            Chat docChat = Chat.fromJson(doc.data());
            if (!docChat.isRead && docChat.uidSender == personUid) {
              unRead = unRead + 1;
            }
          }
          if (unRead == 0) {
            return const SizedBox();
          } else {
            return Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              child: Text(
                unRead.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          }
        }
      },
    );
  }
}
