// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_nanonets/otel_nanonets.dart';
import 'package:test/test.dart';

void main() {
  group('otel_nanonets', () {
    test('suppression toggles in zone', () async {
      expect(nanonetsInstrumentationSuppressed(), isFalse);
      await runWithoutNanonetsInstrumentationAsync(() async {
        expect(nanonetsInstrumentationSuppressed(), isTrue);
      });
      expect(nanonetsInstrumentationSuppressed(), isFalse);
    });

    test('NanonetsResult fields default null', () {
      const r = NanonetsResult();
      expect(r.statusCode, isNull);
    });
  });
}
