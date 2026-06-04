// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_nanonets_suppression.dart';

class NanonetsResult {
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

class NanonetsCallResult<T> {
  const NanonetsCallResult({required this.value, this.result});
  final T value;
  final NanonetsResult? result;
}

Future<T> tracedNanonets<T>({
  required String operation,
  required Future<NanonetsCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (nanonetsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_nanonets');
  final span = t.startSpan('nanonets $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'nanonets')]));
    span.addAttributes(
        OTel.attributes([OTel.attributeString('gen_ai.system', 'nanonets')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.modelId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('gen_ai.request.model', res.modelId!)]));
      }
      if (res.modelType != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('nanonets.model.type', res.modelType!)]));
      }
      if (res.fileName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('file.name', res.fileName!)]));
      }
      if (res.fileSize != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeInt('file.size', res.fileSize!)]));
      }
      if (res.pageCount != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('nanonets.page_count', res.pageCount!)]));
      }
      if (res.predictionId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('nanonets.prediction.id', res.predictionId!)
        ]));
      }
      if (res.confidence != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeDouble('nanonets.confidence', res.confidence!)]));
      }
      if (res.fieldCount != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('nanonets.field_count', res.fieldCount!)]));
      }
      if (res.durationMs != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('nanonets.duration', res.durationMs!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('nanonets.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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
