import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/model/sort_order.dart';
import 'package:shelf_master/src/screens/group_list/bloc/group_list_cubit.dart';
import 'package:shelf_master/src/screens/group_list/bloc/group_list_state.dart';
import 'package:shelf_master/src/screens/group_list/group_list_screen.dart';
import 'package:shelf_master/src/screens/keys.dart';

import '../../mock_responses.dart';
import '../../test_util.dart';

void main() {
  group('Group List Screen', () {
    testGoldens('initial state', (tester) async {
      // given
      final cubit = _getCubit(const GroupListState.init());

      // when
      await tester.pumpGroupListScreen(cubit);

      // then
      await tester.multiScreenGoldenTest(
        customPump: (tester) => tester.pump(const Duration(seconds: 1)),
      );
    });

    testGoldens('loaded state', (tester) async {
      // given
      final cubit = _getCubit(_mockLoadedState());

      // when
      await tester.pumpGroupListScreen(cubit);

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
      await tester.pumpGroupListScreen(cubit);
      await tester.tap(find.byKey(Keys.searchParamsKey));

      // then
      await tester.multiScreenGoldenTest();
    });

    testGoldens('error state', (tester) async {
      // given
      final cubit = _getCubit(const GroupListState.error());

      // when
      await tester.pumpGroupListScreen(cubit);

      // then
      await tester.multiScreenGoldenTest();
    });
  });
}

GroupListCubit _getCubit(GroupListState state) {
  return GroupListCubit(
    groupRepository: MockGroupRepository(),
    categoryRepository: MockCategoryRepository(),
    analyticsRepository: MockAnalyticsRepository(),
    initialState: state,
  );
}

GroupListState _mockLoadedState({
  SearchParams? searchParams,
}) {
  return GroupListState.loaded(
    groups: MockResponses.sampleGroups(),
    searchParams: searchParams ?? const SearchParams(),
    existingCategories: MockResponses.sampleCategories(),
  );
}

extension on WidgetTester {
  Future<void> pumpGroupListScreen(GroupListCubit cubit) {
    return pumpAppWidget(
      this,
      BlocProvider(
        create: (context) => cubit,
        child: const GroupListScreen(),
      ),
    );
  }
}
