import 'package:get/get.dart';
import '../controllers/create_todo_controller.dart';

/// 创建待办事项页面绑定类
/// 负责注入创建待办页面所需的控制器
class CreateTodoBinding extends Bindings {
  @override
  void dependencies() {
    // 懒加载CreateTodoController
    Get.lazyPut<CreateTodoController>(
      () => CreateTodoController(),
    );
  }
}