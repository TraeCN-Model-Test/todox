import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart';
import '../../core/constants/app_constants.dart';

/// Hive数据服务类
/// 提供对Hive数据库的初始化和基本操作
class HiveService {
  static HiveService? _instance;
  static HiveService get instance {
    _instance ??= HiveService._();
    return _instance!;
  }

  HiveService._(); // 私有构造函数，实现单例模式

  /// 待办事项数据盒子
  Box<Todo>? _todoBox;

  /// 初始化Hive数据库
  /// [initDir] 可选的自定义初始化目录，主要用于测试
  Future<void> init({String? initDir}) async {
    // 设置Hive的初始化路径
    if (initDir != null) {
      Hive.init(initDir);
    } else {
      // 获取应用程序文档目录
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    }

    // 注册适配器
    if (!Hive.isAdapterRegistered(TodoAdapter().typeId)) {
      Hive.registerAdapter(TodoAdapter());
    }

    // 打开数据盒子
    await _openBoxes();
  }

  /// 打开所有需要的数据盒子
  Future<void> _openBoxes() async {
    _todoBox = await Hive.openBox<Todo>(AppConstants.hiveBoxName);
  }

  /// 关闭所有数据盒子
  Future<void> close() async {
    await _todoBox?.close();
  }

  /// 清空所有数据
  Future<void> clearAllData() async {
    await _todoBox?.clear();
  }

  /// 获取待办事项数据盒子
  Box<Todo>? get todoBox => _todoBox;

  /// 获取所有待办事项
  List<Todo> getAllTodos() {
    return _todoBox?.values.toList() ?? [];
  }

  /// 根据ID获取待办事项
  Todo? getTodoById(String id) {
    return _todoBox?.get(id);
  }

  /// 添加待办事项
  Future<void> addTodo(Todo todo) async {
    await _todoBox?.put(todo.id, todo);
  }

  /// 更新待办事项
  Future<void> updateTodo(Todo todo) async {
    await _todoBox?.put(todo.id, todo);
  }

  /// 删除待办事项
  Future<void> deleteTodo(String id) async {
    await _todoBox?.delete(id);
  }

  /// 删除多个待办事项
  Future<void> deleteTodos(List<String> ids) async {
    for (final id in ids) {
      await _todoBox?.delete(id);
    }
  }

  /// 标记待办事项为已完成
  Future<void> markTodoAsCompleted(String id) async {
    final todo = _todoBox?.get(id);
    if (todo != null) {
      todo.markAsCompleted();
    }
  }

  /// 标记待办事项为未完成
  Future<void> markTodoAsIncomplete(String id) async {
    final todo = _todoBox?.get(id);
    if (todo != null) {
      todo.markAsIncomplete();
    }
  }

  /// 切换待办事项的完成状态
  Future<void> toggleTodoCompletion(String id) async {
    final todo = _todoBox?.get(id);
    if (todo != null) {
      todo.toggleCompletion();
    }
  }

  /// 获取已完成的待办事项
  List<Todo> getCompletedTodos() {
    return _todoBox?.values.where((todo) => todo.isCompleted).toList() ?? [];
  }

  /// 获取未完成的待办事项
  List<Todo> getIncompleteTodos() {
    return _todoBox?.values.where((todo) => !todo.isCompleted).toList() ?? [];
  }

  /// 获取过期的待办事项
  List<Todo> getOverdueTodos() {
    return _todoBox?.values.where((todo) => todo.isOverdue).toList() ?? [];
  }

  /// 获取即将到期的待办事项（24小时内）
  List<Todo> getDueSoonTodos() {
    return _todoBox?.values.where((todo) => todo.isDueSoon).toList() ?? [];
  }

  /// 按优先级获取待办事项
  List<Todo> getTodosByPriority(int priority) {
    return _todoBox?.values
            .where((todo) => todo.priority == priority)
            .toList() ??
        [];
  }

  /// 按标签获取待办事项
  List<Todo> getTodosByTag(String tag) {
    return _todoBox?.values.where((todo) => todo.tags.contains(tag)).toList() ??
        [];
  }

  /// 搜索待办事项
  List<Todo> searchTodos(String query) {
    if (query.isEmpty) return getAllTodos();

    final lowerQuery = query.toLowerCase();
    return _todoBox?.values.where((todo) {
          return todo.title.toLowerCase().contains(lowerQuery) ||
              todo.description.toLowerCase().contains(lowerQuery) ||
              todo.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        }).toList() ??
        [];
  }

  /// 获取待办事项总数
  int getTodoCount() {
    return _todoBox?.length ?? 0;
  }

  /// 获取已完成待办事项数量
  int getCompletedTodoCount() {
    return _todoBox?.values.where((todo) => todo.isCompleted).length ?? 0;
  }

  /// 获取未完成待办事项数量
  int getIncompleteTodoCount() {
    return _todoBox?.values.where((todo) => !todo.isCompleted).length ?? 0;
  }

  /// 获取待办事项完成率
  double getCompletionRate() {
    final total = getTodoCount();
    if (total == 0) return 0.0;
    return getCompletedTodoCount() / total;
  }
}
