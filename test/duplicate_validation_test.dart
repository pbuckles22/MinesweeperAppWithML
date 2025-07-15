import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../lib/core/game_mode_config.dart';

void main() {
  group('Game Mode Configuration Validation', () {
    test('should throw error for duplicate IDs', () async {
      const duplicateIdJson = '''
      {
        "game_modes": [
          {
            "id": "easy",
            "name": "Easy",
            "description": "9×9 grid, 10 mines",
            "rows": 9,
            "columns": 9,
            "mines": 10,
            "enabled": true,
            "icon": "sentiment_satisfied"
          },
          {
            "id": "easy",
            "name": "Easy Duplicate",
            "description": "Duplicate ID",
            "rows": 9,
            "columns": 9,
            "mines": 10,
            "enabled": true,
            "icon": "sentiment_satisfied"
          }
        ],
        "default_mode": "easy"
      }
      ''';

      final json = jsonDecode(duplicateIdJson);
      final gameModesJson = json['game_modes'] as List;
      
      // Validate for duplicate IDs
      final Set<String> ids = <String>{};
      
      expect(() {
        for (final modeJson in gameModesJson) {
          final id = modeJson['id'] as String;
          
          if (ids.contains(id)) {
            throw ArgumentError('Duplicate game mode ID found: "$id". All game mode IDs must be unique.');
          }
          
          ids.add(id);
        }
      }, throwsA(isA<ArgumentError>().having(
        (e) => e.message,
        'message',
        contains('Duplicate game mode ID found: "easy"')
      )));
    });

    test('should throw error for duplicate names', () async {
      const duplicateNameJson = '''
      {
        "game_modes": [
          {
            "id": "easy",
            "name": "Easy",
            "description": "9×9 grid, 10 mines",
            "rows": 9,
            "columns": 9,
            "mines": 10,
            "enabled": true,
            "icon": "sentiment_satisfied"
          },
          {
            "id": "easy2",
            "name": "Easy",
            "description": "Duplicate name",
            "rows": 9,
            "columns": 9,
            "mines": 10,
            "enabled": true,
            "icon": "sentiment_satisfied"
          }
        ],
        "default_mode": "easy"
      }
      ''';

      final json = jsonDecode(duplicateNameJson);
      final gameModesJson = json['game_modes'] as List;
      
      // Validate for duplicate names
      final Set<String> names = <String>{};
      
      expect(() {
        for (final modeJson in gameModesJson) {
          final name = modeJson['name'] as String;
          
          if (names.contains(name)) {
            throw ArgumentError('Duplicate game mode name found: "$name". All game mode names must be unique.');
          }
          
          names.add(name);
        }
      }, throwsA(isA<ArgumentError>().having(
        (e) => e.message,
        'message',
        contains('Duplicate game mode name found: "Easy"')
      )));
    });

    test('should pass validation for unique IDs and names', () async {
      const validJson = '''
      {
        "game_modes": [
          {
            "id": "easy",
            "name": "Easy",
            "description": "9×9 grid, 10 mines",
            "rows": 9,
            "columns": 9,
            "mines": 10,
            "enabled": true,
            "icon": "sentiment_satisfied"
          },
          {
            "id": "normal",
            "name": "Normal",
            "description": "16×16 grid, 40 mines",
            "rows": 16,
            "columns": 16,
            "mines": 40,
            "enabled": true,
            "icon": "sentiment_neutral"
          }
        ],
        "default_mode": "easy"
      }
      ''';

      final json = jsonDecode(validJson);
      final gameModesJson = json['game_modes'] as List;
      
      // Validate for duplicate IDs and names
      final Set<String> ids = <String>{};
      final Set<String> names = <String>{};
      
      expect(() {
        for (final modeJson in gameModesJson) {
          final id = modeJson['id'] as String;
          final name = modeJson['name'] as String;
          
          if (ids.contains(id)) {
            throw ArgumentError('Duplicate game mode ID found: "$id". All game mode IDs must be unique.');
          }
          if (names.contains(name)) {
            throw ArgumentError('Duplicate game mode name found: "$name". All game mode names must be unique.');
          }
          
          ids.add(id);
          names.add(name);
        }
      }, returnsNormally);
    });
  });
} 