import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/core/icon_utils.dart';

void main() {
  group('IconUtils.getIconFromString', () {
    test('returns null for null input', () {
      expect(IconUtils.getIconFromString(null), isNull);
    });

    test('returns correct IconData for known icon strings', () {
      expect(IconUtils.getIconFromString('sentiment_satisfied'), equals(Icons.sentiment_satisfied));
      expect(IconUtils.getIconFromString('sentiment_neutral'), equals(Icons.sentiment_neutral));
      expect(IconUtils.getIconFromString('sentiment_dissatisfied'), equals(Icons.sentiment_dissatisfied));
      expect(IconUtils.getIconFromString('warning'), equals(Icons.warning));
      expect(IconUtils.getIconFromString('settings'), equals(Icons.settings));
      expect(IconUtils.getIconFromString('games'), equals(Icons.games));
      expect(IconUtils.getIconFromString('star'), equals(Icons.star));
      expect(IconUtils.getIconFromString('favorite'), equals(Icons.favorite));
      expect(IconUtils.getIconFromString('bolt'), equals(Icons.bolt));
      expect(IconUtils.getIconFromString('fire'), equals(Icons.local_fire_department));
      expect(IconUtils.getIconFromString('skull'), equals(Icons.sports_soccer));
      expect(IconUtils.getIconFromString('diamond'), equals(Icons.diamond));
      expect(IconUtils.getIconFromString('crown'), equals(Icons.emoji_events));
      expect(IconUtils.getIconFromString('rocket'), equals(Icons.rocket_launch));
      expect(IconUtils.getIconFromString('zombie'), equals(Icons.person));
      expect(IconUtils.getIconFromString('alien'), equals(Icons.face));
      expect(IconUtils.getIconFromString('robot'), equals(Icons.smart_toy));
      expect(IconUtils.getIconFromString('ghost'), equals(Icons.psychology));
      expect(IconUtils.getIconFromString('dragon'), equals(Icons.pets));
    });

    test('returns fallback IconData for unknown icon string', () {
      expect(IconUtils.getIconFromString('unknown_icon'), equals(Icons.games));
      expect(IconUtils.getIconFromString(''), equals(Icons.games));
      expect(IconUtils.getIconFromString('123'), equals(Icons.games));
    });
  });
} 