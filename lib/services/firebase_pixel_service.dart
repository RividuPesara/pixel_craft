import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PixelUpdate {
  final int x;
  final int y;
  final Color? color;
  PixelUpdate(this.x, this.y, this.color);
}

class FirebasePixelService {
  final String roomId;
  final DatabaseReference _ref;
  StreamSubscription<DatabaseEvent>? _addedSub;
  StreamSubscription<DatabaseEvent>? _changedSub;

  FirebasePixelService(this.roomId)
    : _ref = FirebaseDatabase.instance.ref('rooms/$roomId/pixels');

  void listen(void Function(PixelUpdate) onUpdate) {
    _addedSub = _ref.onChildAdded.listen((event) {
      _handleEvent(event, onUpdate);
    });
    _changedSub = _ref.onChildChanged.listen((event) {
      _handleEvent(event, onUpdate);
    });
  }

  void _handleEvent(DatabaseEvent event, void Function(PixelUpdate) onUpdate) {
    final key = event.snapshot.key;
    if (key == null) return;
    final parts = key.split('_');
    if (parts.length != 2) return;
    final x = int.tryParse(parts[0]);
    final y = int.tryParse(parts[1]);
    if (x == null || y == null) return;

    final raw = event.snapshot.value;
    if (raw == null) {
      onUpdate(PixelUpdate(x, y, null));
      return;
    }

    int? colorInt;
    if (raw is int)
      colorInt = raw;
    else if (raw is String)
      colorInt = int.tryParse(raw);

    if (colorInt == null) return;

    onUpdate(PixelUpdate(x, y, Color(colorInt)));
  }

  Future<void> setPixel(int x, int y, Color? color) async {
    final key = '${x}_$y';
    if (color == null) {
      await _ref.child(key).remove();
    } else {
      await _ref.child(key).set(color.value);
    }
  }

  Future<void> fetchInitial(void Function(PixelUpdate) onUpdate) async {
    final snap = await _ref.get();
    if (!snap.exists) return;
    final data = snap.value as Map<dynamic, dynamic>?;
    if (data == null) return;
    data.forEach((k, v) {
      final key = k.toString();
      final parts = key.split('_');
      if (parts.length != 2) return;
      final x = int.tryParse(parts[0]);
      final y = int.tryParse(parts[1]);
      if (x == null || y == null) return;
      int? colorInt;
      if (v is int)
        colorInt = v;
      else if (v is String)
        colorInt = int.tryParse(v);
      onUpdate(PixelUpdate(x, y, colorInt == null ? null : Color(colorInt)));
    });
  }

  void dispose() {
    _addedSub?.cancel();
    _changedSub?.cancel();
  }
}
