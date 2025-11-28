/// 应用程序常量配置类
/// 集中管理应用程序中使用的常量值
class AppConstants {
  AppConstants._(); // 私有构造函数，防止实例化

  // 应用程序基本信息
  static const String appName = 'TodoX';
  static const String appVersion = '1.0.0';

  // Hive数据库相关常量
  static const String hiveBoxName = 'todoBox';
  static const String todoAdapterName = 'todoAdapter';

  // 路由名称常量
  static const String homeRoute = '/home';
  static const String createTodoRoute = '/create-todo';
  static const String editTodoRoute = '/edit-todo';

  // 存储键常量
  static const String themeKey = 'theme_key';
  static const String localeKey = 'locale_key';

  // 日期时间格式常量
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';

  // UI相关常量
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonHeight = 48.0;

  // 动画持续时间常量
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // 网络请求相关常量
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int maxRetryCount = 3;

  // 本地存储相关常量
  static const String sharedPreferencesName = 'todo_shared_preferences';
}