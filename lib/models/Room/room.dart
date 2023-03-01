class Room {
  final String email;
  final bool inRoom;
  final String lastChat;
  final int lastDateTime;
  final String lastUid;
  final String name;
  final String photo;
  final String type;
  final String uid;

  Room({
    this.email,
    this.inRoom,
    this.lastChat,
    this.lastDateTime,
    this.lastUid,
    this.name,
    this.photo,
    this.type,
    this.uid,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        email: json['email'] ?? '',
        inRoom: json['inRoom'] ?? false,
        lastChat: json['lastChat'] ?? '',
        lastDateTime: json['lastDateTime'] ?? 0,
        lastUid: json['lastUid'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? '',
        photo: json['photo'] ?? '',
        uid: json['uid'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'inRoom': inRoom,
        'lastChat': lastChat,
        'lastDateTime': lastDateTime,
        'lastUid': lastUid,
        'name': name,
        'type': type,
        'photo': photo,
        'uid': uid,
      };
}
