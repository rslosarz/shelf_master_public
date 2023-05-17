import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/model/sort_order.dart';
import 'package:shelf_master/src/screens/item_list/bloc/item_list_cubit.dart';
import 'package:shelf_master/src/screens/item_list/bloc/item_list_state.dart';
import 'package:shelf_master/src/screens/item_list/item_list_screen.dart';
import 'package:shelf_master/src/screens/keys.dart';

import '../../mock_responses.dart';
import '../../test_util.dart';

void main() {
  group('Item List Screen', () {
    testGoldens('initial state', (tester) async {
      // given
      final cubit = _getCubit(const ItemListState.init());

      // when
      await tester.pumpItemListScreen(cubit);

      // then
      await tester.multiScreenGoldenTest(
        customPump: (tester) => tester.pump(const Duration(seconds: 1)),
      );
    });

    testGoldens('loaded state', (tester) async {
      // given
      final cubit = _getCubit(_mockLoadedState());

      // when
      await tester.pumpItemListScreen(cubit);

      // then
      await tester.multiScreenGoldenTest();
    });

    testGoldens('search params', (tester) async {
      // given
      final cubit = _getCubit(
        _mockLoadedState(
          searchParams: SearchParams(
            sortOrder: SortOrder.nameDesc,
            categories: MockResponses.sampleCategories(),
          ),
        ),
      );

      // when
      await tester.pumpItemListScreen(cubit);
      await tester.tap(find.byKey(Keys.searchParamsKey));

      // then
      await tester.multiScreenGoldenTest();
    });

    testGoldens('error state', (tester) async {
      // given
      final cubit = _getCubit(const ItemListState.error());

      // when
      await tester.pumpItemListScreen(cubit);

      // then
      await tester.multiScreenGoldenTest();
    });
  });
}

ItemListCubit _getCubit(ItemListState state) {
  return ItemListCubit(
    itemRepository: MockItemRepository(),
    categoryRepository: MockCategoryRepository(),
    analyticsRepository: MockAnalyticsRepository(),
    initialState: state,
  );
}

ItemListState _mockLoadedState({
  SearchParams? searchParams,
}) {
  return ItemListState.loaded(
    items: MockResponses.sampleItems(),
    searchParams: searchParams ?? const SearchParams(),
    existingCategories: MockResponses.sampleCategories(),
  );
}

extension on WidgetTester {
  Future<void> pumpItemListScreen(ItemListCubit cubit) {
    return pumpAppWidget(
      this,
      BlocProvider(
        create: (context) => cubit,
        child: const ItemListScreen(),
      ),
    );
  }
}
