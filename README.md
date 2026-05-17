# otel_aws_cloudfront

Dartastic OpenTelemetry bridge for AWS CloudFront (CDN).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_cloudfront/otel_aws_cloudfront.dart';

await tracedAwsCloudFront<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsCloudFrontCallResult(value: r, result: AwsCloudFrontResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsCloudFrontInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
