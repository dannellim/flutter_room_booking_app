import 'package:room_booking_app/models/rm_booking.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

class DbRmBookingProvider {
  static const String _dbName = 'room_booking.db';
  static const int _kVersion1 = 1;
  static const String _rmBookingStoreName = 'room_booking';
  final _lock = Lock(reentrant: true);
  final DatabaseFactory _dbFactory;
  Database? _db;

  final _bookingsStore = intMapStoreFactory.store(_rmBookingStoreName);

  DbRmBookingProvider(this._dbFactory);

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

  Future<DbRmBooking?> getBooking(int id) async {
    var map = await _bookingsStore.record(id).get(_db!);
    if (map != null) {
      return DbRmBooking()
        ..fromMap(map)
        ..id = id;
    }
    return null;
  }

  Future<Database> open() async {
    return await openPath(await fixPath(_dbName));
  }

  Future<String> fixPath(String path) async => path;

  Future saveRmBooking(DbRmBooking dbRmBooking) async {
    if (dbRmBooking.id != null) {
      await _bookingsStore
          .record(dbRmBooking.id!)
          .put(_db!, dbRmBooking.toMap());
    } else {
      dbRmBooking.id = await _bookingsStore.add(_db!, dbRmBooking.toMap());
    }
  }

  Future deleteRmBooking(int? id) async {
    if (id != null) {
      await _bookingsStore.record(id).delete(_db!);
    }
  }

  final _bookingsTransformer = StreamTransformer<
      List<RecordSnapshot<int, Map<String, Object?>>>,
      List<DbRmBooking>>.fromHandlers(handleData: (snapshotList, sink) {
    sink.add(DbRmBookings(snapshotList));
  });

  final _bookingTransformer = StreamTransformer<
      RecordSnapshot<int, Map<String, Object?>>?,
      DbRmBooking?>.fromHandlers(handleData: (snapshot, sink) {
    sink.add(snapshot == null ? null : snapshotToBooking(snapshot));
  });

  Stream<List<DbRmBooking>> onRmBookings() {
    return _bookingsStore
        .query(finder: Finder(sortOrders: [SortOrder('bookedDate', false)]))
        .onSnapshots(_db!)
        .transform(_bookingsTransformer);
  }

  /// Listed for changes on a given rm booking
  Stream<DbRmBooking?> onRoomBooking(int id) {
    return _bookingsStore
        .record(id)
        .onSnapshot(_db!)
        .transform(_bookingTransformer);
  }

  Future clearAllRoomBookings() async {
    await _bookingsStore.delete(_db!);
    await getDatabaseFactory().deleteDatabase(_db!.path);
  }

  Future close() async {
    await _db!.close();
  }

  Future deleteDb() async {
    await _dbFactory.deleteDatabase(await fixPath(_dbName));
  }
}

DbRmBooking snapshotToBooking(RecordSnapshot snapshot) {
  return DbRmBooking()
    ..fromMap(snapshot.value as Map)
    ..id = snapshot.key as int;
}

class DbRmBookings extends ListBase<DbRmBooking> {
  final List<RecordSnapshot<int, Map<String, Object?>>> list;
  late List<DbRmBooking?> _cacheBookings;

  DbRmBookings(this.list) {
    _cacheBookings = List.generate(list.length, (index) => null);
  }

  @override
  DbRmBooking operator [](int index) {
    return _cacheBookings[index] ??= snapshotToBooking(list[index]);
  }

  @override
  int get length => list.length;

  @override
  void operator []=(int index, DbRmBooking? value) => throw 'read-only';

  @override
  set length(int newLength) => throw 'read-only';
}
