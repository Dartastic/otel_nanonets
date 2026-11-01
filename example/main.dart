// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_nanonets/otel_nanonets.dart';

/// Traces Nanonets calls with OpenTelemetry.
///
/// `otel_nanonets` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Nanonets call in
/// [tracedNanonets]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'nanonets-example');

  // Traces a Nanonets call.
  final nanonetsId = await tracedNanonets<String>(
    operation: 'create',
    invoke: () async {
      // Make the Nanonets call here, then report what it returned.
      const id = 'nanonets_8f3a2c';
      return const NanonetsCallResult(
          value: id,
          result: NanonetsResult(
              modelId: 'model_8f3a2c',
              modelType: 'standard',
              fileName: 'example',
              fileSize: 512,
              pageCount: 3,
              predictionId: 'prediction_8f3a2c',
              confidence: 0.5,
              fieldCount: 3,
              durationMs: 120,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedNanonets create returned $nanonetsId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutNanonetsInstrumentationAsync.
  await runWithoutNanonetsInstrumentationAsync(
    () => tracedNanonets<String>(
      operation: 'create',
      invoke: () async {
        const id = 'nanonets_8f3a2c';
        return const NanonetsCallResult(
            value: id,
            result: NanonetsResult(
                modelId: 'model_8f3a2c',
                modelType: 'standard',
                fileName: 'example',
                fileSize: 512,
                pageCount: 3,
                predictionId: 'prediction_8f3a2c',
                confidence: 0.5,
                fieldCount: 3,
                durationMs: 120,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
