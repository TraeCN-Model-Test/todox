import 'package:get/get.dart';
import '../controllers/todo_controller.dart';

/// 主页绑定类
/// 负责初始化和注入依赖
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TodoController>(() => TodoController());
  }
}