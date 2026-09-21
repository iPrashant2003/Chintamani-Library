import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class BatchConfig {
  final String id;
  final String name;
  final String timing;
  final int startMinutes;
  final int endMinutes;
  final int totalSeats;
  final double price;
  final Color color;
  final bool is24Hours;

  const BatchConfig({
    required this.id,
    required this.name,
    required this.timing,
    required this.startMinutes,
    required this.endMinutes,
    required this.totalSeats,
    required this.price,
    required this.color,
    this.is24Hours = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'timing': timing,
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
        'totalSeats': totalSeats,
        'price': price,
        'color': color.value,
        'is24Hours': is24Hours,
      };

  factory BatchConfig.fromJson(Map<String, dynamic> json) => BatchConfig(
        id: json['id'] as String? ?? UniqueKey().toString(),
        name: json['name'] as String? ?? 'Custom Batch',
        timing: json['timing'] as String? ?? '7am - 1pm',
        startMinutes: (json['startMinutes'] as num?)?.toInt() ?? 420,
        endMinutes: (json['endMinutes'] as num?)?.toInt() ?? 780,
        totalSeats: (json['totalSeats'] as num?)?.toInt() ?? 10,
        price: (json['price'] as num?)?.toDouble() ?? 500.0,
        color: Color((json['color'] as num?)?.toInt() ?? 0xFF00CDB0),
        is24Hours: json['is24Hours'] as bool? ?? false,
      );

  BatchConfig copyWith({
    String? id,
    String? name,
    String? timing,
    int? startMinutes,
    int? endMinutes,
    int? totalSeats,
    double? price,
    Color? color,
    bool? is24Hours,
  }) =>
      BatchConfig(
        id: id ?? this.id,
        name: name ?? this.name,
        timing: timing ?? this.timing,
        startMinutes: startMinutes ?? this.startMinutes,
        endMinutes: endMinutes ?? this.endMinutes,
        totalSeats: totalSeats ?? this.totalSeats,
        price: price ?? this.price,
        color: color ?? this.color,
        is24Hours: is24Hours ?? this.is24Hours,
      );
}

class BatchTimingService {
  static final BatchTimingService instance = BatchTimingService._internal();
  BatchTimingService._internal();

  static const String _dbFileName = 'chintamani_master_database.json';

  static List<BatchConfig> get defaultBatches => [
        const BatchConfig(
          id: 'b1',
          name: '6 Hour Morning',
          timing: '7am – 1pm',
          startMinutes: 7 * 60,
          endMinutes: 13 * 60,
          totalSeats: 10,
          price: 500.0,
          color: Color(0xFF00CDB0), // Sea green
        ),
        const BatchConfig(
          id: 'b2',
          name: '6 Hour Afternoon',
          timing: '1pm – 7pm',
          startMinutes: 13 * 60,
          endMinutes: 19 * 60,
          totalSeats: 10,
          price: 500.0,
          color: Color(0xFF8B5CF6), // Royal Purple
        ),
        const BatchConfig(
          id: 'b3',
          name: '6 Hour Evening',
          timing: '3pm – 9pm',
          startMinutes: 15 * 60,
          endMinutes: 21 * 60,
          totalSeats: 10,
          price: 500.0,
          color: Color(0xFFF59E0B), // Imperial Gold
        ),
        const BatchConfig(
          id: 'b4',
          name: '12 Hour Day',
          timing: '7am – 7pm',
          startMinutes: 7 * 60,
          endMinutes: 19 * 60,
          totalSeats: 8,
          price: 800.0,
          color: Color(0xFFEF4444), // Crimson Red
        ),
        const BatchConfig(
          id: 'b5',
          name: '12 Hour Late',
          timing: '10am – 10pm',
          startMinutes: 10 * 60,
          endMinutes: 22 * 60,
          totalSeats: 7,
          price: 800.0,
          color: Color(0xFF2563EB), // Sapphire Blue
        ),
        const BatchConfig(
          id: 'b6',
          name: '24 Hour Pass',
          timing: '24 Hours (Round the Clock)',
          startMinutes: 0,
          endMinutes: 24 * 60,
          totalSeats: 5,
          price: 1000.0,
          color: Color(0xFF10B981), // Radiant Emerald
          is24Hours: true,
        ),
      ];

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_dbFileName');
  }

  Future<List<BatchConfig>> loadBatches() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return defaultBatches;
      final text = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(text);
      if (data.containsKey('batches') && data['batches'] is List) {
        final List list = data['batches'] as List;
        if (list.isNotEmpty) {
          return list
              .map((e) => BatchConfig.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      }
      return defaultBatches;
    } catch (_) {
      return defaultBatches;
    }
  }

  Future<void> saveBatches(List<BatchConfig> batches) async {
    try {
      final file = await _getFile();
      Map<String, dynamic> data = {};
      if (await file.exists()) {
        try {
          data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        } catch (_) {}
      }
      data['batches'] = batches.map((b) => b.toJson()).toList();
      data['lastUpdated'] = DateTime.now().toIso8601String();
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (e) {
      debugPrint('Error saving batches: $e');
    }
  }
}

class BatchNotifier extends StateNotifier<List<BatchConfig>> {
  BatchNotifier() : super(BatchTimingService.defaultBatches) {
    _init();
  }

  Future<void> _init() async {
    final loaded = await BatchTimingService.instance.loadBatches();
    state = loaded;
  }

  Future<void> updateBatch(BatchConfig updated) async {
    state = [
      for (final b in state)
        if (b.id == updated.id) updated else b,
    ];
    await BatchTimingService.instance.saveBatches(state);
  }

  Future<void> addBatch(BatchConfig newBatch) async {
    state = [...state, newBatch];
    await BatchTimingService.instance.saveBatches(state);
  }

  Future<void> deleteBatch(String id) async {
    state = state.where((b) => b.id != id).toList();
    await BatchTimingService.instance.saveBatches(state);
  }

  Future<void> resetToDefaults() async {
    state = BatchTimingService.defaultBatches;
    await BatchTimingService.instance.saveBatches(state);
  }
}

final batchListProvider =
    StateNotifierProvider<BatchNotifier, List<BatchConfig>>((ref) {
  return BatchNotifier();
});
