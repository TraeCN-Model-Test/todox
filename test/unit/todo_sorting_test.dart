import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:todox/data/models/todo.dart';
import 'package:todox/presentation/controllers/todo_controller.dart';
import 'package:todox/data/repositories/hive_service.dart';

void main() {
  late TodoController todoController;
  late HiveService hiveService;

  setUp(() async {
    // 初始化Hive服务
    hiveService = HiveService.instance;
    await hiveService.init(initDir: 'test_todos');
    
    // 清空之前的测试数据
    await hiveService.clearAllData();
    
    // 创建待办事项控制器
    todoController = TodoController();
  });

  tearDown(() async {
    // 清理测试数据
    await hiveService.clearAllData();
    await hiveService.close();
    await Hive.close();
  });

  group('TodoController Sorting Tests', () {
    test('should sort todos by time in ascending order by default', () async {
      // 添加测试待办事项，按创建时间倒序排列
      final now = DateTime.now();
      final todo1 = Todo(
        id: '1',
        title: 'Todo 1',
        createdAt: DateTime(2023, 1, 3),
        updatedAt: now,
      );
      final todo2 = Todo(
        id: '2',
        title: 'Todo 2',
        createdAt: DateTime(2023, 1, 2),
        updatedAt: now,
      );
      final todo3 = Todo(
        id: '3',
        title: 'Todo 3',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: now,
      );
      
      await hiveService.addTodo(todo1);
      await hiveService.addTodo(todo2);
      await hiveService.addTodo(todo3);
      
      // 加载待办事项
      await todoController.loadTodos();
      
      // 验证排序结果
      expect(todoController.displayTodos[0].id, todo3.id);
      expect(todoController.displayTodos[1].id, todo2.id);
      expect(todoController.displayTodos[2].id, todo1.id);
    });

    test('should sort todos by time in descending order when toggled', () async {
      // 添加测试待办事项，按创建时间倒序排列
      final now = DateTime.now();
      final todo1 = Todo(
        id: '1',
        title: 'Todo 1',
        createdAt: DateTime(2023, 1, 3),
        updatedAt: now,
      );
      final todo2 = Todo(
        id: '2',
        title: 'Todo 2',
        createdAt: DateTime(2023, 1, 2),
        updatedAt: now,
      );
      final todo3 = Todo(
        id: '3',
        title: 'Todo 3',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: now,
      );
      
      await hiveService.addTodo(todo1);
      await hiveService.addTodo(todo2);
      await hiveService.addTodo(todo3);
      
      // 加载待办事项
      await todoController.loadTodos();
      
      // 切换排序方向
      todoController.toggleSortDirection();
      
      // 验证排序结果
      expect(todoController.displayTodos[0].id, todo1.id);
      expect(todoController.displayTodos[1].id, todo2.id);
      expect(todoController.displayTodos[2].id, todo3.id);
    });

    test('should sort todos by priority in ascending order', () async {
      // 添加测试待办事项，按优先级倒序排列
      final now = DateTime.now();
      final todo1 = Todo(
        id: '1',
        title: 'Todo 1',
        createdAt: now,
        updatedAt: now,
        priority: 3,
      );
      final todo2 = Todo(
        id: '2',
        title: 'Todo 2',
        createdAt: now,
        updatedAt: now,
        priority: 2,
      );
      final todo3 = Todo(
        id: '3',
        title: 'Todo 3',
        createdAt: now,
        updatedAt: now,
        priority: 1,
      );
      
      await hiveService.addTodo(todo1);
      await hiveService.addTodo(todo2);
      await hiveService.addTodo(todo3);
      
      // 加载待办事项
      await todoController.loadTodos();
      
      // 设置排序方式为优先级
      todoController.setSortBy('priority');
      
      // 验证排序结果
      expect(todoController.displayTodos[0].id, todo3.id);
      expect(todoController.displayTodos[1].id, todo2.id);
      expect(todoController.displayTodos[2].id, todo1.id);
    });

    test('should sort todos by priority in descending order when toggled', () async {
      // 添加测试待办事项，按优先级倒序排列
      final now = DateTime.now();
      final todo1 = Todo(
        id: '1',
        title: 'Todo 1',
        createdAt: now,
        updatedAt: now,
        priority: 3,
      );
      final todo2 = Todo(
        id: '2',
        title: 'Todo 2',
        createdAt: now,
        updatedAt: now,
        priority: 2,
      );
      final todo3 = Todo(
        id: '3',
        title: 'Todo 3',
        createdAt: now,
        updatedAt: now,
        priority: 1,
      );
      
      await hiveService.addTodo(todo1);
      await hiveService.addTodo(todo2);
      await hiveService.addTodo(todo3);
      
      // 加载待办事项
      await todoController.loadTodos();
      
      // 设置排序方式为优先级
      todoController.setSortBy('priority');
      
      // 切换排序方向
      todoController.toggleSortDirection();
      
      // 验证排序结果
      expect(todoController.displayTodos[0].id, todo1.id);
      expect(todoController.displayTodos[1].id, todo2.id);
      expect(todoController.displayTodos[2].id, todo3.id);
    });

    test('should sort todos by title in ascending order', () async {
      // 添加测试待办事项，按标题倒序排列
      final now = DateTime.now();
      final todo1 = Todo(
        id: '1',
        title: 'C Todo',
        createdAt: now,
        updatedAt: now,
      );
      final todo2 = Todo(
        id: '2',
        title: 'B Todo',
        createdAt: now,
        updatedAt: now,
      );
      final todo3 = Todo(
        id: '3',
        title: 'A Todo',
        createdAt: now,
        updatedAt: now,
      );
      
      await hiveService.addTodo(todo1);
      await hiveService.addTodo(todo2);
      await hiveService.addTodo(todo3);
      
      // 加载待办事项
      await todoController.loadTodos();
      
      // 设置排序方式为标题
      todoController.setSortBy('title');
      
      // 验证排序结果
      expect(todoController.displayTodos[0].id, todo3.id);
      expect(todoController.displayTodos[1].id, todo2.id);
      expect(todoController.displayTodos[2].id, todo1.id);
    });

    test('should sort todos by title in descending order when toggled', () async {
      // 添加测试待办事项，按标题倒序排列
      final now = DateTime.now();
      final todo1 = Todo(
        id: '1',
        title: 'C Todo',
        createdAt: now,
        updatedAt: now,
      );
      final todo2 = Todo(
        id: '2',
        title: 'B Todo',
        createdAt: now,
        updatedAt: now,
      );
      final todo3 = Todo(
        id: '3',
        title: 'A Todo',
        createdAt: now,
        updatedAt: now,
      );
      
      await hiveService.addTodo(todo1);
      await hiveService.addTodo(todo2);
      await hiveService.addTodo(todo3);
      
      // 加载待办事项
      await todoController.loadTodos();
      
      // 设置排序方式为标题
      todoController.setSortBy('title');
      
      // 切换排序方向
      todoController.toggleSortDirection();
      
      // 验证排序结果
      expect(todoController.displayTodos[0].id, todo1.id);
      expect(todoController.displayTodos[1].id, todo2.id);
      expect(todoController.displayTodos[2].id, todo3.id);
    });

    test('should sort todos by due date in ascending order', () async {
      // 添加测试待办事项，按截止日期倒序排列
      final now = DateTime.now();
      final todo1 = Todo(
        id: '1',
        title: 'Todo 1',
        createdAt: now,
        updatedAt: now,
        dueDate: DateTime(2023, 1, 3),
      );
      final todo2 = Todo(
        id: '2',
        title: 'Todo 2',
        createdAt: now,
        updatedAt: now,
        dueDate: DateTime(2023, 1, 2),
      );
      final todo3 = Todo(
        id: '3',
        title: 'Todo 3',
        createdAt: now,
        updatedAt: now,
        dueDate: DateTime(2023, 1, 1),
      );
      final todo4 = Todo(
        id: '4',
        title: 'Todo 4', // 无截止日期
        createdAt: now,
        updatedAt: now,
      );
      
      await hiveService.addTodo(todo1);
      await hiveService.addTodo(todo2);
      await hiveService.addTodo(todo3);
      await hiveService.addTodo(todo4);
      
      // 加载待办事项
      await todoController.loadTodos();
      
      // 设置排序方式为截止日期
      todoController.setSortBy('dueDate');
      
      // 验证排序结果：有截止日期的在前，按日期升序，无截止日期的在后
      expect(todoController.displayTodos[0].id, todo3.id);
      expect(todoController.displayTodos[1].id, todo2.id);
      expect(todoController.displayTodos[2].id, todo1.id);
      expect(todoController.displayTodos[3].id, todo4.id);
    });

    test('should sort todos by due date in descending order when toggled', () async {
      // 添加测试待办事项，按截止日期倒序排列
      final now = DateTime.now();
      final todo1 = Todo(
        id: '1',
        title: 'Todo 1',
        createdAt: now,
        updatedAt: now,
        dueDate: DateTime(2023, 1, 3),
      );
      final todo2 = Todo(
        id: '2',
        title: 'Todo 2',
        createdAt: now,
        updatedAt: now,
        dueDate: DateTime(2023, 1, 2),
      );
      final todo3 = Todo(
        id: '3',
        title: 'Todo 3',
        createdAt: now,
        updatedAt: now,
        dueDate: DateTime(2023, 1, 1),
      );
      final todo4 = Todo(
        id: '4',
        title: 'Todo 4', // 无截止日期
        createdAt: now,
        updatedAt: now,
      );
      
      await hiveService.addTodo(todo1);
      await hiveService.addTodo(todo2);
      await hiveService.addTodo(todo3);
      await hiveService.addTodo(todo4);
      
      // 加载待办事项
      await todoController.loadTodos();
      
      // 设置排序方式为截止日期
      todoController.setSortBy('dueDate');
      
      // 切换排序方向
      todoController.toggleSortDirection();
      
      // 验证排序结果：无截止日期的在前，有截止日期的按日期降序
      expect(todoController.displayTodos[0].id, todo4.id);
      expect(todoController.displayTodos[1].id, todo1.id);
      expect(todoController.displayTodos[2].id, todo2.id);
      expect(todoController.displayTodos[3].id, todo3.id);
    });
  });
}
