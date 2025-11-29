import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/models/todo.dart';

/// 待办事项列表项组件
/// 用于在列表中显示单个待办事项
class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const TodoItemWidget({
    Key? key,
    required this.todo,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(todo.id),
      // 指定滑动的方向
      direction: Axis.horizontal,
      // 设置删除操作
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            icon: Icons.delete,
            label: '删除',
            spacing: 8,
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppConstants.smallPadding),
                if (todo.description.isNotEmpty) _buildDescription(),
                const SizedBox(height: AppConstants.smallPadding),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建头部区域
  Widget _buildHeader() {
    return Row(
      children: [
        // 完成状态复选框
        GestureDetector(
          onTap: onToggleComplete,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: todo.isCompleted ? AppColors.success : AppColors.transparent,
              border: Border.all(
                color: todo.isCompleted ? AppColors.success : AppColors.grey400,
                width: 2,
              ),
            ),
            child:
                todo.isCompleted
                    ? const Icon(
                      Icons.check,
                      color: AppColors.onSuccess,
                      size: 16,
                    )
                    : null,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        // 标题
        Expanded(
          child: Text(
            todo.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color:
                  todo.isCompleted ? AppColors.grey500 : AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // 优先级标签
        _buildPriorityLabel(),
      ],
    );
  }

  /// 构建优先级标签
  Widget _buildPriorityLabel() {
    Color labelColor;
    String label;

    switch (todo.priority) {
      case 1:
        labelColor = AppColors.priorityLow;
        label = '低';
        break;
      case 2:
        labelColor = AppColors.priorityMedium;
        label = '中';
        break;
      case 3:
        labelColor = AppColors.priorityHigh;
        label = '高';
        break;
      default:
        labelColor = AppColors.grey400;
        label = '无';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: labelColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: labelColor,
        ),
      ),
    );
  }

  /// 构建描述区域
  Widget _buildDescription() {
    return Text(
      todo.description,
      style: TextStyle(
        fontSize: 14,
        color: todo.isCompleted ? AppColors.grey400 : AppColors.textSecondary,
        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建底部区域
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 创建时间
        Text(
          DateTimeUtils.formatDate(todo.createdAt),
          style: TextStyle(fontSize: 12, color: AppColors.grey500),
        ),
        // 截止日期（如果有）
        if (todo.dueDate != null) _buildDueDateWidget(),
      ],
    );
  }

  /// 构建截止日期组件
  Widget _buildDueDateWidget() {
    final now = DateTime.now();
    final dueDate = todo.dueDate!;
    final isOverdue = dueDate.isBefore(now) && !todo.isCompleted;
    final isToday = DateTimeUtils.isSameDay(dueDate, now);
    final isTomorrow = DateTimeUtils.isSameDay(
      dueDate,
      now.add(const Duration(days: 1)),
    );

    Color textColor;
    String prefix;

    if (isOverdue) {
      textColor = AppColors.error;
      prefix = '已过期';
    } else if (isToday) {
      textColor = AppColors.warning;
      prefix = '今天';
    } else if (isTomorrow) {
      textColor = AppColors.warning;
      prefix = '明天';
    } else {
      textColor = AppColors.grey500;
      prefix = '';
    }

    return Row(
      children: [
        Icon(Icons.event, size: 14, color: textColor),
        const SizedBox(width: 4),
        Text(
          '$prefix ${DateTimeUtils.formatDate(dueDate)}',
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight:
                isToday || isOverdue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}