# otel_nanonets

Dartastic OpenTelemetry bridge for Nanonets (OCR + document AI).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_nanonets/otel_nanonets.dart';

await tracedNanonets<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return NanonetsCallResult(value: r, result: NanonetsResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutNanonetsInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
