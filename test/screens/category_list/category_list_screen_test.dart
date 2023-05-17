import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/model/sort_order.dart';
import 'package:shelf_master/src/screens/category_list/bloc/category_list_cubit.dart';
import 'package:shelf_master/src/screens/category_list/bloc/category_list_state.dart';
import 'package:shelf_master/src/screens/category_list/category_list_screen.dart';
import 'package:shelf_master/src/screens/keys.dart';

import '../../mock_responses.dart';
import '../../test_util.dart';

void main() {
  group('Category List Screen', () {
    testGoldens('initial state', (tester) async {
      // given
      final cubit = _getCubit(const CategoryListState.init());

      // when
      await tester.pumpCategoryListScreen(cubit);

      // then
      await tester.multiScreenGoldenTest(
        customPump: (tester) => tester.pump(const Duration(seconds: 1)),
      );
    });

    testGoldens('loaded state', (tester) async {
      // given
      final cubit = _getCubit(_mockLoadedState());

      // when
      await tester.pumpCategoryListScreen(cubit);

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
      await tester.pumpCategoryListScreen(cubit);
      await tester.tap(find.byKey(Keys.searchParamsKey));

      // then
      await tester.multiScreenGoldenTest();
    });

    testGoldens('error state', (tester) async {
      // given
      final cubit = _getCubit(const CategoryListState.error());

      // when
      await tester.pumpCategoryListScreen(cubit);

      // then
      await tester.multiScreenGoldenTest();
    });
  });
}

CategoryListCubit _getCubit(CategoryListState state) {
  return CategoryListCubit(
    categoryRepository: MockCategoryRepository(),
    analyticsRepository: MockAnalyticsRepository(),
    initialState: state,
  );
}

CategoryListState _mockLoadedState({
  SearchParams? searchParams,
}) {
  return CategoryListState.loaded(
    categories: MockResponses.sampleCategories().toList(),
    searchParams: searchParams ?? const SearchParams(),
  );
}

extension on WidgetTester {
  Future<void> pumpCategoryListScreen(CategoryListCubit cubit) {
    return pumpAppWidget(
      this,
      BlocProvider(
        create: (context) => cubit,
        child: const CategoryListScreen(),
      ),
    );
  }
}
