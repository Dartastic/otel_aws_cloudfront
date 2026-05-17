// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_aws_cloudfront/otel_aws_cloudfront.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_cloudfront', () {
    test('suppression toggles in zone', () async {
      expect(awsCloudFrontInstrumentationSuppressed(), isFalse);
      await runWithoutAwsCloudFrontInstrumentationAsync(() async {
        expect(awsCloudFrontInstrumentationSuppressed(), isTrue);
      });
      expect(awsCloudFrontInstrumentationSuppressed(), isFalse);
    });

    test('AwsCloudFrontResult fields default null', () {
      const r = AwsCloudFrontResult();
      expect(r.statusCode, isNull);
    });
  });
}
