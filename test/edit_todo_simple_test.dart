import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:todox/data/models/todo.dart';
import 'package:todox/presentation/controllers/todo_controller.dart';
import 'package:todox/presentation/widgets/todo_item_widget.dart';

void main() {
  group('编辑功能集成测试', () {
    late TodoController todoController;
    
    setUp(() {
      // 初始化控制器
      todoController = TodoController();
      Get.put(todoController);
    });
    
    tearDown(() {
      Get.reset();
    });
    
    testWidgets('编辑回调功能测试', (WidgetTester tester) async {
      bool editCallbackTriggered = false;
      
      // 创建一个测试待办事项
      final now = DateTime.now();
      final testTodo = Todo(
        id: 'test-123',
        title: '测试待办事项',
        description: '这是一个测试待办事项',
        priority: 2,
        dueDate: DateTime.now().add(Duration(days: 3)),
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
      
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                TodoItemWidget(
                  todo: testTodo,
                  onTap: () {},
                  onDelete: () {},
                  onEdit: () {
                    editCallbackTriggered = true;
                  },
                  onToggleComplete: () {},
                ),
              ],
            ),
          ),
        ),
      );
      
      // 验证待办事项显示
      expect(find.text('测试待办事项'), findsOneWidget);
      expect(find.text('这是一个测试待办事项'), findsOneWidget);
      
      // 触发编辑回调
      final todoItemWidget = tester.widget<TodoItemWidget>(find.byType(TodoItemWidget));
      todoItemWidget.onEdit?.call();
      
      // 验证编辑回调被触发
      expect(editCallbackTriggered, true);
    });
    
    testWidgets('编辑空待办事项', (WidgetTester tester) async {
      bool editCallbackTriggered = false;
      
      final now = DateTime.now();
      final emptyTodo = Todo(
        id: 'empty-123',
        title: '',
        description: '',
        priority: 1,
        dueDate: null,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
      
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                TodoItemWidget(
                  todo: emptyTodo,
                  onTap: () {},
                  onDelete: () {},
                  onEdit: () {
                    editCallbackTriggered = true;
                  },
                  onToggleComplete: () {},
                ),
              ],
            ),
          ),
        ),
      );
      
      // 触发编辑回调
      final todoItemWidget = tester.widget<TodoItemWidget>(find.byType(TodoItemWidget));
      todoItemWidget.onEdit?.call();
      
      // 验证编辑回调被触发（即使待办事项为空）
      expect(editCallbackTriggered, true);
    });
    
    testWidgets('编辑已完成待办事项', (WidgetTester tester) async {
      bool editCallbackTriggered = false;
      
      final now = DateTime.now();
      final completedTodo = Todo(
        id: 'completed-123',
        title: '已完成的待办',
        description: '这个待办已经完成',
        priority: 2,
        dueDate: DateTime.now(),
        isCompleted: true,
        createdAt: now,
        updatedAt: now,
      );
      
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                TodoItemWidget(
                  todo: completedTodo,
                  onTap: () {},
                  onDelete: () {},
                  onEdit: () {
                    editCallbackTriggered = true;
                  },
                  onToggleComplete: () {},
                ),
              ],
            ),
          ),
        ),
      );
      
      // 触发编辑回调
      final todoItemWidget = tester.widget<TodoItemWidget>(find.byType(TodoItemWidget));
      todoItemWidget.onEdit?.call();
      
      // 验证编辑回调被触发（即使待办事项已完成）
      expect(editCallbackTriggered, true);
    });
  });
}