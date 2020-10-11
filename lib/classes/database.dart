import 'package:path_provider/path_provider.dart'; //digunakan untuk menggunakan filesystem locations
import 'dart:io'; // digunakan by file
import 'dart:convert'; //digunakan untuk json
import 'journal.dart';

class DatabaseFileRoutines {
  //untuk mengambil atau mengetahui letak local pathnya dimana
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //untuk membuat file lokal dan menyimpan di lokasi path nya di appdata
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }

//ini untuk membaca journal
  Future<String> readJournals() async {
    try {
      //pertama deklarasikan file menjadi lokasi file
      final file = await _localFile;
      //file.existsync digunakan untuk melakukan check apakah filenya sudah ada jika tidak akan dibuat dengan cara
      //memanggil wirtejournals method untuk membuat file journal kosong
      if (!file.existsSync()) {
        print("File does not exist: ${file.absolute}");
        await writeJournals('{"journals": []}');
      }
      //membaca isi dari file yang di namanakan contents
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      print("error readJournals: $e");
      return "";
    }
  }

//method ini menyimpan json object ke file
  Future<File> writeJournals(String json) async {
    final file = await _localFile;
    return file.writeAsString('$json');
  }
}

//method ini untuk membaca File Json (dataFromJson)
Database databaseFromJson(String str) {
  final dataFromJson = json.decode(str); //deserialize

  return Database.fromJson(dataFromJson);
}

//method ini untuk menyimpan data ke json file (dataToJson)
String databaseToJson(Database data) {
  final dataToJson = data.toJson();
  // print(dataToJson);
  return json.encode(dataToJson); //serialize
}

class Database {
  //dibawah ini item yang dideklarasikan adalah variabel jurnal yang berisi list journal
  List<Journal> journal;
  //dibawah ini adalah constructor
  Database({
    this.journal,
  });

  //dibawah ini adalah factory constructor untuk membaca
  factory Database.fromJson(Map<String, dynamic> json) => Database(
        journal: List<Journal>.from(
            json["journals"].map((x) => Journal.fromJson(x))),
      );
//dibawah ini map untuk parse/simpan ke json
  Map<String, dynamic> toJson() => {
        "journals": List<dynamic>.from(journal.map((x) => x.toJson())),
      };
}
