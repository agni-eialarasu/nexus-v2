import 'package:flutter_test/flutter_test.dart';
import 'package:nexus/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NexusApp());

    expect(find.text('Nexus'), findsOneWidget);
    expect(find.text('Project Portfolio Management'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
