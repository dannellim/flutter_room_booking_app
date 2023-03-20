import 'package:room_booking_app/models/rm_booking.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

class DbRmBookingProvider {
  static const String dbName = 'test.db';
  static const int kVersion1 = 1;
  static const String rmBookingStoreName = 'room_booking';
  final lock = Lock(reentrant: true);
  final DatabaseFactory dbFactory;
  Database? db;

  final bookingsStore = intMapStoreFactory.store(rmBookingStoreName);

  DbRmBookingProvider(this.dbFactory);

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

  Future<DbRmBooking?> getBooking(int id) async {
    var map = await bookingsStore.record(id).get(db!);
    if (map != null) {
      return DbRmBooking()
        ..fromMap(map)
        ..id = id;
    }
    return null;
  }

  Future<Database> open() async {
    return await openPath(await fixPath(dbName));
  }

  Future<String> fixPath(String path) async => path;

  Future saveRmBooking(DbRmBooking dbRmBooking) async {
    if (dbRmBooking.id != null) {
      await bookingsStore.record(dbRmBooking.id!).put(db!, dbRmBooking.toMap());
    } else {
      dbRmBooking.id = await bookingsStore.add(db!, dbRmBooking.toMap());
    }
  }

  Future deleteRmBooking(int? id) async {
    if (id != null) {
      await bookingsStore.record(id).delete(db!);
    }
  }

  var bookingsTransformer = StreamTransformer<
      List<RecordSnapshot<int, Map<String, Object?>>>,
      List<DbRmBooking>>.fromHandlers(handleData: (snapshotList, sink) {
    sink.add(DbRmBookings(snapshotList));
  });

  var bookingTransformer = StreamTransformer<
      RecordSnapshot<int, Map<String, Object?>>?,
      DbRmBooking?>.fromHandlers(handleData: (snapshot, sink) {
    sink.add(snapshot == null ? null : snapshotToBooking(snapshot));
  });

  Stream<List<DbRmBooking>> onRmBookings() {
    return bookingsStore
        .query(finder: Finder(sortOrders: [SortOrder('bookedDate', false)]))
        .onSnapshots(db!)
        .transform(bookingsTransformer);
  }

  /// Listed for changes on a given rm booking
  Stream<DbRmBooking?> onRoomBooking(int id) {
    return bookingsStore
        .record(id)
        .onSnapshot(db!)
        .transform(bookingTransformer);
  }

  Future clearAllRoomBookings() async {
    await bookingsStore.delete(db!);
    await getDatabaseFactory().deleteDatabase(db!.path);
  }

  Future close() async {
    await db!.close();
  }

  Future deleteDb() async {
    await dbFactory.deleteDatabase(await fixPath(dbName));
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
