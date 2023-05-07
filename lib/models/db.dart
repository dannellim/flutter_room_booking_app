import 'package:cv/cv.dart';
export 'package:cv/cv.dart';

/// Base record implementation.
abstract class DbRecord extends CvModelBase {
  /// Record id.
  int? id;
  int createdDt = DateTime.now().millisecondsSinceEpoch;
  int updatedDt = DateTime.now().millisecondsSinceEpoch;
}
