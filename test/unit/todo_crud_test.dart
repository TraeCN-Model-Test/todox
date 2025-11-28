import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:todox/data/models/todo.dart';
import 'package:todox/presentation/controllers/todo_controller.dart';
import 'package:todox/data/repositories/hive_service.dart';

void main() {
  // 初始化Flutter绑定
  WidgetsFlutterBinding.ensureInitialized();

  late TodoController todoController;
  late HiveService hiveService;

  setUp(() async {
    // 初始化Hive服务
    hiveService = HiveService.instance;
    await hiveService.init(initDir: 'test_todos');

    // 创建待办事项控制器，传入模拟的showSnackbar函数
    todoController = TodoController(
      showSnackbar: (title, message) {
        print('Snackbar: $title - $message');
      },
    );

    // 清空之前的测试数据
    await hiveService.clearAllData();
  });

  tearDown(() async {
    // 清理测试数据
    await hiveService.clearAllData();
    await hiveService.close();
    await Hive.close();
  });

  group('TodoController CRUD Tests', () {
    test('should add a new todo', () async {
      // 添加待办事项
      final now = DateTime.now();
      await todoController.addTodo(
        title: 'Test Todo',
        description: 'Test Description',
        dueDate: DateTime(2023, 12, 31),
        priority: 2,
        tags: ['test', 'flutter'],
      );

      // 验证待办事项是否添加成功
      expect(todoController.todoCount, 1);
      expect(todoController.incompleteTodoCount, 1);
      expect(todoController.completedTodoCount, 0);

      // 验证待办事项内容
      final todo = todoController.todos.first;
      expect(todo.title, 'Test Todo');
      expect(todo.description, 'Test Description');
      expect(todo.dueDate, DateTime(2023, 12, 31));
      expect(todo.priority, 2);
      expect(todo.tags, ['test', 'flutter']);
      expect(todo.isCompleted, false);
    });

    test('should update an existing todo', () async {
      // 添加待办事项
      final now = DateTime.now();
      await todoController.addTodo(
        title: 'Test Todo',
        description: 'Test Description',
      );

      // 获取待办事项
      final todo = todoController.todos.first;

      // 更新待办事项
      final updatedTodo = todo.copyWith(
        title: 'Updated Todo',
        description: 'Updated Description',
        isCompleted: true,
      );
      await todoController.updateTodo(updatedTodo);

      // 验证待办事项是否更新成功
      final todos = todoController.todos;
      expect(todos.length, 1);
      expect(todos[0].title, 'Updated Todo');
      expect(todos[0].description, 'Updated Description');
      expect(todos[0].isCompleted, true);
      expect(todoController.completedTodoCount, 1);
      expect(todoController.incompleteTodoCount, 0);
    });

    test('should delete an existing todo', () async {
      // 添加待办事项
      final now = DateTime.now();
      await todoController.addTodo(
        title: 'Test Todo',
        description: 'Test Description',
      );

      // 获取待办事项
      final todo = todoController.todos.first;

      // 删除待办事项
      await todoController.deleteTodo(todo.id);

      // 验证待办事项是否删除成功
      expect(todoController.todoCount, 0);
      expect(todoController.completedTodoCount, 0);
      expect(todoController.incompleteTodoCount, 0);
    });

    test('should toggle todo completion status', () async {
      // 添加待办事项
      final now = DateTime.now();
      await todoController.addTodo(
        title: 'Test Todo',
        description: 'Test Description',
      );

      // 获取待办事项
      final todo = todoController.todos.first;

      // 切换待办事项完成状态
      await todoController.toggleTodoCompletion(todo.id);

      // 验证待办事项状态是否切换成功
      final updatedTodo = todoController.todos.first;
      expect(updatedTodo.isCompleted, true);
      expect(todoController.completedTodoCount, 1);
      expect(todoController.incompleteTodoCount, 0);

      // 再次切换待办事项完成状态
      await todoController.toggleTodoCompletion(todo.id);

      // 验证待办事项状态是否切换成功
      final updatedTodo2 = todoController.todos.first;
      expect(updatedTodo2.isCompleted, false);
      expect(todoController.completedTodoCount, 0);
      expect(todoController.incompleteTodoCount, 1);
    });

    test('should mark todo as completed', () async {
      // 添加待办事项
      final now = DateTime.now();
      await todoController.addTodo(
        title: 'Test Todo',
        description: 'Test Description',
      );

      // 获取待办事项
      final todo = todoController.todos.first;

      // 标记待办事项为已完成
      await todoController.markTodoAsCompleted(todo.id);

      // 验证待办事项状态是否标记成功
      final updatedTodo = todoController.todos.first;
      expect(updatedTodo.isCompleted, true);
      expect(todoController.completedTodoCount, 1);
      expect(todoController.incompleteTodoCount, 0);
    });

    test('should mark todo as incomplete', () async {
      // 添加待办事项
      final now = DateTime.now();
      await todoController.addTodo(
        title: 'Test Todo',
        description: 'Test Description',
      );

      // 获取待办事项
      final todo = todoController.todos.first;

      // 标记待办事项为已完成
      await todoController.markTodoAsCompleted(todo.id);

      // 验证待办事项状态是否标记成功
      final updatedTodo = todoController.todos.first;
      expect(updatedTodo.isCompleted, true);

      // 标记待办事项为未完成
      await todoController.markTodoAsIncomplete(todo.id);

      // 验证待办事项状态是否标记成功
      final updatedTodo2 = todoController.todos.first;
      expect(updatedTodo2.isCompleted, false);
      expect(todoController.completedTodoCount, 0);
      expect(todoController.incompleteTodoCount, 1);
    });

    test('should clear all completed todos', () async {
      // 添加待办事项
      final now = DateTime.now();
      await todoController.addTodo(
        title: 'Completed Todo',
        description: 'Completed Description',
      );
      await todoController.addTodo(
        title: 'Incomplete Todo',
        description: 'Incomplete Description',
      );

      // 获取待办事项
      final todo1 = todoController.todos[0];

      // 标记第一个待办事项为已完成
      await todoController.markTodoAsCompleted(todo1.id);

      // 验证待办事项状态
      expect(todoController.completedTodoCount, 1);
      expect(todoController.incompleteTodoCount, 1);

      // 清空所有已完成的待办事项
      await todoController.clearCompletedTodos();

      // 验证已完成的待办事项是否清空成功
      expect(todoController.todoCount, 1);
      expect(todoController.completedTodoCount, 0);
      expect(todoController.incompleteTodoCount, 1);
      expect(todoController.todos[0].title, 'Incomplete Todo');
    });

    test('should clear all todos', () async {
      // 添加待办事项
      final now = DateTime.now();
      await todoController.addTodo(
        title: 'Todo 1',
        description: 'Description 1',
      );
      await todoController.addTodo(
        title: 'Todo 2',
        description: 'Description 2',
      );
      await todoController.addTodo(
        title: 'Todo 3',
        description: 'Description 3',
      );

      // 验证待办事项数量
      expect(todoController.todoCount, 3);

      // 清空所有待办事项
      await todoController.clearAllTodos();

      // 验证所有待办事项是否清空成功
      expect(todoController.todoCount, 0);
      expect(todoController.completedTodoCount, 0);
      expect(todoController.incompleteTodoCount, 0);
    });
  });
}
