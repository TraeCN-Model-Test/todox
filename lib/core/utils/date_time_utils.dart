import 'package:intl/intl.dart';

/// 日期时间工具类
/// 提供日期时间格式化、计算等常用方法
class DateTimeUtils {
  DateTimeUtils._(); // 私有构造函数，防止实例化

  /// 格式化日期时间
  /// [dateTime] 要格式化的日期时间
  /// [pattern] 格式化模式，默认为 'yyyy-MM-dd HH:mm'
  static String formatDateTime(
    DateTime dateTime, {
    String pattern = 'yyyy-MM-dd HH:mm',
  }) {
    return DateFormat(pattern).format(dateTime);
  }

  /// 格式化日期
  /// [dateTime] 要格式化的日期时间
  /// [pattern] 格式化模式，默认为 'yyyy-MM-dd'
  static String formatDate(DateTime dateTime, {String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern).format(dateTime);
  }

  /// 格式化时间
  /// [dateTime] 要格式化的日期时间
  /// [pattern] 格式化模式，默认为 'HH:mm'
  static String formatTime(DateTime dateTime, {String pattern = 'HH:mm'}) {
    return DateFormat(pattern).format(dateTime);
  }

  /// 解析日期时间字符串
  /// [dateString] 日期时间字符串
  /// [pattern] 格式化模式，默认为 'yyyy-MM-dd HH:mm'
  static DateTime? parseDateTime(
    String dateString, {
    String pattern = 'yyyy-MM-dd HH:mm',
  }) {
    try {
      return DateFormat(pattern).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// 获取当前日期时间字符串
  /// [pattern] 格式化模式，默认为 'yyyy-MM-dd HH:mm'
  static String getCurrentDateTimeString({
    String pattern = 'yyyy-MM-dd HH:mm',
  }) {
    return formatDateTime(DateTime.now(), pattern: pattern);
  }

  /// 获取当前日期字符串
  /// [pattern] 格式化模式，默认为 'yyyy-MM-dd'
  static String getCurrentDateString({String pattern = 'yyyy-MM-dd'}) {
    return formatDate(DateTime.now(), pattern: pattern);
  }

  /// 获取当前时间字符串
  /// [pattern] 格式化模式，默认为 'HH:mm'
  static String getCurrentTimeString({String pattern = 'HH:mm'}) {
    return formatTime(DateTime.now(), pattern: pattern);
  }

  /// 计算两个日期之间的天数差
  /// [from] 起始日期
  /// [to] 结束日期
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// 判断两个日期是否是同一天
  /// [date1] 第一个日期
  /// [date2] 第二个日期
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 判断日期是否为今天
  /// [date] 要判断的日期
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 判断日期是否为昨天
  /// [date] 要判断的日期
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// 判断日期是否为明天
  /// [date] 要判断的日期
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// 判断日期是否为本周
  /// [date] 要判断的日期
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// 获取友好的时间描述
  /// [date] 要描述的日期
  static String getFriendlyTimeDescription(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (isToday(date)) {
      return '今天 ${formatTime(date)}';
    } else if (isYesterday(date)) {
      return '昨天 ${formatTime(date)}';
    } else if (isTomorrow(date)) {
      return '明天 ${formatTime(date)}';
    } else if (isThisWeek(date)) {
      return '${_getWeekdayName(date.weekday)} ${formatTime(date)}';
    } else if (date.year == now.year) {
      return formatDate(date, pattern: 'MM-dd HH:mm');
    } else {
      return formatDate(date, pattern: 'yyyy-MM-dd HH:mm');
    }
  }

  /// 获取星期几的名称
  /// [weekday] 星期几的数字表示（1-7，1表示周一）
  static String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return '周一';
      case 2:
        return '周二';
      case 3:
        return '周三';
      case 4:
        return '周四';
      case 5:
        return '周五';
      case 6:
        return '周六';
      case 7:
        return '周日';
      default:
        return '';
    }
  }

  /// 判断日期是否已过期
  /// [date] 要判断的日期
  static bool isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// 判断日期是否在未来
  /// [date] 要判断的日期
  static bool isInFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }
}
