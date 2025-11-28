import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../controllers/create_todo_controller.dart';

/// 创建待办事项页面
/// 提供表单让用户输入待办事项的详细信息
class CreateTodoPage extends GetView<CreateTodoController> {
  const CreateTodoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('创建待办事项'),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      actions: [
        // 重置按钮
        TextButton(
          onPressed: controller.resetForm,
          child: const Text(
            '重置',
            style: TextStyle(color: AppColors.onPrimary),
          ),
        ),
      ],
    );
  }

  /// 构建主体内容
  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(),
          const SizedBox(height: AppConstants.defaultPadding * 1.5),
          _buildDescriptionSection(),
          const SizedBox(height: AppConstants.defaultPadding * 1.5),
          _buildPrioritySection(),
          const SizedBox(height: AppConstants.defaultPadding * 1.5),
          _buildDueDateSection(),
          const SizedBox(height: AppConstants.defaultPadding * 2),
        ],
      ),
    );
  }

  /// 构建标题输入区域
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '标题',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Obx(
          () => TextField(
            controller: controller.titleController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '输入待办事项标题',
              border: const OutlineInputBorder(),
              errorText: controller.titleError.value,
              errorStyle: const TextStyle(color: AppColors.error),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              // 清除错误状态
              if (controller.titleError.value != null) {
                controller.titleError.value = null;
              }
            },
          ),
        ),
      ],
    );
  }

  /// 构建描述输入区域
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '描述',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Obx(
          () => TextField(
            controller: controller.descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: '输入待办事项描述',
              border: const OutlineInputBorder(),
              errorText: controller.descriptionError.value,
              errorStyle: const TextStyle(color: AppColors.error),
            ),
            textInputAction: TextInputAction.newline,
            onChanged: (_) {
              // 清除错误状态
              if (controller.descriptionError.value != null) {
                controller.descriptionError.value = null;
              }
            },
          ),
        ),
      ],
    );
  }

  /// 构建优先级选择区域
  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '优先级',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPriorityOption(
                title: '低',
                priority: 1,
                color: AppColors.priorityLow,
                isSelected: controller.selectedPriority.value == 1,
              ),
              _buildPriorityOption(
                title: '中',
                priority: 2,
                color: AppColors.priorityMedium,
                isSelected: controller.selectedPriority.value == 2,
              ),
              _buildPriorityOption(
                title: '高',
                priority: 3,
                color: AppColors.priorityHigh,
                isSelected: controller.selectedPriority.value == 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建优先级选项
  Widget _buildPriorityOption({
    required String title,
    required int priority,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.selectPriority(priority),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding * 1.5,
          vertical: AppConstants.defaultPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(
            color: color,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.onPrimary : color,
          ),
        ),
      ),
    );
  }

  /// 构建截止日期选择区域
  Widget _buildDueDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '截止日期',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: controller.selectDueDate,
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey400),
                      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: AppConstants.smallPadding),
                        Text(
                          controller.formatDueDate(controller.selectedDueDate.value),
                          style: TextStyle(
                            color: controller.selectedDueDate.value != null
                                ? AppColors.textPrimary
                                : AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (controller.selectedDueDate.value != null) ...[
                const SizedBox(width: AppConstants.smallPadding),
                IconButton(
                  onPressed: controller.clearDueDate,
                  icon: const Icon(Icons.clear),
                  color: AppColors.error,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.createTodo,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimary,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  '创建待办事项',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}