import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../presentation/bindings/home_binding.dart';
import '../presentation/bindings/create_todo_binding.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/create_todo_page.dart';

/// 应用路由配置
/// 使用GetX的路由管理功能，定义所有页面路由和对应的绑定
class AppRoutes {
  /// 获取所有路由页面
  static final List<GetPage> routes = [
    // 主页路由
    GetPage(
      name: AppConstants.homeRoute,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    // 创建待办事项页面路由
    GetPage(
      name: AppConstants.createTodoRoute,
      page: () => const CreateTodoPage(),
      binding: CreateTodoBinding(),
      transition: Transition.rightToLeft,
    ),
  ];

  /// 初始化路由配置
  static void init() {
    // 这里可以添加路由初始化逻辑，例如设置默认过渡动画等
    Get.config(
      defaultTransition: Transition.rightToLeft,
      // 启用日志记录
      enableLog: true,
      // 设置默认的中间件
      defaultGlobalState: true,
    );
  }
}
