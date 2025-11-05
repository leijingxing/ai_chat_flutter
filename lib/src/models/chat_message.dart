import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'message_status.dart';
import 'message_role.dart';

part 'chat_message.g.dart';

/// 聊天消息模型类
/// 使用Hive进行本地存储
@HiveType(typeId: 2)
@JsonSerializable()
class ChatMessage extends HiveObject {
  /// 消息唯一标识符
  @HiveField(0)
  final String id;

  /// 消息发送者角色
  @HiveField(1)
  final MessageRole role;

  /// 消息内容
  @HiveField(2)
  String content;

  /// 消息状态
  @HiveField(3)
  MessageStatus status;

  /// 消息创建时间
  @HiveField(4)
  final DateTime timestamp;

  /// 消息令牌数（可选，用于统计）
  @HiveField(5)
  int? tokenCount;

  /// 错误信息（状态为error时使用）
  @HiveField(6)
  String? errorMessage;

  /// 是否为流式消息的最后一部分
  @HiveField(7)
  bool isComplete;

  /// 构造函数
  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.status,
    required this.timestamp,
    this.tokenCount,
    this.errorMessage,
    this.isComplete = false,
  });

  /// 创建用户消息的便捷构造函数
  ChatMessage.user({
    required String id,
    required String content,
    MessageStatus status = MessageStatus.sent,
    DateTime? timestamp,
  }) : this(
         id: id,
         role: MessageRole.user,
         content: content,
         status: status,
         timestamp: timestamp ?? DateTime.now(),
       );

  /// 创建助手消息的便捷构造函数
  ChatMessage.assistant({
    required String id,
    required String content,
    MessageStatus status = MessageStatus.streaming,
    DateTime? timestamp,
  }) : this(
         id: id,
         role: MessageRole.assistant,
         content: content,
         status: status,
         timestamp: timestamp ?? DateTime.now(),
       );

  /// 创建系统消息的便捷构造函数
  ChatMessage.system({
    required String id,
    required String content,
    DateTime? timestamp,
  }) : this(
         id: id,
         role: MessageRole.system,
         content: content,
         status: MessageStatus.sent,
         timestamp: timestamp ?? DateTime.now(),
       );

  /// 从JSON创建对象
  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  /// 更新消息内容（用于流式输出）
  void updateContent(String newContent) {
    content = newContent;
    save(); // 保存到Hive
  }

  /// 更新消息状态
  void updateStatus(MessageStatus newStatus, {String? error}) {
    status = newStatus;
    if (error != null) {
      errorMessage = error;
    }
    save(); // 保存到Hive
  }

  /// 标记消息为完成状态
  void markAsComplete({int? tokenCount}) {
    status = MessageStatus.sent;
    isComplete = true;
    if (tokenCount != null) {
      this.tokenCount = tokenCount;
    }
    save(); // 保存到Hive
  }

  /// 标记消息为错误状态
  void markAsError(String error) {
    status = MessageStatus.error;
    errorMessage = error;
    save(); // 保存到Hive
  }

  /// 创建消息副本
  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    MessageStatus? status,
    DateTime? timestamp,
    int? tokenCount,
    String? errorMessage,
    bool? isComplete,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      tokenCount: tokenCount ?? this.tokenCount,
      errorMessage: errorMessage ?? this.errorMessage,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  String toString() {
    final preview = content.length > 50
        ? '${content.substring(0, 50)}...'
        : content;
    return 'ChatMessage(id: $id, role: $role, content: $preview, status: $status, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.role == role &&
        other.content == content &&
        other.status == status &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(id, role, content, status, timestamp);
  }
}
