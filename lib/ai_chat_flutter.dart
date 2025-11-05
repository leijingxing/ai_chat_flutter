// AI Chat Flutter Library
// 一个可定制的 Flutter AI 对话界面组件库
//
// 这个库提供了构建AI聊天应用所需的所有核心组件，包括：
// - 消息模型和状态管理
// - AI Provider抽象层（支持多种AI服务）
// - 可自定义的UI组件
// - 主题配置系统
// - Riverpod状态管理集成
//
// 基本使用示例：
// ```dart
// import 'package:ai_chat_flutter/ai_chat_flutter.dart';
//
// // 创建聊天控制器
// final controller = ChatController.create(
//   provider: MockAiProvider(),
//   sessionTitle: 'AI对话',
// );
//
// // 在UI中使用
// ChatView(
//   controller: controller,
//   theme: ChatTheme.light(),
// )
// ```

// 导入必要的依赖
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'src/models/chat_message.dart';
import 'src/models/chat_session.dart';
import 'src/models/message_role.dart';
import 'src/models/message_status.dart';
import 'src/providers/ai_provider.dart';
import 'src/themes/chat_theme.dart';

// 导出核心模型类
export 'src/models/message_role.dart';
export 'src/models/message_status.dart';
export 'src/models/chat_message.dart';
export 'src/models/chat_session.dart';

// 导出AI Provider
export 'src/providers/ai_provider.dart';
export 'src/providers/mock_ai_provider.dart';
export 'src/providers/openai_provider.dart';

// 导出控制器
export 'src/controllers/chat_controller.dart';

// 导出主题配置
export 'src/themes/chat_theme.dart';

// 导出UI组件
export 'src/widgets/message_bubble.dart';
export 'src/widgets/message_input.dart';
export 'src/widgets/chat_view.dart';

// 常用的工具函数和便捷方法

/// 创建默认的聊天会话
ChatSession createDefaultSession({
  required String title,
  String? modelName,
  String? systemPrompt,
}) {
  return ChatSession.create(
    id: const Uuid().v4(),
    title: title,
    modelName: modelName,
    systemPrompt: systemPrompt,
  );
}

/// 验证消息内容
bool isValidMessage(String content) {
  return content.trim().isNotEmpty && content.length <= 4000;
}

/// 格式化时间戳为用户友好的格式
String formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inDays > 0) {
    return '${difference.inDays}天前';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}小时前';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}分钟前';
  } else {
    return '刚刚';
  }
}

/// 获取消息状态对应的图标
IconData getStatusIcon(MessageStatus status) {
  switch (status) {
    case MessageStatus.sending:
    case MessageStatus.retrying:
      return Icons.access_time;
    case MessageStatus.streaming:
      return Icons.more_horiz;
    case MessageStatus.sent:
      return Icons.done;
    case MessageStatus.error:
      return Icons.error_outline;
  }
}

/// 获取消息状态对应的颜色
Color getStatusColor(MessageStatus status, ChatTheme theme) {
  switch (status) {
    case MessageStatus.sending:
    case MessageStatus.retrying:
      return theme.loadingColor;
    case MessageStatus.streaming:
      return theme.statusIndicatorColor;
    case MessageStatus.sent:
      return theme.statusIndicatorColor;
    case MessageStatus.error:
      return theme.errorColor;
  }
}

/// 常用的预设主题
class PresetThemes {
  /// iOS风格浅色主题
  static ChatTheme get iosLight => ChatTheme.light();

  /// iOS风格深色主题
  static ChatTheme get iosDark => ChatTheme.dark();

  /// 蓝色主题
  static ChatTheme get blue => ChatTheme.custom(
    primaryColor: const Color(0xFF007AFF),
    backgroundColor: Colors.white,
  );

  /// 绿色主题
  static ChatTheme get green => ChatTheme.custom(
    primaryColor: const Color(0xFF34C759),
    backgroundColor: Colors.white,
  );

  /// 紫色主题
  static ChatTheme get purple => ChatTheme.custom(
    primaryColor: const Color(0xFFAF52DE),
    backgroundColor: Colors.white,
  );

  /// 深色蓝色主题
  static ChatTheme get darkBlue => ChatTheme.custom(
    primaryColor: const Color(0xFF0A84FF),
    backgroundColor: const Color(0xFF1C1C1E),
    isDark: true,
  );
}

/// 常用的系统提示词模板
class SystemPrompts {
  /// 通用助手
  static const String assistant = '你是一个有用的AI助手。请友好、专业地回答用户的问题。';

  /// 代码助手
  static const String codeAssistant = '你是一个编程专家。请提供清晰的代码示例和解释。';

  /// 翻译助手
  static const String translator = '你是一个专业的翻译助手。请准确、自然地翻译文本。';

  /// 写作助手
  static const String writer = '你是一个写作助手。请帮助用户改进文笔、提供创意建议。';

  /// 学习助手
  static const String tutor = '你是一个耐心的老师。请用简单易懂的方式解释复杂的概念。';
}

/// 库信息类
class LibraryInfo {
  /// 获取库版本
  static String get version => '0.1.0';

  /// 获取库名称
  static String get name => 'ai_chat_flutter';

  /// 获取库描述
  static String get description => '一个可定制的 Flutter AI 对话界面组件库';

  /// 打印库信息
  static void printInfo() {
    debugPrint('''
╔══════════════════════════════════════════════════════════════╗
║                    $name v$version                    ║
║                     $description                     ║
╚══════════════════════════════════════════════════════════════╝
    ''');
  }
}

// 便捷的类型别名
typedef ChatMessages = List<ChatMessage>;
typedef MessageCallback = void Function(ChatMessage message);
typedef MessageTextCallback = void Function(String text);
typedef ErrorCallback = void Function(String error);

// 开发工具类
class DevTools {
  /// 打印消息列表（调试用）
  static void printMessages(ChatMessages messages) {
    debugPrint('=== 消息列表 (${messages.length}条) ===');
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final preview = msg.content.length > 50
          ? '${msg.content.substring(0, 50)}...'
          : msg.content;
      debugPrint(
        '${i + 1}. [${msg.role.apiName}] ${msg.status.description}: $preview',
      );
    }
    debugPrint('=== 消息列表结束 ===');
  }

  /// 验证Provider配置
  static bool validateProviderConfig(AiConfig config) {
    return config.apiKey.isNotEmpty && config.model.isNotEmpty;
  }

  /// 生成测试消息
  static ChatMessage generateTestMessage({
    MessageRole role = MessageRole.user,
  }) {
    return ChatMessage(
      id: const Uuid().v4(),
      role: role,
      content: '这是一条测试消息',
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
    );
  }
}
