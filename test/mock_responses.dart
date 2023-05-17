import 'package:mocktail/mocktail.dart';
import 'package:shelf_master/src/model/category.dart' as model;
import 'package:shelf_master/src/model/group.dart';
import 'package:shelf_master/src/model/item.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/repo/category_repository.dart';
import 'package:shelf_master/src/repo/group_repository.dart';
import 'package:shelf_master/src/repo/internal_storage_repository.dart';
import 'package:shelf_master/src/repo/item_repository.dart';

class MockItemRepository extends Mock implements ItemRepository {}

class MockGroupRepository extends Mock implements GroupRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockInternalStorageRepository extends Mock implements InternalStorageRepository {}

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

class MockResponses {
  static Group mockGroup({
    String? id,
    String? name,
    String? location,
    List<Item>? items,
  }) {
    return Group(
      id: id ?? 'id',
      name: name ?? 'groupName',
      locationDsc: location ?? 'location',
      items: items ?? [],
    );
  }

  static Item mockItem({
    String? id,
    String? name,
    Set<model.Category>? categories,
  }) {
    return Item(
      id: id ?? 'id',
      name: name ?? 'itemName',
      categories: categories ?? <model.Category>{},
    );
  }

  static model.Category mockCategory({
    String? id,
    String? name,
    String? colorHex,
  }) {
    return model.Category(
      id: id ?? 'id',
      name: name ?? 'categoryName',
      colorHex: colorHex ?? 'FF0000',
    );
  }

  static Set<model.Category> sampleCategories() {
    return {
      mockCategory(
        id: 'category1',
        name: 'category1',
        colorHex: 'FF0000',
      ),
      mockCategory(
        id: 'category2',
        name: 'category2',
        colorHex: '0000FF',
      ),
      mockCategory(
        id: 'category2',
        name: 'category2',
        colorHex: '00FF00',
      ),
    };
  }

  static List<Item> sampleItems() {
    return [
      mockItem(
        id: 'item1',
        name: 'item1',
        categories: sampleCategories(),
      ),
      mockItem(
        id: 'item2',
        name: 'item2',
        categories: {sampleCategories().first},
      ),
      mockItem(
        id: 'item3',
        name: 'item3',
        categories: {sampleCategories().elementAt(1)},
      ),
      mockItem(
        id: 'item4',
        name: 'item4',
        categories: {sampleCategories().elementAt(2)},
      ),
      mockItem(
        id: 'item5',
        name: 'item5',
        categories: {},
      ),
    ];
  }

  static List<Group> sampleGroups() {
    return [
      mockGroup(
        id: 'group1',
        name: 'group1',
        items: sampleItems(),
      ),
      mockGroup(
        id: 'group2',
        name: 'group2',
        items: [sampleItems().first],
      ),
      mockGroup(
        id: 'group3',
        name: 'group3',
        items: [sampleItems().elementAt(1)],
      ),
      mockGroup(
        id: 'group4',
        name: 'group4',
        items: [sampleItems().elementAt(2)],
      ),
      mockGroup(
        id: 'group5',
        name: 'group5',
        items: [],
      ),
    ];
  }
}
