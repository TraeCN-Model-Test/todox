import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../controllers/todo_controller.dart';
import '../widgets/todo_item_widget.dart';

/// 主页视图
/// 显示待办事项列表，支持添加、编辑、删除和标记完成等功能
class HomePage extends GetView<TodoController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() => _buildBody(context)),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('TodoX'),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      actions: [
        // 搜索按钮
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context),
        ),
        // 筛选按钮
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          onSelected: (value) {
            controller.setFilterStatus(value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'all',
              child: Row(
                children: [
                  const Icon(Icons.list),
                  const SizedBox(width: 8),
                  const Text('全部'),
                  if (controller.filterStatus == 'all')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: AppColors.primary),
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'incomplete',
              child: Row(
                children: [
                  const Icon(Icons.radio_button_unchecked),
                  const SizedBox(width: 8),
                  const Text('未完成'),
                  if (controller.filterStatus == 'incomplete')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: AppColors.primary),
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'completed',
              child: Row(
                children: [
                  const Icon(Icons.check_circle),
                  const SizedBox(width: 8),
                  const Text('已完成'),
                  if (controller.filterStatus == 'completed')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: AppColors.primary),
                    ),
                ],
              ),
            ),
          ],
        ),
        // 排序按钮
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (value) {
            controller.setSortBy(value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'time',
              child: Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 8),
                  const Text('按时间'),
                  if (controller.sortBy == 'time')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: AppColors.primary),
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'priority',
              child: Row(
                children: [
                  const Icon(Icons.flag),
                  const SizedBox(width: 8),
                  const Text('按优先级'),
                  if (controller.sortBy == 'priority')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: AppColors.primary),
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'title',
              child: Row(
                children: [
                  const Icon(Icons.sort_by_alpha),
                  const SizedBox(width: 8),
                  const Text('按标题'),
                  if (controller.sortBy == 'title')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: AppColors.primary),
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'dueDate',
              child: Row(
                children: [
                  const Icon(Icons.event),
                  const SizedBox(width: 8),
                  const Text('按截止日期'),
                  if (controller.sortBy == 'dueDate')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: AppColors.primary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建主体内容
  Widget _buildBody(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.displayTodos.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        _buildStatsRow(),
        const SizedBox(height: AppConstants.defaultPadding),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshTodos,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: controller.displayTodos.length,
              itemBuilder: (context, index) {
                final todo = controller.displayTodos[index];
                return TodoItemWidget(
                  key: ValueKey(todo.id),
                  todo: todo,
                  onTap: () => _showTodoDetails(todo),
                  onToggleComplete: () => controller.toggleTodoCompletion(todo.id),
                  onDelete: () => _showDeleteConfirmationDialog(todo.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 构建空状态视图
  Widget _buildEmptyState(BuildContext context) {
    String title;
    String subtitle;
    IconData icon;

    switch (controller.filterStatus) {
      case 'completed':
        title = '没有已完成的待办事项';
        subtitle = '完成一些任务后，它们会显示在这里';
        icon = Icons.check_circle_outline;
        break;
      case 'incomplete':
        title = '没有待完成的任务';
        subtitle = '点击右下角的按钮添加新任务';
        icon = Icons.radio_button_unchecked;
        break;
      default:
        title = '还没有待办事项';
        subtitle = '点击右下角的按钮添加你的第一个任务';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建统计行
  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryWithOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('总计', controller.todoCount.toString()),
          _buildStatItem('已完成', controller.completedTodoCount.toString()),
          _buildStatItem('未完成', controller.incompleteTodoCount.toString()),
          _buildStatItem('完成率', '${(controller.completionRate * 100).toInt()}%'),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  /// 构建浮动操作按钮
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Get.toNamed(AppConstants.createTodoRoute),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      child: const Icon(Icons.add),
    );
  }

  /// 显示搜索对话框
  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController(
      text: controller.searchQuery,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索待办事项'),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入关键词搜索...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            controller.setSearchQuery(value);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.setSearchQuery('');
              Navigator.of(context).pop();
            },
            child: const Text('清空'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.setSearchQuery(searchController.text);
              Navigator.of(context).pop();
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  /// 显示待办事项详情
  void _showTodoDetails(todo) {
    // 这里可以实现显示待办事项详情的逻辑
    // 例如跳转到编辑页面或显示底部弹窗
    Get.snackbar(
      todo.title,
      '创建时间: ${DateTimeUtils.formatDateTime(todo.createdAt)}\n'
      '优先级: ${todo.priorityText}\n'
      '状态: ${todo.isCompleted ? "已完成" : "未完成"}',
      duration: const Duration(seconds: 3),
    );
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmationDialog(String todoId) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个待办事项吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteTodo(todoId);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}