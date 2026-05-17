// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

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
