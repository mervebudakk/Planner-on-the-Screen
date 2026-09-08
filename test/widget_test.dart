import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aesthetic_planner/core/services/storage_service.dart';
import 'package:aesthetic_planner/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  testWidgets('AestheticPlannerApp loads and displays welcome screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'language': 'tr'});
    final storageService = await StorageService.init();

    await tester.pumpWidget(AestheticPlannerApp(storageService: storageService));
    await tester.pumpAndSettle();

    expect(find.byType(AestheticPlannerApp), findsOneWidget);
  });
}
