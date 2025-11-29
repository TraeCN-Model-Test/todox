import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';
import 'routes/app_routes.dart';
import 'data/models/todo.dart';

/// 应用程序入口点
/// 负责初始化应用程序并运行主应用
Future<void> main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Hive
  await Hive.initFlutter();

  // 注册适配器
  if (!Hive.isAdapterRegistered(TodoAdapter().typeId)) {
    Hive.registerAdapter(TodoAdapter());
  }

  // 打开Hive盒子
  await Hive.openBox<Todo>(AppConstants.hiveBoxName);

  // 初始化应用路由
  AppRoutes.init();

  // 运行应用程序
  runApp(const TodoApp());
}

/// 应用程序根组件
/// 配置应用程序的主题、路由和全局设置
class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // 应用程序标题
      title: AppConstants.appName,

      // 调试横幅
      debugShowCheckedModeBanner: false,

      // 主题配置
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system, // 跟随系统主题
      // 路由配置
      initialRoute: AppConstants.homeRoute,
      getPages: AppRoutes.routes,

      // 默认过渡动画
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),

      // 国际化配置（可选）
      locale: const Locale('zh', 'CN'),
      fallbackLocale: const Locale('zh', 'CN'),

      // 应用程序构建器，用于全局配置
      builder: (context, child) {
        return MediaQuery(
          // 确保文本缩放因子不超过1.2
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },

      // 错误处理
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const NotFoundPage(),
        transition: Transition.fadeIn,
      ),
    );
  }
}

/// 404页面
/// 当用户访问不存在的路由时显示
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Text('页面未找到', style: TextStyle(fontSize: 24, color: Colors.grey)),
            SizedBox(height: 32),
            Text(
              '请检查您输入的URL是否正确',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.offAllNamed(AppConstants.homeRoute),
        child: const Icon(Icons.home),
      ),
    );
  }
}
