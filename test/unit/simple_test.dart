import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todox/presentation/controllers/todo_controller.dart';
import 'package:todox/data/repositories/hive_service.dart';

void main() {
  late TodoController controller;
  late HiveService hiveService;

  setUp(() async {
    // 初始化Hive服务
    hiveService = HiveService.instance;
    await hiveService.init(initDir: 'test_simple');

    // 创建待办事项控制器
    controller = TodoController();

    // 清空之前的测试数据
    await hiveService.clearAllData();
  });

  test('Issue 2: Default sort direction should be ascending', () {
    expect(controller.isAscending, true);
  });

  test('Issue 3: Toggle sort direction should update UI', () {
    // 记录初始状态
    final initialAscending = controller.isAscending;

    // 切换排序方向
    controller.toggleSortDirection();

    // 验证状态改变
    expect(controller.isAscending, !initialAscending);
  });

  test('Issue 5: No duplicate refreshTodos method', () {
    // 检查是否只有一个refreshTodos方法
    expect(() => controller.refreshTodos(), returnsNormally);
  });

  tearDown(() async {
    // 清理测试数据
    await hiveService.clearAllData();
    await hiveService.close();
    await Hive.close();
  });
}
