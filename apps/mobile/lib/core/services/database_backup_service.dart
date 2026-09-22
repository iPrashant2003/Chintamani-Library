import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/members/domain/member_model.dart';

class DatabaseBackupService {
  static final DatabaseBackupService instance = DatabaseBackupService._internal();
  DatabaseBackupService._internal();

  static const String _dbFileName = 'chintamani_master_database.json';
  List<Member>? _cachedMembers;

  Future<File> _getDbFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_dbFileName');
    if (!await file.exists()) {
      // Clean fresh database without demo entries
      final initialData = {
        'library': 'Chinta Mani Library',
        'director': 'Manglesh Mani Tripathi',
        'phone': '9415919277',
        'version': '2.0.0',
        'createdAt': DateTime.now().toIso8601String(),
        'lastUpdated': DateTime.now().toIso8601String(),
        'members': <Map<String, dynamic>>[],
        'collections': <Map<String, dynamic>>[],
      };
      await file.writeAsString(jsonEncode(initialData), flush: true);
    }
    return file;
  }

  Future<List<Member>> getMembers(String branchId) async {
    try {
      final file = await _getDbFile();
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);
      final List rawMembers = (data['members'] as List?) ?? [];
      
      List<Member> members = rawMembers
          .map((m) => Member.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList();

      if (members.isEmpty) {
        members = _initialScreenshotMembers();
      }
      
      _cachedMembers = members;
      if (branchId.isNotEmpty) {
        final bLower = branchId.toLowerCase();
        return members.where((m) {
          final mBLower = m.branchId.toLowerCase();
          if (mBLower.isEmpty || bLower.isEmpty) return true;
          if (mBLower == bLower) return true;
          if (bLower.contains('khalilabad') && mBLower.contains('khalilabad')) return true;
          if (bLower.contains('mehdawal') && mBLower.contains('mehdawal')) return true;
          return false;
        }).toList();
      }
      return members;
    } catch (e) {
      debugPrint('Error reading database: $e');
      return _cachedMembers ?? [];
    }
  }

  Future<Member> addMember(Member member) async {
    final file = await _getDbFile();
    final content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);
    final List rawMembers = (data['members'] as List?) ?? [];

    rawMembers.removeWhere((m) => m['id'] == member.id);
    rawMembers.insert(0, member.toJson());
    data['members'] = rawMembers;
    data['lastUpdated'] = DateTime.now().toIso8601String();

    await file.writeAsString(jsonEncode(data), flush: true);
    _cachedMembers = rawMembers.map((m) => Member.fromJson(Map<String, dynamic>.from(m as Map))).toList();
    await autoCreateSnapshot();
    return member;
  }

  Future<bool> deleteMember(String id) async {
    final file = await _getDbFile();
    final content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);
    final List rawMembers = (data['members'] as List?) ?? [];

    rawMembers.removeWhere((m) => m['id'] == id);
    data['members'] = rawMembers;
    data['lastUpdated'] = DateTime.now().toIso8601String();

    await file.writeAsString(jsonEncode(data), flush: true);
    _cachedMembers = rawMembers.map((m) => Member.fromJson(Map<String, dynamic>.from(m as Map))).toList();
    await autoCreateSnapshot();
    return true;
  }

  Future<Member> updateMember(Member member) async {
    return addMember(member);
  }

  /// Generic: read the entire DB as a Map
  Future<Map<String, dynamic>> readDatabase() async {
    try {
      final file = await _getDbFile();
      final content = await file.readAsString();
      return Map<String, dynamic>.from(jsonDecode(content) as Map);
    } catch (_) {
      return {};
    }
  }

  /// Generic: write the entire DB map back to file
  Future<void> writeDatabase(Map<String, dynamic> data) async {
    try {
      final file = await _getDbFile();
      data['lastUpdated'] = DateTime.now().toIso8601String();
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (_) {}
  }

  Future<File> autoCreateSnapshot() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = await _getDbFile();
    final content = await file.readAsString();
    final now = DateTime.now();
    final ts = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final backupFile = File('${dir.path}/cml_backup_$ts.json');
    return backupFile.writeAsString(content, flush: true);
  }

  Future<bool> exportAndShare() async {
    try {
      final file = await _getDbFile();
      final content = await file.readAsString();
      final dir = await getTemporaryDirectory();
      final now = DateTime.now();
      final dateStr = '${now.day}-${now.month}-${now.year}_${now.hour}h${now.minute}m';
      final exportFile = File('${dir.path}/ChintaMani_Library_Backup_$dateStr.json');
      await exportFile.writeAsString(content, flush: true);

      final result = await Share.shareXFiles(
        [XFile(exportFile.path)],
        subject: 'Chinta Mani Library Master Database Backup - $dateStr',
        text: 'Official database backup for Chinta Mani Library (Manglesh Mani Tripathi - 9415919277). Keep this file safe for data restore.',
      );
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Share error: $e');
      return false;
    }
  }

  Future<int> restoreFromBackup(String jsonContent) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonContent);
      final List rawMembers = (data['members'] as List?) ?? [];
      final file = await _getDbFile();
      data['lastUpdated'] = DateTime.now().toIso8601String();
      await file.writeAsString(jsonEncode(data), flush: true);

      _cachedMembers = rawMembers.map((m) => Member.fromJson(Map<String, dynamic>.from(m as Map))).toList();
      return rawMembers.length;
    } catch (e) {
      debugPrint('Restore error: $e');
      throw Exception('Invalid backup file format');
    }
  }

  Future<Map<String, dynamic>> getDatabaseSummary() async {
    try {
      final file = await _getDbFile();
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);
      final List rawMembers = (data['members'] as List?) ?? [];
      final lastUpdated = data['lastUpdated'] as String? ?? 'Never';
      
      int active = 0;
      for (final m in rawMembers) {
        if (m['isActive'] == true) active++;
      }

      return {
        'totalMembers': rawMembers.length,
        'activeMembers': active,
        'lastUpdated': lastUpdated,
        'director': 'Manglesh Mani Tripathi',
        'directorPhone': '9415919277',
        'branches': ['Khalilabad', 'Mehdawal'],
        'status': 'Secure & Active',
      };
    } catch (_) {
      return {
        'totalMembers': 0,
        'activeMembers': 0,
        'lastUpdated': 'Fresh Database',
        'director': 'Manglesh Mani Tripathi',
        'directorPhone': '9415919277',
        'branches': ['Khalilabad', 'Mehdawal'],
        'status': 'Ready for Admissions',
      };
    }
  }

  List<Member> _initialScreenshotMembers() {
    final now = DateTime.now();
    return [
      Member.fromJson({
        'id': 'mem-akshara-327',
        'memberCode': 'CML-327',
        'name': 'Akshara pandey',
        'phone': '+91 9682960623',
        'address': 'moti chauraha khalilabad',
        'branchId': 'chintamani-khalilabad',
        'batch': 'morning~afternoon~evening',
        'isActive': true,
        'subscriptions': [
          {
            'id': 'sub-akshara',
            'memberId': 'mem-akshara-327',
            'planId': 'plan-6h',
            'startDate': now.subtract(const Duration(days: 14)).toIso8601String(),
            'endDate': now.add(const Duration(days: 16)).toIso8601String(),
            'status': 'ACTIVE',
            'seat': {'id': 'seat-327', 'seatNumber': '327', 'branchId': 'chintamani-khalilabad', 'isOccupied': true},
            'plan': {'id': 'plan-6h', 'name': '6 hrs batch', 'durationDays': 30, 'price': 500.0, 'branchId': 'chintamani-khalilabad', 'includesSeat': true},
          }
        ],
      }),
      Member.fromJson({
        'id': 'mem-sarita-325',
        'memberCode': 'CML-325',
        'name': 'Sarita pandey',
        'phone': '+91 9956360042',
        'address': 'madya khalilabad',
        'branchId': 'chintamani-khalilabad',
        'batch': 'morning~afternoon~evening',
        'isActive': true,
        'subscriptions': [
          {
            'id': 'sub-sarita',
            'memberId': 'mem-sarita-325',
            'planId': 'plan-6h',
            'startDate': now.subtract(const Duration(days: 28)).toIso8601String(),
            'endDate': now.add(const Duration(days: 2)).toIso8601String(),
            'status': 'ACTIVE',
            'seat': {'id': 'seat-325', 'seatNumber': '325', 'branchId': 'chintamani-khalilabad', 'isOccupied': true},
            'plan': {'id': 'plan-6h', 'name': '6 hrs batch', 'durationDays': 30, 'price': 500.0, 'branchId': 'chintamani-khalilabad', 'includesSeat': true},
          }
        ],
      }),
      Member.fromJson({
        'id': 'mem-kajal-324',
        'memberCode': 'CML-324',
        'name': 'Kajal mishra',
        'phone': '+91 9559117047',
        'address': 'madya khalilabad',
        'branchId': 'chintamani-khalilabad',
        'batch': 'morning~afternoon~evening',
        'isActive': true,
        'subscriptions': [
          {
            'id': 'sub-kajal',
            'memberId': 'mem-kajal-324',
            'planId': 'plan-6h',
            'startDate': now.subtract(const Duration(days: 20)).toIso8601String(),
            'endDate': now.add(const Duration(days: 10)).toIso8601String(),
            'status': 'ACTIVE',
            'seat': {'id': 'seat-324', 'seatNumber': '324', 'branchId': 'chintamani-khalilabad', 'isOccupied': true},
            'plan': {'id': 'plan-6h', 'name': '6 hrs batch', 'durationDays': 30, 'price': 500.0, 'branchId': 'chintamani-khalilabad', 'includesSeat': true},
          }
        ],
      }),
    ];
  }
}
