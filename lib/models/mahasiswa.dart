class Mahasiswa {
  final int id;
  final String name;
  final String email;
  final String nrp;
  final int? semester;
  final Map<String, dynamic>? kelas;

  Mahasiswa({
    required this.id,
    required this.name,
    required this.email,
    required this.nrp,
    this.semester,
    this.kelas,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      nrp: json['nrp'],
      semester: json['semester'],
      kelas: json['kelas'],
    );
  }
}