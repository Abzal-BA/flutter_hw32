import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hw32/di/service_locator.dart';
import 'package:flutter_hw32/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_hw32/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter_hw32/features/items/data/api_client.dart';
import 'package:flutter_hw32/features/items/data/fake_server_api_client.dart';
import 'package:flutter_hw32/features/items/data/in_memory_items_db.dart';
import 'package:flutter_hw32/main.dart';

import '../test/helpers/fake_auth_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository authRepository;
  late FakeServerApiClient apiClient;
  late InMemoryItemsDb itemsDb;

  setUp(() async {
    authRepository = FakeAuthRepository();
    apiClient = FakeServerApiClient();
    itemsDb = InMemoryItemsDb();

    await resetDependencies();
    await setupDependencies(
      overrides: DependencyOverrides(
        authRepository: authRepository,
        apiClient: apiClient,
        itemsDb: itemsDb,
      ),
      registerNotifications: false,
    );
  });

  tearDown(() async {
    await authRepository.dispose();
    await resetDependencies();
  });

  testWidgets('login, load list, add item, sign out with test DI', (
    tester,
  ) async {
    expect(getIt<IAuthRepository>(), same(authRepository));
    expect(getIt<ApiClient>(), same(apiClient));

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>(
        create: (_) => getIt<AuthController>(),
        child: const MaterialApp(home: AuthGate()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('emailField')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('passwordField')),
      'secret123',
    );
    await tester.tap(find.byKey(const ValueKey<String>('submitAuthButton')));
    await tester.pumpAndSettle();

    expect(authRepository.signInCalls, 1);
    expect(find.text('Current Tasks'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('itemsList')), findsOneWidget);
    expect(find.text('Read CI guide'), findsOneWidget);
    expect(apiClient.fetchCalls, 1);

    await tester.enterText(
      find.byKey(const ValueKey<String>('itemTitleField')),
      'Write integration test',
    );
    await tester.tap(find.byKey(const ValueKey<String>('addItemButton')));
    await tester.pumpAndSettle();

    expect(find.text('Write integration test'), findsOneWidget);
    expect(apiClient.createCalls, 1);
    expect(find.textContaining('Status: To Do'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('itemTile_item-1')));
    await tester.pumpAndSettle();

    expect(find.text('Edit Task'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('taskStatusField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('saveTaskStatusButton')),
    );
    await tester.pumpAndSettle();

    expect(apiClient.updateCalls, 1);
    expect(find.textContaining('Status: Done'), findsWidgets);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('drawerSignOutButton')));
    await tester.pumpAndSettle();

    expect(authRepository.signOutCalls, 1);
    expect(find.text('Login'), findsOneWidget);
  });
}
