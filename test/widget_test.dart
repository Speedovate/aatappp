import 'package:flutter_test/flutter_test.dart';

import 'package:aatappp/main.dart';

void main() {
  testWidgets('renders AATAPPP website shell', (tester) async {
    await tester.pumpWidget(const AatapppWebsiteApp());

    expect(
      find.text(
        'We champion accredited hospitality in Puerto Princesa and Palawan.',
      ),
      findsOneWidget,
    );
  });
}
