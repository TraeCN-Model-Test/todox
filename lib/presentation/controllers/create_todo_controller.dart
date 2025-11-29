import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/models/todo.dart';
import 'todo_controller.dart';

/// 创建待办事项控制器
/// 负责管理创建待办事项页面的状态和逻辑
class CreateTodoController extends GetxController {
  // 表单控制器
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  // 状态变量
  var selectedPriority = 2.obs; // 默认中等优先级
  var selectedDueDate = Rxn<DateTime>(); // 截止日期
  var isLoading = false.obs;
  var isEditing = false.obs;
  var editingTodo = Rx<Todo?>(null);

  // 表单验证
  var titleError = Rxn<String>();
  var descriptionError = Rxn<String>();

  CreateTodoController({Todo? todo}) {
    if (todo != null) {
      isEditing.value = true;
      editingTodo.value = todo;
    }
  }

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    descriptionController = TextEditingController();

    // If editing, fill the form with todo data
    if (isEditing.value && editingTodo.value != null) {
      final todo = editingTodo.value!;
      titleController.text = todo.title;
      descriptionController.text = todo.description;
      selectedPriority.value = todo.priority;
      selectedDueDate.value = todo.dueDate;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  /// 验证表单
  bool validateForm() {
    bool isValid = true;

    // 验证标题
    if (titleController.text.trim().isEmpty) {
      titleError.value = '标题不能为空';
      isValid = false;
    } else {
      titleError.value = null;
    }

    // 验证描述（可选）
    if (descriptionController.text.trim().isEmpty) {
      descriptionError.value = '描述不能为空';
      isValid = false;
    } else {
      descriptionError.value = null;
    }

    return isValid;
  }

  /// 选择优先级
  void selectPriority(int priority) {
    selectedPriority.value = priority;
  }

  /// 选择截止日期
  Future<void> selectDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDueDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      selectedDueDate.value = pickedDate;
    }
  }

  /// 清除截止日期
  void clearDueDate() {
    selectedDueDate.value = null;
  }

  /// 创建或更新待办事项
  Future<void> createOrUpdateTodo() async {
    if (!validateForm()) {
      return;
    }

    isLoading.value = true;

    try {
      final todoController = Get.find<TodoController>();

      if (isEditing.value && editingTodo.value != null) {
        // 编辑模式：更新现有待办事项
        final todo = editingTodo.value!;
        todo.title = titleController.text.trim();
        todo.description = descriptionController.text.trim();
        todo.priority = selectedPriority.value;
        todo.dueDate = selectedDueDate.value;
        todo.updatedAt = DateTime.now();

        await todoController.updateTodo(todo);

        // 显示成功消息
        Get.snackbar(
          '成功',
          '待办事项已更新',
          backgroundColor: AppColors.success,
          colorText: AppColors.onSuccess,
          duration: const Duration(seconds: 2),
        );
      } else {
        // 创建模式：添加新待办事项
        await todoController.addTodo(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          priority: selectedPriority.value,
          dueDate: selectedDueDate.value,
        );

        // 显示成功消息
        Get.snackbar(
          '成功',
          '待办事项已创建',
          backgroundColor: AppColors.success,
          colorText: AppColors.onSuccess,
          duration: const Duration(seconds: 2),
        );
      }

      // 返回主页
      Get.back();
    } catch (e) {
      // 显示错误消息
      Get.snackbar(
        '错误',
        isEditing.value ? '更新待办事项失败: $e' : '创建待办事项失败: $e',
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 重置表单
  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    selectedPriority.value = 2; // 重置为中等优先级
    selectedDueDate.value = null;
    titleError.value = null;
    descriptionError.value = null;
  }

  /// 获取优先级颜色
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.priorityLow;
      case 2:
        return AppColors.priorityMedium;
      case 3:
        return AppColors.priorityHigh;
      default:
        return AppColors.grey400;
    }
  }

  /// 获取优先级文本
  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '低';
      case 2:
        return '中';
      case 3:
        return '高';
      default:
        return '无';
    }
  }

  /// 格式化截止日期显示
  String formatDueDate(DateTime? date) {
    if (date == null) return '无截止日期';
    return DateTimeUtils.formatDate(date);
  }
}
