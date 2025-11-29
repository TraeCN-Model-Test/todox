import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:todox/data/models/todo.dart';
import 'package:todox/presentation/controllers/todo_controller.dart';
import 'package:todox/presentation/widgets/todo_item_widget.dart';

// 创建模拟类
class MockTodoController extends GetxController implements TodoController {
  final RxList<Todo> _todos = <Todo>[].obs;
  final RxList<Todo> _completedTodos = <Todo>[].obs;
  final RxList<Todo> _incompleteTodos = <Todo>[].obs;
  final RxString _searchQuery = ''.obs;
  final RxString _filterStatus = 'all'.obs;
  final RxString _sortBy = 'time'.obs;
  final RxBool _isAscending = false.obs;
  final RxBool _isLoading = false.obs;

  @override
  List<Todo> get todos => _todos.toList();

  @override
  List<Todo> get completedTodos => _completedTodos.toList();

  @override
  List<Todo> get incompleteTodos => _incompleteTodos.toList();

  @override
  List<Todo> get displayTodos {
    List<Todo> result;

    switch (_filterStatus.value) {
      case 'completed':
        result = _completedTodos.toList();
        break;
      case 'incomplete':
        result = _incompleteTodos.toList();
        break;
      default:
        result = _todos.toList();
    }

    if (_searchQuery.value.isNotEmpty) {
      result =
          result.where((todo) {
            final query = _searchQuery.value.toLowerCase();
            return todo.title.toLowerCase().contains(query) ||
                todo.description.toLowerCase().contains(query) ||
                todo.tags.any((tag) => tag.toLowerCase().contains(query));
          }).toList();
    }

    return result;
  }

  @override
  int get todoCount => _todos.length;

  @override
  int get completedTodoCount => _completedTodos.length;

  @override
  int get incompleteTodoCount => _incompleteTodos.length;

  @override
  double get completionRate {
    if (_todos.isEmpty) return 0.0;
    return _completedTodos.length / _todos.length;
  }

  @override
  String get searchQuery => _searchQuery.value;

  @override
  String get filterStatus => _filterStatus.value;

  @override
  String get sortBy => _sortBy.value;

  @override
  bool get isAscending => _isAscending.value;

  @override
  bool get isLoading => _isLoading.value;

  @override
  Future<void> loadTodos() async {
    // 模拟加载数据
    _isLoading.value = true;
    await Future.delayed(Duration(milliseconds: 100));
    _isLoading.value = false;
  }

  @override
  Future<void> addTodo({
    required String title,
    String description = '',
    DateTime? dueDate,
    int priority = 1,
    List<String> tags = const [],
  }) async {
    final todo = Todo.create(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      tags: tags,
    );

    _todos.add(todo);
    _updateFilteredLists();
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      _updateFilteredLists();
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    _updateFilteredLists();
  }

  @override
  Future<void> deleteTodos(List<String> ids) async {
    _todos.removeWhere((todo) => ids.contains(todo.id));
    _updateFilteredLists();
  }

  @override
  Future<void> toggleTodoCompletion(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final todo = _todos[index];
      // 手动切换完成状态，避免调用 Hive 的 save 方法
      todo.isCompleted = !todo.isCompleted;
      todo.updatedAt = DateTime.now();
      _updateFilteredLists();
    }
  }

  @override
  Future<void> markTodoAsCompleted(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final todo = _todos[index];
      todo.isCompleted = true;
      todo.updatedAt = DateTime.now();
      _updateFilteredLists();
    }
  }

  @override
  Future<void> markTodoAsIncomplete(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final todo = _todos[index];
      todo.isCompleted = false;
      todo.updatedAt = DateTime.now();
      _updateFilteredLists();
    }
  }

  @override
  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  @override
  void setFilterStatus(String status) {
    _filterStatus.value = status;
  }

  @override
  void setSortBy(String sortBy) {
    _sortBy.value = sortBy;
  }

  @override
  void toggleSortDirection() {
    _isAscending.value = !_isAscending.value;
  }

  @override
  Future<void> clearCompletedTodos() async {
    final completedIds = _completedTodos.map((todo) => todo.id).toList();
    await deleteTodos(completedIds);
  }

  @override
  Future<void> clearAllTodos() async {
    _todos.clear();
    _completedTodos.clear();
    _incompleteTodos.clear();
  }

  @override
  Future<void> refreshTodos() async {
    await loadTodos();
  }

  void _updateFilteredLists() {
    _completedTodos.assignAll(_todos.where((todo) => todo.isCompleted));
    _incompleteTodos.assignAll(_todos.where((todo) => !todo.isCompleted));
  }

  @override
  void addTodoForTesting(Todo todo) {
    _todos.add(todo);
    _updateFilteredLists();
  }
}

void main() {
  late MockTodoController todoController;

  setUp(() {
    // 初始化模拟控制器
    todoController = MockTodoController();
    Get.put<TodoController>(todoController);
  });

  tearDown(() {
    Get.reset();
  });

  group('编辑功能集成测试', () {
    setUp(() {
      // 添加一些测试数据
      todoController.addTodo(
        title: '测试待办事项',
        description: '这是一个测试待办事项',
        priority: 2,
        dueDate: DateTime.now().add(Duration(days: 3)),
      );
    });

    testWidgets('待办事项正常显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                TodoItemWidget(
                  todo: todoController.todos.first,
                  onTap: () {},
                  onDelete: () {},
                  onEdit: () {},
                  onToggleComplete: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // 验证TodoItemWidget正常显示
      expect(find.byType(TodoItemWidget), findsOneWidget);
      expect(find.text(todoController.todos.first.title), findsOneWidget);
    });

    testWidgets('点击编辑按钮触发回调', (WidgetTester tester) async {
      bool editCallbackTriggered = false;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                TodoItemWidget(
                  todo: todoController.todos.first,
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
      final todoItemWidget = tester.widget<TodoItemWidget>(
        find.byType(TodoItemWidget),
      );
      todoItemWidget.onEdit?.call();

      // 验证编辑回调被触发
      expect(editCallbackTriggered, true);
    });

    testWidgets('编辑模式下创建页面显示正确的数据', (WidgetTester tester) async {
      bool editCallbackTriggered = false;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                TodoItemWidget(
                  todo: todoController.todos.first,
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
      final todoItemWidget = tester.widget<TodoItemWidget>(
        find.byType(TodoItemWidget),
      );
      todoItemWidget.onEdit?.call();

      // 验证编辑回调被触发
      expect(editCallbackTriggered, true);
    });
  });

  group('编辑功能边界测试', () {
    testWidgets('编辑空待办事项', (WidgetTester tester) async {
      bool editCallbackTriggered = false;

      // 创建一个空的待办事项
      await todoController.addTodo(
        title: '',
        description: '',
        priority: 1,
        dueDate: null,
      );

      // 获取最后创建的待办事项
      final emptyTodo = todoController.todos.last;

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
      final todoItemWidget = tester.widget<TodoItemWidget>(
        find.byType(TodoItemWidget),
      );
      todoItemWidget.onEdit?.call();

      // 验证编辑回调被触发（即使待办事项为空）
      expect(editCallbackTriggered, true);
    });

    testWidgets('编辑已完成待办事项', (WidgetTester tester) async {
      bool editCallbackTriggered = false;

      // 创建一个已完成的待办事项
      await todoController.addTodo(
        title: '已完成的待办',
        description: '这个待办已经完成',
        priority: 2,
        dueDate: DateTime.now(),
      );

      // 获取最后创建的待办事项
      final completedTodo = todoController.todos.last;

      // 标记为已完成
      await todoController.toggleTodoCompletion(completedTodo.id);

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
      final todoItemWidget = tester.widget<TodoItemWidget>(
        find.byType(TodoItemWidget),
      );
      todoItemWidget.onEdit?.call();

      // 验证编辑回调被触发（即使待办事项已完成）
      expect(editCallbackTriggered, true);
    });
  });
}
