import 'package:room_booking_app/models/user_profile.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

class UserProfileProvider {
  static const String dbName = 'user_profile.db';
  static const int kVersion1 = 1;
  static const String userProfileStoreName = 'user_profile';
  final lock = Lock(reentrant: true);
  final DatabaseFactory dbFactory;
  Database? db;

  final profilesStore = intMapStoreFactory.store(userProfileStoreName);

  UserProfileProvider(this.dbFactory);

  Future<Database> openPath(String path) async {
    db = await dbFactory.openDatabase(path, version: kVersion1);
    return db!;
  }

  Future<Database> get ready async =>
      db ??= await lock.synchronized<Database>(() async {
        if (db == null) {
          await open();
        }
        return db!;
      });

  Future<DbUserProfile?> getProfile(int id) async {
    var map = await profilesStore.record(id).get(db!);
    if (map != null) {
      return DbUserProfile()
        ..fromMap(map)
        ..id = id;
    }
    return null;
  }

  Future<Database> open() async {
    return await openPath(await fixPath(dbName));
  }

  Future<String> fixPath(String path) async => path;

  Future saveProfile(DbUserProfile dbUserProfile) async {
    if (dbUserProfile.id != null) {
      await profilesStore
          .record(dbUserProfile.id!)
          .put(db!, dbUserProfile.toMap());
    } else {
      dbUserProfile.id = await profilesStore.add(db!, dbUserProfile.toMap());
    }
  }

  Future deleteProfile(int? id) async {
    if (id != null) {
      await profilesStore.record(id).delete(db!);
    }
  }

  var bookingsTransformer = StreamTransformer<
      List<RecordSnapshot<int, Map<String, Object?>>>,
      List<DbUserProfile>>.fromHandlers(handleData: (snapshotList, sink) {
    sink.add(DbUserProfiles(snapshotList));
  });

  var bookingTransformer = StreamTransformer<
      RecordSnapshot<int, Map<String, Object?>>?,
      DbUserProfile?>.fromHandlers(handleData: (snapshot, sink) {
    sink.add(snapshot == null ? null : snapshotToProfile(snapshot));
  });

  Stream<List<DbUserProfile>> onProfiles() {
    return profilesStore
        .query(finder: Finder(sortOrders: [SortOrder('createdDt', false)]))
        .onSnapshots(db!)
        .transform(bookingsTransformer);
  }

  /// Listed for changes on a given rm booking
  Stream<DbUserProfile?> onProfile(int id) {
    return profilesStore
        .record(id)
        .onSnapshot(db!)
        .transform(bookingTransformer);
  }

  Future clearAllProfiles() async {
    await profilesStore.delete(db!);
    await getDatabaseFactory().deleteDatabase(db!.path);
  }

  Future close() async {
    await db!.close();
  }

  Future deleteDb() async {
    await dbFactory.deleteDatabase(await fixPath(dbName));
  }
}

DbUserProfile snapshotToProfile(RecordSnapshot snapshot) {
  return DbUserProfile()
    ..fromMap(snapshot.value as Map)
    ..id = snapshot.key as int;
}

class DbUserProfiles extends ListBase<DbUserProfile> {
  final List<RecordSnapshot<int, Map<String, Object?>>> list;
  late List<DbUserProfile?> _cacheProfiles;

  DbUserProfiles(this.list) {
    _cacheProfiles = List.generate(list.length, (index) => null);
  }

  @override
  DbUserProfile operator [](int index) {
    return _cacheProfiles[index] ??= snapshotToProfile(list[index]);
  }

  @override
  int get length => list.length;

  @override
  void operator []=(int index, DbUserProfile? value) => throw 'read-only';

  @override
  set length(int newLength) => throw 'read-only';
}
