import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../hive_types.dart';

/// Hive服务类
/// 管理Hive的初始化和数据持久化
class HiveService {
  static bool _isInitialized = false;

  /// 初始化Hive
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 初始化Hive Flutter
      await Hive.initFlutter();

      // 注册所有类型适配器
      await HiveTypes.registerAll();

      // 打开所有Box
      await HiveTypes.openAll();

      _isInitialized = true;
      debugPrint('Hive初始化成功');
    } catch (e) {
      debugPrint('Hive初始化失败: $e');
      rethrow;
    }
  }

  /// 检查Hive是否已初始化
  static bool get isInitialized => _isInitialized;

  /// 关闭Hive
  static Future<void> close() async {
    if (_isInitialized) {
      await HiveTypes.closeAll();
      _isInitialized = false;
    }
  }

  /// 清空所有数据
  static Future<void> clearAll() async {
    try {
      await Hive.box('chat_messages').clear();
      await Hive.box('chat_sessions').clear();
      debugPrint('已清空所有Hive数据');
    } catch (e) {
      debugPrint('清空Hive数据失败: $e');
    }
  }
}
