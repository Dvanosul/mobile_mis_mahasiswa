class User {
  final int id;
  final String name;
  final String email;
  final String? nrp;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.nrp,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      nrp: json['nrp'],
      role: json['role'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'nrp': nrp,
      'role': role,
    };
  }
}