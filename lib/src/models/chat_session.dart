import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'chat_message.dart';
import 'message_role.dart';
import 'message_status.dart';

part 'chat_session.g.dart';

/// 聊天会话模型类
/// 管理一个完整的对话会话，包含消息列表和会话元数据
@HiveType(typeId: 3)
@JsonSerializable(explicitToJson: true)
class ChatSession extends HiveObject {
  /// 会话唯一标识符
  @HiveField(0)
  final String id;

  /// 会话标题
  @HiveField(1)
  String title;

  /// 消息列表
  @HiveField(2)
  final List<ChatMessage> messages;

  /// 会话创建时间
  @HiveField(3)
  final DateTime createdAt;

  /// 会话最后更新时间
  @HiveField(4)
  DateTime updatedAt;

  /// 会话是否已置顶
  @HiveField(5)
  bool isPinned;

  /// 会话是否已归档
  @HiveField(6)
  bool isArchived;

  /// AI模型名称（可选）
  @HiveField(7)
  String? modelName;

  /// 系统提示词（可选）
  @HiveField(8)
  String? systemPrompt;

  /// 构造函数
  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isArchived = false,
    this.modelName,
    this.systemPrompt,
  });

  /// 创建新会话的便捷构造函数
  ChatSession.create({
    required String id,
    required String title,
    String? modelName,
    String? systemPrompt,
  }) : this(
         id: id,
         title: title,
         messages: [],
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
         modelName: modelName,
         systemPrompt: systemPrompt,
       );

  /// 从JSON创建对象
  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ChatSessionToJson(this);

  /// 添加消息到会话
  void addMessage(ChatMessage message) {
    messages.add(message);
    updatedAt = DateTime.now();

    // 自动更新会话标题（使用第一条用户消息）
    if (title.isEmpty && messages.isNotEmpty) {
      final firstUserMessage = messages.firstWhere(
        (msg) => msg.role.isUser,
        orElse: () => messages.first,
      );
      if (firstUserMessage.content.isNotEmpty) {
        title = firstUserMessage.content.length > 30
            ? '${firstUserMessage.content.substring(0, 30)}...'
            : firstUserMessage.content;
      }
    }

    save(); // 保存到Hive
  }

  /// 删除消息
  void removeMessage(String messageId) {
    messages.removeWhere((message) => message.id == messageId);
    updatedAt = DateTime.now();
    save(); // 保存到Hive
  }

  /// 清空所有消息
  void clearMessages() {
    messages.clear();
    updatedAt = DateTime.now();
    save(); // 保存到Hive
  }

  /// 获取最后一条消息
  ChatMessage? get lastMessage {
    return messages.isNotEmpty ? messages.last : null;
  }

  /// 获取最后一条用户消息
  ChatMessage? get lastUserMessage {
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role.isUser) {
        return messages[i];
      }
    }
    return null;
  }

  /// 获取未完成的消息数量
  int get processingMessageCount {
    return messages.where((msg) => msg.status.isProcessing).length;
  }

  /// 检查是否有消息正在处理中
  bool get hasProcessingMessages => processingMessageCount > 0;

  /// 获取消息总数
  int get messageCount => messages.length;

  /// 更新会话标题
  void updateTitle(String newTitle) {
    title = newTitle;
    updatedAt = DateTime.now();
    save(); // 保存到Hive
  }

  /// 切换置顶状态
  void togglePin() {
    isPinned = !isPinned;
    updatedAt = DateTime.now();
    save(); // 保存到Hive
  }

  /// 归档/取消归档会话
  void toggleArchive() {
    isArchived = !isArchived;
    updatedAt = DateTime.now();
    save(); // 保存到Hive
  }

  /// 创建会话副本
  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isArchived,
    String? modelName,
    String? systemPrompt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? List.from(this.messages),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      modelName: modelName ?? this.modelName,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }

  @override
  String toString() {
    return 'ChatSession(id: $id, title: $title, messageCount: $messageCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
