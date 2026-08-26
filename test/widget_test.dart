import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_gocatat/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GoCatatApp());
  });
}
