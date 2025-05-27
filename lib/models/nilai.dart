class Nilai {
  final int id;
  final String namaMatakuliah;
  final String kode;
  final int sks;
  final String dosen;
  final String? nilaiHuruf;
  final double? nilaiAngka;

  Nilai({
    required this.id,
    required this.namaMatakuliah,
    required this.kode,
    required this.sks,
    required this.dosen,
    this.nilaiHuruf,
    this.nilaiAngka,
  });

  factory Nilai.fromJson(Map<String, dynamic> json) {
    return Nilai(
      id: json['id'] ?? 0,
      namaMatakuliah: json['nama_matakuliah'] ?? '',
      kode: json['kode'] ?? '',
      sks: json['sks'] is int ? json['sks'] : int.tryParse(json['sks'].toString()) ?? 0,
      dosen: json['dosen'] ?? '',
      nilaiHuruf: json['nilai_huruf'],
      nilaiAngka: json['nilai_angka'] != null ? 
        (json['nilai_angka'] is double ? json['nilai_angka'] : 
        double.tryParse(json['nilai_angka'].toString())) : null,
    );
  }
}