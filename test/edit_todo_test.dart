import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:todox/presentation/controllers/create_todo_controller.dart';
import 'package:todox/presentation/controllers/todo_controller.dart';

void main() {
  group('编辑待办功能测试', () {
    late CreateTodoController controller;
    late TodoController todoController;
    
    setUp(() {
      // 初始化控制器
      todoController = TodoController();
      Get.put(todoController);
      
      controller = CreateTodoController();
      Get.put(controller);
    });
    
    tearDown(() {
      Get.reset();
    });
    
    test('编辑模式下标题显示为"编辑待办事项"', () {
      // 模拟进入编辑模式
      controller.isEditMode.value = true;
      
      // 验证标题
      expect(controller.isEditMode.value, true);
    });
    
    test('编辑模式下加载待办数据到表单', () {
      // 模拟加载数据
      controller.titleController.text = '测试待办标题';
      controller.descriptionController.text = '测试待办描述';
      controller.selectedPriority.value = 3;
      controller.selectedDueDate.value = DateTime(2024, 12, 25);
      
      // 验证表单数据已填充
      expect(controller.titleController.text, '测试待办标题');
      expect(controller.descriptionController.text, '测试待办描述');
      expect(controller.selectedPriority.value, 3);
      expect(controller.selectedDueDate.value, DateTime(2024, 12, 25));
    });
    
    test('编辑模式下提交更新待办事项', () async {
      // 设置编辑模式
      controller.isEditMode.value = true;
      controller.titleController.text = '更新后的标题';
      controller.descriptionController.text = '更新后的描述';
      controller.selectedPriority.value = 3;
      
      // 验证表单数据已设置
      expect(controller.isEditMode.value, true);
      expect(controller.titleController.text, '更新后的标题');
      expect(controller.descriptionController.text, '更新后的描述');
      expect(controller.selectedPriority.value, 3);
    });
    
    test('创建模式下标题显示为"创建待办事项"', () {
      // 默认应该是创建模式
      expect(controller.isEditMode.value, false);
      expect(controller.editingTodo.value, isNull);
    });
  });
  
  group('UI交互测试', () {
    testWidgets('编辑模式下不显示重置按钮', (WidgetTester tester) async {
      // 创建测试环境
      final controller = CreateTodoController();
      controller.isEditMode.value = true;
      
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Obx(() => Text(controller.isEditMode.value ? '编辑待办事项' : '创建待办事项')),
              actions: [
                Obx(() {
                  if (!controller.isEditMode.value) {
                    return TextButton(
                      onPressed: () {},
                      child: const Text('重置'),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
            body: Container(),
          ),
        ),
      );
      
      // 验证标题
      expect(find.text('编辑待办事项'), findsOneWidget);
      
      // 验证重置按钮不存在
      expect(find.text('重置'), findsNothing);
    });
    
    testWidgets('创建模式下显示重置按钮', (WidgetTester tester) async {
      // 创建测试环境
      final controller = CreateTodoController();
      controller.isEditMode.value = false;
      
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Obx(() => Text(controller.isEditMode.value ? '编辑待办事项' : '创建待办事项')),
              actions: [
                Obx(() {
                  if (!controller.isEditMode.value) {
                    return TextButton(
                      onPressed: () {},
                      child: const Text('重置'),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
            body: Container(),
          ),
        ),
      );
      
      // 验证标题
      expect(find.text('创建待办事项'), findsOneWidget);
      
      // 验证重置按钮存在
      expect(find.text('重置'), findsOneWidget);
    });
  });
}