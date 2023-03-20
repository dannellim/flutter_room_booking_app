import 'dart:async';

import 'package:flutter_test/flutter_test.dart' as tst;
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

Future main() async {
  tst.group('sembast Test', () {
    tst.test('Reading and writing records', () async {
      // File path to a file in the current directory
      String dbPath = 'sample.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      await databaseFactoryIo.deleteDatabase(dbPath);

      // We use the database factory to open the database
      Database db = await dbFactory.openDatabase(dbPath);

      // dynamically typed store
      var store = StoreRef.main();

      tst.expect(await store.count(db), 0);

      // Easy to put/get simple values or map
      // A key can be of type int or String and the value can be anything as long as it can
      // be properly JSON encoded/decoded
      await store.record('title').put(db, 'Simple application');
      await store.record('version').put(db, 10);
      await store.record('settings').put(db, {'offline': true});

      tst.expect(await store.count(db), 3);

      // read values
      var title = await store.record('title').get(db) as String;
      tst.expect(title, 'Simple application');

      var version = await store.record('version').get(db) as int;
      tst.expect(version, 10);

      var settings = await store.record('settings').get(db) as Map;
      tst.expect(settings['offline'], true);

      // ...and delete
      await store.record('version').delete(db);
      tst.expect(await store.count(db), 2);

      await db.close();
      await databaseFactoryIo.deleteDatabase(dbPath);
    });
    tst.test("Store", () async {
      // File path to a file in the current directory
      String dbPath = 'sample.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      await databaseFactoryIo.deleteDatabase(dbPath);

      // We use the database factory to open the database
      Database db = await dbFactory.openDatabase(dbPath);

      // Use the animals store using Map records with int keys
      var store = intMapStoreFactory.store('animals');
      tst.expect(await store.count(db), 0);

      // Store some objects
      await db.transaction((txn) async {
        await store.add(txn, {'name': 'fish'});
        await store.add(txn, {'name': 'cat'});

        // You can specify a key
        await store.record(10).put(txn, {'name': 'dog'});
      });

      tst.expect(await store.count(db), 3);

      await db.close();
      await databaseFactoryIo.deleteDatabase(dbPath);
    });
    tst.test("Dart strong mode", () async {
      // File path to a file in the current directory
      String dbPath = 'sample.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      await databaseFactoryIo.deleteDatabase(dbPath);

      // We use the database factory to open the database
      Database db = await dbFactory.openDatabase(dbPath);

      // Use the main store for storing key values as String
      var store = StoreRef<String, String>.main();
      tst.expect(await store.count(db), 0);

      // Writing the data
      await store.record('username').put(db, 'my_username');
      await store.record('url').put(db, 'my_url');
      tst.expect(await store.count(db), 2);

      // Reading the data
      var url = await store.record('url').get(db);
      tst.expect(url, 'my_url');
      var username = await store.record('username').get(db);
      tst.expect(username, 'my_username');

      await db.close();
      await databaseFactoryIo.deleteDatabase(dbPath);
    });
    tst.test("type Map, record fields can be referenced using a dot (.)",
        () async {
      // File path to a file in the current directory
      String dbPath = 'sample.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      await databaseFactoryIo.deleteDatabase(dbPath);

      // We use the database factory to open the database
      Database db = await dbFactory.openDatabase(dbPath);

      var store = intMapStoreFactory.store();
      tst.expect(await store.count(db), 0);
      var key = await store.add(db, {
        'path': {'sub': 'my_value'},
        'with.dots': 'my_other_value'
      });
      tst.expect(await store.count(db), 1);

      var record = await store.record(key).getSnapshot(db);
      var value = record!['path.sub'];
      tst.expect(value, 'my_value');
      // value = 'my_value'
      var value2 = record[FieldKey.escape('with.dots')];
      tst.expect(value2, 'my_other_value');
      // value2 = 'my_other_value'

      await db.close();
      await databaseFactoryIo.deleteDatabase(dbPath);
    });
    tst.test("Auto increment", () async {
      // File path to a file in the current directory
      String dbPath = 'sample.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      await databaseFactoryIo.deleteDatabase(dbPath);

      // We use the database factory to open the database
      Database db = await dbFactory.openDatabase(dbPath);

      var store = StoreRef<int, String>.main();
      tst.expect(await store.count(db), 0);
      // Auto incrementation is built-in
      var key1 = await store.add(db, 'value1');
      tst.expect(key1, 1);
      var key2 = await store.add(db, 'value2');
      tst.expect(key2, 2);
      // key1 = 1, key2 = 2...

      await db.close();
      await databaseFactoryIo.deleteDatabase(dbPath);
    });
    tst.test("Simple find mechanism", () async {
      // File path to a file in the current directory
      String dbPath = 'sample.db';
      DatabaseFactory dbFactory = databaseFactoryIo;
      await databaseFactoryIo.deleteDatabase(dbPath);

      // We use the database factory to open the database
      Database db = await dbFactory.openDatabase(dbPath);

      // Use the animals store using Map records with int keys
      var store = intMapStoreFactory.store('animals');
      tst.expect(await store.count(db), 0);

      // Store some objects
      await db.transaction((txn) async {
        await store.add(txn, {'name': 'fish'});
        await store.add(txn, {'name': 'cat'});
        await store.add(txn, {'name': 'dog'});
      });
      tst.expect(await store.count(db), 3);

      // Look for any animal "greater than" (alphabetically) 'cat'
      // ordered by name
      var finder = Finder(
          filter: Filter.greaterThan('name', 'cat'),
          sortOrders: [SortOrder('name')]);
      var records = await store.find(db, finder: finder);

      tst.expect(records.length, 2);
      tst.expect(records[0]['name'], 'dog');
      tst.expect(records[1]['name'], 'fish');

      await db.close();
      await databaseFactoryIo.deleteDatabase(dbPath);
    });
  });
}
