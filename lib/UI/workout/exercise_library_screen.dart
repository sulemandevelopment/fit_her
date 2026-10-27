import 'package:fitness_zone_2/data/api_provider/api_provider.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/consultation_controller/consultation_controller.dart';
import 'package:fitness_zone_2/values/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// X1 — tagged exercise list. Written steps, mark done, injury filter.
class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;
  String _intensity = '';
  String _injuries = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  String? get _token {
    if (!Get.isRegistered<AuthController>()) return null;
    final token = Get.find<AuthController>().sharedPreferences.getString(Constants.accessToken);
    if (token == null || token.isEmpty) return null;
    return token;
  }

  Future<void> _load() async {
    final token = _token;
    if (token == null || !Get.isRegistered<ApiProvider>()) {
      setState(() {
        _loading = false;
        _error = 'Sign in to see exercises.';
      });
      return;
    }
    if (Get.isRegistered<ConsultationController>()) {
      final profile = await Get.find<ConsultationController>().loadProfile();
      final raw = profile?.workoutSection?['injuries'];
      if (raw is String) _injuries = raw;
      if (raw is List) _injuries = raw.join(' ');
    }
    try {
      final response = await Get.find<ApiProvider>().getData(
        Constants.exercises,
        query: {
          if (_intensity.isNotEmpty) 'intensity': _intensity,
          if (_injuries.trim().isNotEmpty) 'injuries': _injuries.trim(),
        },
        headers: {'accessToken': token},
      );
      final body = response.body;
      if (!mounted) return;
      if (body is Map && body['status'] == '1' && body['data'] is Map) {
        final list = body['data']['exercises'];
        setState(() {
          _rows = list is List
              ? list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
              : [];
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _loading = false;
          _error = body is Map ? body['message']?.toString() : 'Could not load exercises';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load exercises';
        });
      }
    }
  }

  Future<void> _complete(Map<String, dynamic> row) async {
    final token = _token;
    final id = row['id'];
    if (token == null || id == null) return;
    final response = await Get.find<ApiProvider>().postData(
      '${Constants.exercises}/$id/complete',
      body: const <String, dynamic>{},
      headers: {'accessToken': token},
    );
    final body = response.body;
    if (!mounted) return;
    if (body is Map && body['status'] == '1') {
      setState(() => row['doneToday'] = true);
    } else {
      setState(() => _error = 'Could not mark this exercise done.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F4E0),
        foregroundColor: const Color(0xFF1A3A22),
        elevation: 0,
        title: const Text('Exercise library'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (_injuries.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Hiding moves that load: ${_injuries.trim()}',
                      style: const TextStyle(color: Color(0xFF7A8C78)),
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final label in ['', 'gentle', 'moderate', 'intense'])
                      ChoiceChip(
                        label: Text(label.isEmpty ? 'All' : label),
                        selected: _intensity == label,
                        onSelected: (_) {
                          setState(() => _intensity = label);
                          _load();
                        },
                      ),
                  ],
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!, style: const TextStyle(color: Color(0xFFD64545))),
                  ),
                const SizedBox(height: 12),
                if (_rows.isEmpty)
                  const Text('No exercises match these filters.')
                else
                  for (final row in _rows) _card(row),
              ],
            ),
    );
  }

  Widget _card(Map<String, dynamic> row) {
    final done = row['doneToday'] == true;
    final loads = row['loadsAreas'];
    final loadText = loads is List && loads.isNotEmpty ? 'Loads ${loads.join(', ')}' : 'No tagged load area';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row['name']?.toString() ?? '',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '${row['intensity']} · ${row['bodyArea']} · ${row['equipment']}',
            style: const TextStyle(color: Color(0xFF7A8C78), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(row['instructions']?.toString() ?? '', style: const TextStyle(height: 1.35)),
          const SizedBox(height: 4),
          Text(loadText, style: const TextStyle(fontSize: 12, color: Color(0xFF7A8C78))),
          if (row['videoUrl'] != null && row['videoUrl'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(row['videoUrl'].toString(), style: const TextStyle(fontSize: 12)),
            ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: done ? null : () => _complete(row),
            child: Text(done ? 'Done today' : 'Mark done'),
          ),
        ],
      ),
    );
  }
}
