import 'package:room_booking_app/models/user_profile.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

class UserProfileProvider {
  static const String _dbName = 'user_profile.db';
  static const int _kVersion1 = 1;
  static const String _userProfileStoreName = 'user_profile';
  final _lock = Lock(reentrant: true);
  final DatabaseFactory _dbFactory;
  Database? _db;

  final profilesStore = intMapStoreFactory.store(_userProfileStoreName);

  UserProfileProvider(this._dbFactory);

  Future<Database> openPath(String path) async {
    _db = await _dbFactory.openDatabase(path, version: _kVersion1);
    return _db!;
  }

  Future<Database> get ready async =>
      _db ??= await _lock.synchronized<Database>(() async {
        if (_db == null) {
          await open();
        }
        return _db!;
      });

  Future<DbUserProfile?> getProfile(int id) async {
    var map = await profilesStore.record(id).get(_db!);
    if (map != null) {
      return DbUserProfile()
        ..fromMap(map)
        ..id = id;
    }
    return null;
  }

  Future<Database> open() async {
    return await openPath(await fixPath(_dbName));
  }

  Future<String> fixPath(String path) async => path;

  Future saveProfile(DbUserProfile dbUserProfile) async {
    if (dbUserProfile.id != null) {
      await profilesStore
          .record(dbUserProfile.id!)
          .put(_db!, dbUserProfile.toMap());
    } else {
      dbUserProfile.id = await profilesStore.add(_db!, dbUserProfile.toMap());
    }
  }

  Future deleteProfile(int? id) async {
    if (id != null) {
      await profilesStore.record(id).delete(_db!);
    }
  }

  final _profilesTransformer = StreamTransformer<
      List<RecordSnapshot<int, Map<String, Object?>>>,
      List<DbUserProfile>>.fromHandlers(handleData: (snapshotList, sink) {
    sink.add(DbUserProfiles(snapshotList));
  });

  final _profileTransformer = StreamTransformer<
      RecordSnapshot<int, Map<String, Object?>>?,
      DbUserProfile?>.fromHandlers(handleData: (snapshot, sink) {
    sink.add(snapshot == null ? null : snapshotToProfile(snapshot));
  });

  Stream<List<DbUserProfile>> onProfiles() {
    return profilesStore
        .query(finder: Finder(sortOrders: [SortOrder('createdDt', false)]))
        .onSnapshots(_db!)
        .transform(_profilesTransformer);
  }

  /// Listed for changes on a given rm booking
  Stream<DbUserProfile?> onProfile(int id) {
    return profilesStore
        .record(id)
        .onSnapshot(_db!)
        .transform(_profileTransformer);
  }

  Future clearAllProfiles() async {
    await profilesStore.delete(_db!);
    await getDatabaseFactory().deleteDatabase(_db!.path);
  }

  Future close() async {
    await _db!.close();
  }

  Future deleteDb() async {
    await _dbFactory.deleteDatabase(await fixPath(_dbName));
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
