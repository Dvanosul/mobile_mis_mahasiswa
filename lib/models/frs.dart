class FrsMatakuliah {
  final int id;
  final int matakuliahId;
  final String nama;
  final String kode;
  final int sks;
  final String dosen;
  final String jadwal;

  FrsMatakuliah({
    required this.id,
    required this.matakuliahId,
    required this.nama,
    required this.kode,
    required this.sks,
    required this.dosen,
    required this.jadwal,
  });

  factory FrsMatakuliah.fromJson(Map<String, dynamic> json) {
    return FrsMatakuliah(
      id: json['id'] ?? 0,
      matakuliahId: json['matakuliah_id'] ?? json['mata_kuliah_id'] ?? 0,
      nama: json['nama_matakuliah'] ?? json['nama_mk'] ?? json['nama'] ?? json['name'] ?? '',
      kode: json['kode_mk'] ?? json['kode'] ?? json['code'] ?? '',
      sks: json['sks'] is int ? json['sks'] : int.tryParse(json['sks'].toString()) ?? 0,
      dosen: json['nama_dosen'] ?? json['dosen'] ?? json['lecturer'] ?? '',
      jadwal: json['jadwal'] ?? json['schedule'] ?? '${json['hari'] ?? ''} ${json['waktu'] ?? ''}',
    );
  }
}