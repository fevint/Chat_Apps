class Person {
  final String email;
  final String name;
  final String photo;
  final String token;
  final String uid;

  Person({
    this.email,
    this.name,
    this.photo,
    this.token,
    this.uid,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        email: json['email'] ?? '',
        name: json['name'] ?? '',
        photo: json['photo'] ?? '',
        token: json['token'] ?? '',
        uid: json['uid'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'photo': photo,
        'token': token,
        'uid': uid,
      };
}
