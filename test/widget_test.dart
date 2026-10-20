import 'package:flutter_test/flutter_test.dart';
import 'package:life_plus/main.dart';

void main() {
  testWidgets('login and registration screens navigate to each other', (
    tester,
  ) async {
    await tester.pumpWidget(const LifePlusApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Join LIFE+'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
