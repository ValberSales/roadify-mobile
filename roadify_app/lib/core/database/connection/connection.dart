import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

LazyDatabase openConnection() {
  // O LazyDatabase garante que o banco só será inicializado quando a primeira query for feita
  return LazyDatabase(() async {
    // Impede que a base de dados seja exposta ao utilizador ou sofra backup acidental na nuvem.
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'roadify_db.sqlite'));

    // Retorna a engine nativa do SQLite rodando num Isolate (Thread secundária)
    // Essencial para aguentar inserções a 200 Hz sem travar a interface!
    return NativeDatabase.createInBackground(file);
  });
}
