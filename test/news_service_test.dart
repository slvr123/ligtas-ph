import 'package:flutter_test/flutter_test.dart';
import 'package:disaster_awareness_app/services/news_service.dart';

void main() {
  group('NewsService.parseRssDate', () {
    final svc = NewsService();

    test('parses RFC822 with weekday and GMT', () {
      final d = svc.parseRssDate('Mon, 15 Jan 2024 10:30:00 GMT');
      expect(d.year, 2024);
      expect(d.month, 1);
      expect(d.day, 15);
    });

    test('parses with numeric offset', () {
      final d = svc.parseRssDate('15 Jan 2024 10:30:00 +0800');
      expect(d.year, 2024);
      expect(d.month, 1);
      expect(d.day, 15);
    });

    test('parses without seconds', () {
      final d = svc.parseRssDate('15 Jan 2024 10:30');
      expect(d.year, 2024);
      expect(d.month, 1);
      expect(d.day, 15);
    });

    test('falls back to now on empty', () {
      final d = svc.parseRssDate('');
      expect(d, isA<DateTime>());
    });
  });
}
