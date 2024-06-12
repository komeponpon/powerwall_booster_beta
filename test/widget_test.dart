import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:powerwall_booster_beta/main.dart';
import 'package:powerwall_booster_beta/model/token_provider.dart';

void main() {
  testWidgets('WelcomeScreen is displayed with initial token',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TokenProvider()),
        ],
        child: MyApp(),
      ),
    );

    // Verify that WelcomeScreen is displayed.
    expect(find.text('PW Booster'), findsOneWidget);
    expect(
        find.text("Let's use electricity more efficiently!"), findsOneWidget);
    // Verify that TokenProvider's initial access token is empty.
    expect(find.text('Access Token: '), findsOneWidget);
  });
}
