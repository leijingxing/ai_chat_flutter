import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_role.g.dart';

/// 消息角色枚举
/// 定义了对话中消息的发送者角色
@HiveType(typeId: 1)
@JsonEnum()
enum MessageRole {
  /// 用户角色
  @HiveField(0)
  user,

  /// AI助手角色
  @HiveField(1)
  assistant,

  /// 系统角色
  @HiveField(2)
  system,
}

/// 消息角色扩展方法
extension MessageRoleExtension on MessageRole {
  /// 获取角色的中文描述
  String get description {
    switch (this) {
      case MessageRole.user:
        return '用户';
      case MessageRole.assistant:
        return '助手';
      case MessageRole.system:
        return '系统';
    }
  }

  /// 获取角色的英文名称（用于API调用）
  String get apiName {
    switch (this) {
      case MessageRole.user:
        return 'user';
      case MessageRole.assistant:
        return 'assistant';
      case MessageRole.system:
        return 'system';
    }
  }

  /// 判断是否为用户角色
  bool get isUser => this == MessageRole.user;

  /// 判断是否为助手角色
  bool get isAssistant => this == MessageRole.assistant;

  /// 判断是否为系统角色
  bool get isSystem => this == MessageRole.system;
}
