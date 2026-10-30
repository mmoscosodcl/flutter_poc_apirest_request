import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poc_apirest_request/main.dart';

void main() {
  testWidgets('App loads successfully and displays tabs and console toggle', (WidgetTester tester) async {
    await tester.pumpWidget(const ApiRestPocApp());

    // Verify Title and Tabs
    expect(find.text('REST API PoC'), findsOneWidget);
    expect(find.text('Open-Meteo (No Auth)'), findsOneWidget);
    expect(find.text('GitHub (Auth / Public)'), findsOneWidget);

    // Verify Console toggle is present
    expect(find.textContaining('Console: ON'), findsOneWidget);

    // Tap toggle to hide console
    await tester.tap(find.textContaining('Console: ON'));
    await tester.pumpAndSettle();

    // Verify toggle switched to OFF
    expect(find.textContaining('Console: OFF'), findsOneWidget);

    // Switch to GitHub Tab
    await tester.tap(find.text('GitHub (Auth / Public)'));
    await tester.pumpAndSettle();

    // Verify GitHub tab inputs
    expect(find.text('GitHub REST API'), findsOneWidget);
    expect(find.text('Send GitHub Request'), findsOneWidget);
  });
}
