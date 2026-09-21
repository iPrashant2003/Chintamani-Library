import 'package:hive/hive.dart';

class OfflineQueue {
  static const String _boxName = 'offline_attendance';
  
  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<void> enqueue(Map<String, dynamic> item) async {
    final box = await _getBox();
    await box.add(item);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final box = await _getBox();
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  Future<void> remove(int index) async {
    final box = await _getBox();
    await box.deleteAt(index);
  }

  Future<void> syncAll(dynamic repo) async {
    final box = await _getBox();
    final items = box.values.toList();
    // In a real scenario, this would call repo.sync(items)
    // and clear the box on success.
    await box.clear();
  }
}
