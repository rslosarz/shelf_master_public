import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shelf_master/src/screens/item_detail/bloc/item_detail_cubit.dart';
import 'package:shelf_master/src/screens/item_detail/bloc/item_detail_state.dart';
import 'package:shelf_master/src/screens/item_detail/item_detail_screen.dart';

import '../../mock_responses.dart';
import '../../test_util.dart';

void main() {
  group('Item Detail Screen', () {
    testGoldens('initial state', (tester) async {
      // given
      final cubit = _getCubit(const ItemDetailState.init());

      // when
      await tester.pumpItemDetailScreen(cubit);

      // then
      await tester.multiScreenGoldenTest(
        customPump: (tester) => tester.pump(const Duration(seconds: 1)),
      );
    });

    testGoldens('loaded state', (tester) async {
      // given
      final cubit = _getCubit(
        _mockLoadedState(),
      );

      // when
      await tester.pumpItemDetailScreen(cubit);

      // then
      await tester.multiScreenGoldenTest();
    });

    testGoldens('error state', (tester) async {
      // given
      final cubit = _getCubit(const ItemDetailState.noItem());

      // when
      await tester.pumpItemDetailScreen(cubit);

      // then
      await tester.multiScreenGoldenTest();
    });
  });
}

ItemDetailCubit _getCubit(ItemDetailState state) {
  return ItemDetailCubit(
    itemRepository: MockItemRepository(),
    groupRepository: MockGroupRepository(),
    categoryRepository: MockCategoryRepository(),
    internalStorageRepository: MockInternalStorageRepository(),
    analyticsRepository: MockAnalyticsRepository(),
    initialState: state,
  );
}

ItemDetailState _mockLoadedState() {
  return ItemDetailState.loaded(
    originalItem: MockResponses.mockItem(
      categories: MockResponses.sampleCategories(),
    ),
    currentItem: MockResponses.mockItem(),
    originalGroups: MockResponses.sampleGroups(),
    selectedGroups: MockResponses.sampleGroups(),
    availableGroups: MockResponses.sampleGroups(),
    availableCategories: MockResponses.sampleCategories(),
  );
}

extension on WidgetTester {
  Future<void> pumpItemDetailScreen(ItemDetailCubit cubit) {
    return pumpAppWidget(
      this,
      BlocProvider(
        create: (context) => cubit,
        child: const ItemDetailScreen(),
      ),
    );
  }
}
