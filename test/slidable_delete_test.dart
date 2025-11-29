import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:todox/presentation/controllers/todo_controller.dart';
import 'package:todox/presentation/pages/home_page.dart';
import 'package:todox/presentation/widgets/todo_item_widget.dart';
import 'package:todox/data/models/todo.dart';

void main() {
  group('左滑删除功能测试', () {
    late TodoController todoController;

    setUp(() {
      // 初始化Getx控制器
      Get.testMode = true;
      todoController = TodoController();
      Get.put(todoController);
    });

    tearDown(() {
      // 清理测试环境
      Get.reset();
    });

    testWidgets('左滑待办事项应显示删除按钮', (WidgetTester tester) async {
      // 创建测试用的待办事项
      final testTodo = Todo.create(
        title: '测试待办事项',
        description: '这是一个测试描述',
        priority: 2,
      );

      // 构建测试用的Widget
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: TodoItemWidget(
              todo: testTodo,
              onTap: () {},
              onToggleComplete: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // 验证TodoItemWidget已渲染
      expect(find.byType(TodoItemWidget), findsOneWidget);
      expect(find.text('测试待办事项'), findsOneWidget);

      // 执行左滑手势
      await tester.fling(
        find.byType(TodoItemWidget),
        const Offset(-500, 0),
        1000,
      );
      await tester.pumpAndSettle();

      // 验证删除按钮已显示
      expect(find.byType(SlidableAction), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('点击删除按钮应调用onDelete回调', (WidgetTester tester) async {
      // 创建测试用的待办事项
      final testTodo = Todo.create(
        title: '测试待办事项',
        description: '这是一个测试描述',
        priority: 2,
      );

      bool deleteCalled = false;

      // 构建测试用的Widget
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: TodoItemWidget(
              todo: testTodo,
              onTap: () {},
              onToggleComplete: () {},
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      // 执行左滑手势
      await tester.fling(
        find.byType(TodoItemWidget),
        const Offset(-500, 0),
        1000,
      );
      await tester.pumpAndSettle();

      // 点击删除按钮
      await tester.tap(find.byType(SlidableAction));
      await tester.pumpAndSettle();

      // 验证onDelete回调被调用
      expect(deleteCalled, isTrue);
    });

    testWidgets('HomePage中左滑删除应直接删除待办事项', (WidgetTester tester) async {
      // 创建测试用的待办事项
      final testTodo = Todo.create(
        title: '测试待办事项',
        description: '这是一个测试描述',
        priority: 2,
      );

      // 使用测试辅助方法添加待办事项
      todoController.addTodoForTesting(testTodo);

      // 构建HomePage
      await tester.pumpWidget(GetMaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // 验证待办事项已显示
      expect(find.text('测试待办事项'), findsOneWidget);

      // 执行左滑手势
      await tester.fling(
        find.byType(TodoItemWidget),
        const Offset(-500, 0),
        1000,
      );
      await tester.pumpAndSettle();

      // 点击删除按钮
      await tester.tap(find.byType(SlidableAction));
      await tester.pumpAndSettle();

      // 验证待办事项已被删除
      expect(find.text('测试待办事项'), findsNothing);
    });
  });
}
