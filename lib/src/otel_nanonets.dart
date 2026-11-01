// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_nanonets_suppression.dart';

class NanonetsResult {
  /// Creates a result.
  const NanonetsResult({
    this.modelId,
    this.modelType,
    this.fileName,
    this.fileSize,
    this.pageCount,
    this.predictionId,
    this.confidence,
    this.fieldCount,
    this.durationMs,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? modelId;
  final String? modelType;
  final String? fileName;
  final int? fileSize;
  final int? pageCount;
  final String? predictionId;
  final double? confidence;
  final int? fieldCount;
  final int? durationMs;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class NanonetsCallResult<T> {
  /// Creates a call result.
  const NanonetsCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final NanonetsResult? result;
}

Future<T> tracedNanonets<T>({
  required String operation,
  required Future<NanonetsCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (nanonetsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_nanonets');
  final span = t.startSpan('nanonets $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.system', 'nanonets')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('gen_ai.system', 'nanonets')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.modelId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gen_ai.request.model', res.modelId!)]));
      }
      if (res.modelType != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('nanonets.model.type', res.modelType!)]));
      }
      if (res.fileName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('file.name', res.fileName!)]));
      }
      if (res.fileSize != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('file.size', res.fileSize!)]));
      }
      if (res.pageCount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('nanonets.page_count', res.pageCount!)]));
      }
      if (res.predictionId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('nanonets.prediction.id', res.predictionId!)
        ]));
      }
      if (res.confidence != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('nanonets.confidence', res.confidence!)]));
      }
      if (res.fieldCount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('nanonets.field_count', res.fieldCount!)]));
      }
      if (res.durationMs != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('nanonets.duration', res.durationMs!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('nanonets.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'nanonets.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
