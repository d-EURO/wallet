import 'dart:ffi';
import 'dart:io';

import 'package:deuro_wallet/packages/storage/asset_storage.dart';
import 'package:deuro_wallet/packages/storage/balance_storage.dart';
import 'package:deuro_wallet/packages/storage/node_storage.dart';
import 'package:deuro_wallet/packages/storage/transaction_storage.dart';
import 'package:deuro_wallet/packages/storage/wallet_storage.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

part 'database.g.dart';

const _encryptionPassword = 'drift.example.unsafe_password';
const _databaseFileName = 'test.db.enc';

@DriftDatabase(tables: [
  Assets,
  Balances,
  Nodes,
  Transactions,
  WalletAccountInfos,
  WalletInfos,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openDatabase());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {},
      );
}

QueryExecutor _openDatabase() {
  return LazyDatabase(() async {
    final path = await getApplicationDocumentsDirectory();

    return NativeDatabase.createInBackground(
      File(p.join(path.path, _databaseFileName)),
      isolateSetup: () async {
        open
          ..overrideFor(OperatingSystem.android, openCipherOnAndroid)
          ..overrideFor(OperatingSystem.linux,
              () => DynamicLibrary.open('libsqlcipher.so'))
          ..overrideFor(OperatingSystem.windows,
              () => DynamicLibrary.open('sqlcipher.dll'));
      },
      setup: (db) {
        // Check that we're actually running with SQLCipher by querying the
        // cipher_version pragma.
        final result = db.select('pragma cipher_version');
        if (result.isEmpty) {
          throw UnsupportedError(
            'This database needs to run with SQLCipher, but that library is '
            'not available!',
          );
        }

        // Then, apply the key to encrypt the database. Unfortunately, this
        // pragma doesn't seem to support prepared statements so we inline the
        // key.
        final escapedKey = _encryptionPassword.replaceAll("'", "''");
        db.execute("pragma key = '$escapedKey'");

        // Test that the key is correct by selecting from a table
        db.execute('select count(*) from sqlite_master');
      },
    );
  });
}
