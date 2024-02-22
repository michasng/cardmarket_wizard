import 'package:cardmarket_wizard/components/rate_limiter.dart';
import 'package:cardmarket_wizard/components/retry.dart';
import 'package:puppeteer/puppeteer.dart';

final RateLimiter _rateLimiter = RateLimiter(
  const Duration(seconds: 1),
);

extension BetterGoTo on Page {
  Future<Response> betterGoTo(String url) async {
    return await _rateLimiter.execute(
      () => withRetry(
        () => goto(url),
        maxAttemptCount: 5,
        initialDelay: const Duration(seconds: 2),
        maxDelay: const Duration(seconds: 60),
      ),
    );
  }
}
