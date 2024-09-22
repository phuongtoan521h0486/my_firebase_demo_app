class MyUser {
  String? uid;
  String? name;
  String? email;
  String? password;
  String? imageUrl;
  String? provider;
  // Role? role;

  MyUser(
      {this.uid,
        this.name,
        this.email,
        this.password,
        this.imageUrl,
        // this.role,
        this.provider});

}

enum Role {
  ADMIN,
  USER,
  GUEST,
}
