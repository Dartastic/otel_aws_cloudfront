// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_cloudfront_suppression.dart';

class AwsCloudFrontResult {
  const AwsCloudFrontResult({
    this.distributionId,
    this.distributionDomain,
    this.edgeLocation,
    this.originName,
    this.cacheHit,
    this.bytes,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? distributionId;
  final String? distributionDomain;
  final String? edgeLocation;
  final String? originName;
  final bool? cacheHit;
  final int? bytes;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class AwsCloudFrontCallResult<T> {
  const AwsCloudFrontCallResult({required this.value, this.result});
  final T value;
  final AwsCloudFrontResult? result;
}

Future<T> tracedAwsCloudFront<T>({
  required String operation,
  required Future<AwsCloudFrontCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (awsCloudFrontInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_aws_cloudfront');
  final span = t.startSpan('cloudfront $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'aws-api')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.service', 'CloudFront')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.distributionId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'aws.cloudfront.distribution.id',
            res.distributionId!,
          )
        ]));
      }
      if (res.distributionDomain != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'aws.cloudfront.distribution.domain',
            res.distributionDomain!,
          )
        ]));
      }
      if (res.edgeLocation != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'aws.cloudfront.edge_location',
            res.edgeLocation!,
          )
        ]));
      }
      if (res.originName != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('aws.cloudfront.origin.name', res.originName!)
        ]));
      }
      if (res.cacheHit != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeBool('aws.cloudfront.cache.hit', res.cacheHit!)
        ]));
      }
      if (res.bytes != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('http.response.body.size', res.bytes!)]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('cloudfront.error.code', res.errorCode!)
        ]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'cloudfront.error',
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
