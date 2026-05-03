import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mycycle/core/hive/hive_doc_cache.dart';

class _Item {
  _Item(this.name);
  final String name;
}

Object _toJson(_Item i) => <String, dynamic>{'name': i.name};
_Item _fromJson(Object j) => _Item((j as Map)['name'] as String);

void main() {
  late Box<String> box;

  setUpAll(() {
    Hive.init(Directory.systemTemp.createTempSync('hive-test-').path);
  });

  setUp(() async {
    box = await Hive.openBox<String>(
      'doc-cache-test-${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    await box.close();
  });

  test('read returns null when nothing is cached', () {
    final cache = HiveDocCache<_Item>(
      box: box,
      toJson: _toJson,
      fromJson: _fromJson,
    );
    expect(cache.read('k'), isNull);
  });

  test('write then read round-trips the value', () async {
    final cache = HiveDocCache<_Item>(
      box: box,
      toJson: _toJson,
      fromJson: _fromJson,
    );
    await cache.write('k', _Item('hello'));
    expect(cache.read('k')?.name, 'hello');
  });

  test('read drops the key when JSON is corrupt', () async {
    await box.put('k', '{not json');
    final cache = HiveDocCache<_Item>(
      box: box,
      toJson: _toJson,
      fromJson: _fromJson,
    );
    expect(cache.read('k'), isNull);
    await pumpEventQueue();
    expect(box.get('k'), isNull);
  });

  test('delete removes the entry', () async {
    final cache = HiveDocCache<_Item>(
      box: box,
      toJson: _toJson,
      fromJson: _fromJson,
    );
    await cache.write('k', _Item('value'));
    expect(cache.read('k'), isNotNull);
    await cache.delete('k');
    expect(cache.read('k'), isNull);
  });
}
