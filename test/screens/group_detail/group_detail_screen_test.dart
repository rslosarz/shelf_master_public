import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shelf_master/src/model/search_params.dart';
import 'package:shelf_master/src/model/sort_order.dart';
import 'package:shelf_master/src/screens/group_detail/bloc/group_detail_cubit.dart';
import 'package:shelf_master/src/screens/group_detail/bloc/group_detail_state.dart';
import 'package:shelf_master/src/screens/group_detail/group_detail_screen.dart';
import 'package:shelf_master/src/screens/keys.dart';

import '../../mock_responses.dart';
import '../../test_util.dart';

void main() {
  group('Group Detail Screen', () {
    testGoldens('initial state', (tester) async {
      // given
      final cubit = _getCubit(const GroupDetailState.init());

      // when
      await tester.pumpGroupDetailScreen(cubit);

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
      await tester.pumpGroupDetailScreen(cubit);

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
      await tester.pumpGroupDetailScreen(cubit);
      await tester.tap(find.byKey(Keys.searchParamsKey));

      // then
      await tester.multiScreenGoldenTest();
    });

    testGoldens('error state', (tester) async {
      // given
      final cubit = _getCubit(const GroupDetailState.notFound());

      // when
      await tester.pumpGroupDetailScreen(cubit);

      // then
      await tester.multiScreenGoldenTest();
    });
  });
}

GroupDetailCubit _getCubit(GroupDetailState state) {
  return GroupDetailCubit(
    itemRepository: MockItemRepository(),
    groupRepository: MockGroupRepository(),
    analyticsRepository: MockAnalyticsRepository(),
    initialState: state,
  );
}

GroupDetailState _mockLoadedState({
  SearchParams? searchParams,
}) {
  return GroupDetailState.loaded(
    originalGroup: MockResponses.mockGroup(),
    currentGroup: MockResponses.mockGroup(),
    queriedItems: MockResponses.sampleItems(),
    searchParams: searchParams ?? const SearchParams(),
    existingCategories: MockResponses.sampleCategories(),
  );
}

extension on WidgetTester {
  Future<void> pumpGroupDetailScreen(GroupDetailCubit cubit) {
    return pumpAppWidget(
      this,
      BlocProvider(
        create: (context) => cubit,
        child: const GroupDetailScreen(),
      ),
    );
  }
}
