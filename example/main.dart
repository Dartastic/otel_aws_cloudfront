// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_cloudfront/otel_aws_cloudfront.dart';

/// Traces Aws Cloudfront calls with OpenTelemetry.
///
/// `otel_aws_cloudfront` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Cloudfront call in
/// [tracedAwsCloudFront]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-cloudfront-example');

  // Traces a Aws Cloudfront call.
  final awsCloudFrontId = await tracedAwsCloudFront<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Cloudfront call here, then report what it returned.
      const id = 'aws_cloudfront_8f3a2c';
      return const AwsCloudFrontCallResult(
          value: id,
          result: AwsCloudFrontResult(
              distributionId: 'distribution_8f3a2c',
              distributionDomain: 'example',
              edgeLocation: 'example',
              originName: 'example',
              cacheHit: true,
              bytes: 512,
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsCloudFront create returned $awsCloudFrontId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsCloudFrontInstrumentationAsync.
  await runWithoutAwsCloudFrontInstrumentationAsync(
    () => tracedAwsCloudFront<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_cloudfront_8f3a2c';
        return const AwsCloudFrontCallResult(
            value: id,
            result: AwsCloudFrontResult(
                distributionId: 'distribution_8f3a2c',
                distributionDomain: 'example',
                edgeLocation: 'example',
                originName: 'example',
                cacheHit: true,
                bytes: 512,
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
