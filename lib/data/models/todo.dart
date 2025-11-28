import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

/// 待办事项数据模型
/// 使用Hive进行本地存储，使用json_annotation进行JSON序列化
@HiveType(typeId: 0)
@JsonSerializable()
class Todo extends HiveObject {
  /// 待办事项ID
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;
  
  /// 待办事项标题
  @HiveField(1)
  @JsonKey(name: 'title')
  String title;
  
  /// 待办事项描述
  @HiveField(2)
  @JsonKey(name: 'description')
  String description;
  
  /// 创建时间
  @HiveField(3)
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  
  /// 更新时间
  @HiveField(4)
  @JsonKey(name: 'updatedAt')
  DateTime updatedAt;
  
  /// 截止时间
  @HiveField(5)
  @JsonKey(name: 'dueDate')
  DateTime? dueDate;
  
  /// 是否已完成
  @HiveField(6)
  @JsonKey(name: 'isCompleted')
  bool isCompleted;
  
  /// 优先级（0: 低，1: 中，2: 高）
  @HiveField(7)
  @JsonKey(name: 'priority')
  int priority;
  
  /// 标签列表
  @HiveField(8)
  @JsonKey(name: 'tags')
  List<String> tags;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.isCompleted = false,
    this.priority = 1,
    this.tags = const [],
  });

  /// 从JSON创建Todo实例
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  /// 将Todo实例转换为JSON
  Map<String, dynamic> toJson() => _$TodoToJson(this);

  /// 创建一个新的Todo实例
  factory Todo.create({
    required String title,
    String description = '',
    DateTime? dueDate,
    int priority = 1,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return Todo(
      id: _generateId(),
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
      isCompleted: false,
      priority: priority,
      tags: tags,
    );
  }

  /// 生成唯一ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 创建Todo的副本，可用于更新
  Todo copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    int? priority,
    List<String>? tags,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
    );
  }

  /// 标记为已完成
  void markAsCompleted() {
    isCompleted = true;
    updatedAt = DateTime.now();
    save();
  }

  /// 标记为未完成
  void markAsIncomplete() {
    isCompleted = false;
    updatedAt = DateTime.now();
    save();
  }

  /// 切换完成状态
  void toggleCompletion() {
    isCompleted = !isCompleted;
    updatedAt = DateTime.now();
    save();
  }

  /// 更新标题
  void updateTitle(String newTitle) {
    title = newTitle;
    updatedAt = DateTime.now();
    save();
  }

  /// 更新描述
  void updateDescription(String newDescription) {
    description = newDescription;
    updatedAt = DateTime.now();
    save();
  }

  /// 更新截止日期
  void updateDueDate(DateTime? newDueDate) {
    dueDate = newDueDate;
    updatedAt = DateTime.now();
    save();
  }

  /// 更新优先级
  void updatePriority(int newPriority) {
    priority = newPriority;
    updatedAt = DateTime.now();
    save();
  }

  /// 添加标签
  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
      updatedAt = DateTime.now();
      save();
    }
  }

  /// 移除标签
  void removeTag(String tag) {
    if (tags.contains(tag)) {
      tags.remove(tag);
      updatedAt = DateTime.now();
      save();
    }
  }

  /// 获取优先级文本
  String get priorityText {
    switch (priority) {
      case 0:
        return '低';
      case 1:
        return '中';
      case 2:
        return '高';
      default:
        return '中';
    }
  }

  /// 判断是否过期
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  /// 判断是否即将到期（24小时内）
  bool get isDueSoon {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final dueTime = dueDate!;
    return dueTime.isAfter(now) && dueTime.difference(now).inHours <= 24;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority)';
  }
}