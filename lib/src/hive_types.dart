import 'package:hive/hive.dart';
import 'models/chat_message.dart';
import 'models/chat_session.dart';
import 'models/message_role.dart';
import 'models/message_status.dart';

/// Hive类型注册器
/// 必须在应用启动时调用以注册所有自定义类型
class HiveTypes {
  /// 注册所有Hive类型
  static Future<void> registerAll() async {
    // 注册枚举类型
    if (!Hive.isAdapterRegistered(messageStatusAdapterId)) {
      Hive.registerAdapter(MessageStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(messageRoleAdapterId)) {
      Hive.registerAdapter(MessageRoleAdapter());
    }

    // 注册模型类型
    if (!Hive.isAdapterRegistered(chatMessageAdapterId)) {
      Hive.registerAdapter(ChatMessageAdapter());
    }
    if (!Hive.isAdapterRegistered(chatSessionAdapterId)) {
      Hive.registerAdapter(ChatSessionAdapter());
    }
  }

  /// 打开所有Hive Box
  static Future<void> openAll() async {
    await Hive.openBox<ChatMessage>('chat_messages');
    await Hive.openBox<ChatSession>('chat_sessions');
  }

  /// 关闭所有Hive Box
  static Future<void> closeAll() async {
    await Hive.close();
  }
}

// 适配器ID常量
const int messageStatusAdapterId = 0;
const int messageRoleAdapterId = 1;
const int chatMessageAdapterId = 2;
const int chatSessionAdapterId = 3;
