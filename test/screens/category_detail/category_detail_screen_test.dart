import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/model/sort_order.dart';
import 'package:shelf_master/src/screens/category_detail/bloc/category_detail_cubit.dart';
import 'package:shelf_master/src/screens/category_detail/bloc/category_detail_state.dart';
import 'package:shelf_master/src/screens/category_detail/category_detail_screen.dart';
import 'package:shelf_master/src/screens/keys.dart';

import '../../mock_responses.dart';
import '../../test_util.dart';

void main() {
  group('Category Detail Screen', () {
    testGoldens('initial state', (tester) async {
      // given
      final cubit = _getCubit(const CategoryDetailState.init());

      // when
      await tester.pumpCategoryDetailScreen(cubit);

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
      await tester.pumpCategoryDetailScreen(cubit);

      // then
      await tester.multiScreenGoldenTest();
    });

    testGoldens('search params', (tester) async {
      // given
      final cubit = _getCubit(
        _mockLoadedState(
          searchParams: const SearchParams(
            sortOrder: SortOrder.nameDesc,
          ),
        ),
      );

      // when
      await tester.pumpCategoryDetailScreen(cubit);
      await tester.tap(find.byKey(Keys.searchParamsKey));

      // then
      await tester.multiScreenGoldenTest();
    });

    testGoldens('error state', (tester) async {
      // given
      final cubit = _getCubit(const CategoryDetailState.notFound());

      // when
      await tester.pumpCategoryDetailScreen(cubit);

      // then
      await tester.multiScreenGoldenTest();
    });
  });
}

CategoryDetailCubit _getCubit(CategoryDetailState state) {
  return CategoryDetailCubit(
    itemRepository: MockItemRepository(),
    categoryRepository: MockCategoryRepository(),
    analyticsRepository: MockAnalyticsRepository(),
    initialState: state,
  );
}

CategoryDetailState _mockLoadedState({
  SearchParams? searchParams,
}) {
  return CategoryDetailState.loaded(
    category: MockResponses.mockCategory(),
    originalName: MockResponses.mockCategory().name,
    queriedItems: MockResponses.sampleItems(),
    searchParams: searchParams ?? const SearchParams(),
  );
}

extension on WidgetTester {
  Future<void> pumpCategoryDetailScreen(CategoryDetailCubit cubit) {
    return pumpAppWidget(
      this,
      BlocProvider(
        create: (context) => cubit,
        child: const CategoryDetailScreen(),
      ),
    );
  }
}
