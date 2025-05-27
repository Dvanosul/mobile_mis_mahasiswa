class Jadwal {
  final int id;
  final String mataKuliah;
  final String kode;
  final String dosen;
  final String ruang;
  final String waktu;
  final String hari;

  Jadwal({
    required this.id,
    required this.mataKuliah,
    required this.kode,
    required this.dosen,
    required this.ruang,
    required this.waktu,
    required this.hari,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['id'] ?? 0,
      mataKuliah: json['mata_kuliah'] ?? '',
      kode: json['kode'] ?? '',
      dosen: json['dosen'] ?? '',
      ruang: json['ruang'] ?? '',
      waktu: json['waktu'] ?? '',
      hari: json['hari'] ?? '',
    );
  }
}