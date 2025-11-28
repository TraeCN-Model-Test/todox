import 'package:get/get.dart';
import '../../data/models/todo.dart';
import '../../data/repositories/hive_service.dart';

/// 待办事项控制器
/// 负责管理待办事项的状态和业务逻辑
class TodoController extends GetxController {
  final HiveService _hiveService = HiveService.instance;

  /// 所有待办事项列表
  final RxList<Todo> _todos = <Todo>[].obs;

  /// 已完成的待办事项列表
  final RxList<Todo> _completedTodos = <Todo>[].obs;

  /// 未完成的待办事项列表
  final RxList<Todo> _incompleteTodos = <Todo>[].obs;

  /// 搜索关键词
  final RxString _searchQuery = ''.obs;

  /// 当前筛选状态 (all, completed, incomplete)
  final RxString _filterStatus = 'all'.obs;

  /// 当前排序方式 (time, priority, title)
  final RxString _sortBy = 'time'.obs;

  /// 是否升序排列
  final RxBool _isAscending = false.obs;

  /// 是否正在加载
  final RxBool _isLoading = false.obs;

  /// 获取所有待办事项
  List<Todo> get todos => _todos.toList();

  /// 获取已完成的待办事项
  List<Todo> get completedTodos => _completedTodos.toList();

  /// 获取未完成的待办事项
  List<Todo> get incompleteTodos => _incompleteTodos.toList();

  /// 获取搜索关键词
  String get searchQuery => _searchQuery.value;

  /// 获取当前筛选状态
  String get filterStatus => _filterStatus.value;

  /// 获取当前排序方式
  String get sortBy => _sortBy.value;

  /// 是否升序排列
  bool get isAscending => _isAscending.value;

  /// 是否正在加载
  bool get isLoading => _isLoading.value;

  /// 获取显示的待办事项列表（根据筛选和排序条件）
  List<Todo> get displayTodos {
    List<Todo> result;

    // 根据筛选条件获取数据
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

    // 应用搜索过滤
    if (_searchQuery.value.isNotEmpty) {
      result = _hiveService.searchTodos(_searchQuery.value);
    }

    // 应用排序
    result = _sortTodos(result);

    return result;
  }

  /// 获取待办事项总数
  int get todoCount => _todos.length;

  /// 获取已完成待办事项数量
  int get completedTodoCount => _completedTodos.length;

  /// 获取未完成待办事项数量
  int get incompleteTodoCount => _incompleteTodos.length;

  /// 获取完成率
  double get completionRate {
    if (_todos.isEmpty) return 0.0;
    return _completedTodos.length / _todos.length;
  }

  @override
  void onInit() {
    super.onInit();
    loadTodos();
  }

  /// 加载所有待办事项
  Future<void> loadTodos() async {
    _isLoading.value = true;
    try {
      final todos = _hiveService.getAllTodos();
      _todos.assignAll(todos);
      _updateFilteredLists();
    } catch (e) {
      Get.snackbar('错误', '加载待办事项失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 更新筛选后的列表
  void _updateFilteredLists() {
    _completedTodos.assignAll(_todos.where((todo) => todo.isCompleted));
    _incompleteTodos.assignAll(_todos.where((todo) => !todo.isCompleted));
  }

  /// 添加待办事项
  Future<void> addTodo({
    required String title,
    String description = '',
    DateTime? dueDate,
    int priority = 1,
    List<String> tags = const [],
  }) async {
    try {
      final todo = Todo.create(
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        tags: tags,
      );

      await _hiveService.addTodo(todo);
      _todos.add(todo);
      _updateFilteredLists();
      
      Get.snackbar('成功', '待办事项已添加');
    } catch (e) {
      Get.snackbar('错误', '添加待办事项失败: $e');
    }
  }

  /// 更新待办事项
  Future<void> updateTodo(Todo todo) async {
    try {
      await _hiveService.updateTodo(todo);
      
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        _updateFilteredLists();
      }
      
      Get.snackbar('成功', '待办事项已更新');
    } catch (e) {
      Get.snackbar('错误', '更新待办事项失败: $e');
    }
  }

  /// 删除待办事项
  Future<void> deleteTodo(String id) async {
    try {
      await _hiveService.deleteTodo(id);
      _todos.removeWhere((todo) => todo.id == id);
      _updateFilteredLists();
      
      Get.snackbar('成功', '待办事项已删除');
    } catch (e) {
      Get.snackbar('错误', '删除待办事项失败: $e');
    }
  }

  /// 删除多个待办事项
  Future<void> deleteTodos(List<String> ids) async {
    try {
      await _hiveService.deleteTodos(ids);
      _todos.removeWhere((todo) => ids.contains(todo.id));
      _updateFilteredLists();
      
      Get.snackbar('成功', '已删除 ${ids.length} 个待办事项');
    } catch (e) {
      Get.snackbar('错误', '删除待办事项失败: $e');
    }
  }

  /// 切换待办事项的完成状态
  Future<void> toggleTodoCompletion(String id) async {
    try {
      await _hiveService.toggleTodoCompletion(id);
      
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = _hiveService.getTodoById(id)!;
        _updateFilteredLists();
      }
    } catch (e) {
      Get.snackbar('错误', '更新待办事项状态失败: $e');
    }
  }

  /// 标记待办事项为已完成
  Future<void> markTodoAsCompleted(String id) async {
    try {
      await _hiveService.markTodoAsCompleted(id);
      
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = _hiveService.getTodoById(id)!;
        _updateFilteredLists();
      }
    } catch (e) {
      Get.snackbar('错误', '标记待办事项为已完成失败: $e');
    }
  }

  /// 标记待办事项为未完成
  Future<void> markTodoAsIncomplete(String id) async {
    try {
      await _hiveService.markTodoAsIncomplete(id);
      
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = _hiveService.getTodoById(id)!;
        _updateFilteredLists();
      }
    } catch (e) {
      Get.snackbar('错误', '标记待办事项为未完成失败: $e');
    }
  }

  /// 设置搜索关键词
  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  /// 设置筛选状态
  void setFilterStatus(String status) {
    _filterStatus.value = status;
  }

  /// 设置排序方式
  void setSortBy(String sortBy) {
    _sortBy.value = sortBy;
  }

  /// 切换排序方向
  void toggleSortDirection() {
    _isAscending.value = !_isAscending.value;
  }

  /// 对待办事项进行排序
  List<Todo> _sortTodos(List<Todo> todos) {
    List<Todo> sortedTodos = List.from(todos);

    switch (_sortBy.value) {
      case 'time':
        sortedTodos.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'priority':
        sortedTodos.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case 'title':
        sortedTodos.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'dueDate':
        sortedTodos.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
    }

    if (!_isAscending.value) {
      sortedTodos = sortedTodos.reversed.toList();
    }

    return sortedTodos;
  }

  /// 清空所有已完成的待办事项
  Future<void> clearCompletedTodos() async {
    try {
      final completedIds = _completedTodos.map((todo) => todo.id).toList();
      await deleteTodos(completedIds);
    } catch (e) {
      Get.snackbar('错误', '清空已完成待办事项失败: $e');
    }
  }

  /// 清空所有待办事项
  Future<void> clearAllTodos() async {
    try {
      await _hiveService.clearAllData();
      _todos.clear();
      _completedTodos.clear();
      _incompleteTodos.clear();
      
      Get.snackbar('成功', '已清空所有待办事项');
    } catch (e) {
      Get.snackbar('错误', '清空待办事项失败: $e');
    }
  }

  /// 刷新待办事项列表
  Future<void> refreshTodos() async {
    await loadTodos();
  }
}