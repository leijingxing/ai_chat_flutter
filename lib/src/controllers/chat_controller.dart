import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_provider.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/message_status.dart';
import '../models/message_role.dart';

/// 聊天控制器状态
enum ChatControllerState {
  /// 空闲状态
  idle,

  /// 发送消息中
  sending,

  /// 接收流式回复中
  streaming,

  /// 错误状态
  error,
}

/// 聊天控制器
/// 管理聊天的核心逻辑，包括消息发送、状态管理、AI交互等
class ChatController extends StateNotifier<ChatControllerState> {
  /// AI Provider
  final AiProvider _provider;

  /// 当前聊天会话
  ChatSession _session;

  /// 流式回复的当前内容
  String _currentStreamContent = '';

  /// 当前流式消息的ID
  String? _currentStreamingMessageId;

  /// 消息更新回调
  final Function(ChatMessage)? onMessageUpdated;

  /// 错误回调
  final Function(String)? onErrorCallback;

  /// 完成回调
  final Function()? onStreamCompleted;

  /// UUID生成器
  final Uuid _uuid = const Uuid();

  /// 构造函数
  ChatController({
    required AiProvider provider,
    required ChatSession session,
    this.onMessageUpdated,
    this.onErrorCallback,
    this.onStreamCompleted,
  }) : _provider = provider,
       _session = session,
       super(ChatControllerState.idle);

  /// 获取当前会话
  ChatSession get session => _session;

  /// 获取所有消息
  List<ChatMessage> get messages => List.unmodifiable(_session.messages);

  /// 获取最后一条消息
  ChatMessage? get lastMessage => _session.lastMessage;

  /// 检查是否有消息正在处理中
  bool get hasProcessingMessages => _session.hasProcessingMessages;

  /// 检查是否可以发送新消息
  bool get canSendMessage =>
      state != ChatControllerState.sending &&
      state != ChatControllerState.streaming;

  /// 当前控制器状态
  ChatControllerState get status => state;

  /// 创建新的控制器实例
  factory ChatController.create({
    required AiProvider provider,
    required String sessionTitle,
    String? modelName,
    String? systemPrompt,
    Function(ChatMessage)? onMessageUpdated,
    Function(String)? onError,
    Function()? onStreamCompleted,
  }) {
    final session = ChatSession.create(
      id: const Uuid().v4(),
      title: sessionTitle,
      modelName: modelName,
      systemPrompt: systemPrompt,
    );

    return ChatController(
      provider: provider,
      session: session,
      onMessageUpdated: onMessageUpdated,
      onErrorCallback: onError,
      onStreamCompleted: onStreamCompleted,
    );
  }

  /// 添加用户消息
  Future<String> addUserMessage(String content) async {
    if (content.trim().isEmpty) {
      throw ArgumentError('消息内容不能为空');
    }

    final message = ChatMessage.user(
      id: _uuid.v4(),
      content: content.trim(),
      status: MessageStatus.sent,
    );

    _session.addMessage(message);
    onMessageUpdated?.call(message);

    return message.id;
  }

  /// 添加助手消息
  Future<String> addAssistantMessage(String content) async {
    final message = ChatMessage.assistant(
      id: _uuid.v4(),
      content: content,
      status: MessageStatus.sent,
    );

    _session.addMessage(message);
    onMessageUpdated?.call(message);

    return message.id;
  }

  /// 添加系统消息
  Future<String> addSystemMessage(String content) async {
    final message = ChatMessage.system(id: _uuid.v4(), content: content);

    _session.addMessage(message);
    onMessageUpdated?.call(message);

    return message.id;
  }

  /// 发送消息并获取流式回复
  Future<void> sendMessage(String content) async {
    if (!canSendMessage) {
      throw StateError('当前无法发送新消息');
    }

    if (!_provider.isConfigured) {
      throw StateError('AI Provider未正确配置');
    }

    try {
      // 添加用户消息
      await addUserMessage(content);

      // 创建助手消息准备接收回复
      final assistantMessage = ChatMessage.assistant(
        id: _uuid.v4(),
        content: '',
        status: MessageStatus.sending,
      );

      _session.addMessage(assistantMessage);
      onMessageUpdated?.call(assistantMessage);

      // 更新控制器状态
      state = ChatControllerState.sending;

      // 开始流式回复
      await _streamResponse(assistantMessage);
    } catch (e) {
      state = ChatControllerState.error;
      onErrorCallback?.call('发送消息失败: $e');
      rethrow;
    }
  }

  /// 重试发送消息
  Future<void> retryMessage(String messageId) async {
    final message = _session.messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => throw ArgumentError('消息不存在'),
    );

    if (!message.role.isUser) {
      throw ArgumentError('只能重试用户消息');
    }

    // 删除该消息之后的所有消息
    final messageIndex = _session.messages.indexOf(message);
    final messagesToRemove = _session.messages.sublist(messageIndex + 1);

    for (final msg in messagesToRemove) {
      _session.removeMessage(msg.id);
    }

    // 重新发送消息
    await sendMessage(message.content);
  }

  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    final message = _session.messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => throw ArgumentError('消息不存在'),
    );

    // 如果删除的是正在处理的消息，停止流式回复
    if (_currentStreamingMessageId == messageId) {
      _currentStreamingMessageId = null;
      _currentStreamContent = '';
      state = ChatControllerState.idle;
    }

    _session.removeMessage(messageId);
    onMessageUpdated?.call(message);
  }

  /// 清空所有消息
  Future<void> clearMessages() async {
    _currentStreamingMessageId = null;
    _currentStreamContent = '';
    state = ChatControllerState.idle;

    _session.clearMessages();
  }

  /// 停止当前流式回复
  void stopStreaming() {
    if (state == ChatControllerState.streaming) {
      _currentStreamingMessageId = null;
      _currentStreamContent = '';
      state = ChatControllerState.idle;
    }
  }

  /// 更新会话标题
  void updateSessionTitle(String title) {
    _session.updateTitle(title);
  }

  /// 切换会话置顶状态
  void toggleSessionPin() {
    _session.togglePin();
  }

  /// 流式回复处理
  Future<void> _streamResponse(ChatMessage assistantMessage) async {
    _currentStreamingMessageId = assistantMessage.id;
    _currentStreamContent = '';

    await _provider.stream(
      messages: _session.messages,
      onToken: (token) {
        if (_currentStreamingMessageId == null) return; // 已停止

        _currentStreamContent += token;
        assistantMessage.updateContent(_currentStreamContent);
        assistantMessage.updateStatus(MessageStatus.streaming);

        state = ChatControllerState.streaming;
        onMessageUpdated?.call(assistantMessage);
      },
      onDone: () {
        if (_currentStreamingMessageId == null) return; // 已停止

        assistantMessage.markAsComplete();
        state = ChatControllerState.idle;

        _currentStreamingMessageId = null;
        _currentStreamContent = '';

        onMessageUpdated?.call(assistantMessage);
        onStreamCompleted?.call();
      },
      onError: (error) {
        if (_currentStreamingMessageId == null) return; // 已停止

        final errorMessage = error.toString();
        assistantMessage.markAsError(errorMessage);
        state = ChatControllerState.error;

        _currentStreamingMessageId = null;
        _currentStreamContent = '';

        onMessageUpdated?.call(assistantMessage);
        onErrorCallback?.call('AI回复错误: $errorMessage');
      },
    );
  }

  /// 获取支持的模型列表
  Future<List<String>> getSupportedModels() async {
    return await _provider.getSupportedModels();
  }

  /// 测试AI Provider连接
  Future<bool> testConnection() async {
    return await _provider.testConnection();
  }

  /// 更换AI Provider
  void updateProvider(AiProvider newProvider) {
    _provider.dispose();
    // 注意：这里需要重新设置provider，但由于_provider是final的，
    // 在实际使用中可能需要创建新的ChatController实例
  }

  /// 重置控制器状态
  void reset() {
    stopStreaming();
    state = ChatControllerState.idle;
  }

  @override
  void dispose() {
    stopStreaming();
    _provider.dispose();
    super.dispose();
  }
}

/// 聊天控制器提供者
typedef ChatControllerProvider =
    StateNotifierProvider<ChatController, ChatControllerState>;

/// 创建聊天控制器提供者
ChatControllerProvider createChatControllerProvider({
  required AiProvider provider,
  required String sessionTitle,
  String? modelName,
  String? systemPrompt,
  Function(ChatMessage)? onMessageUpdated,
  Function(String)? onError,
  Function()? onStreamCompleted,
}) {
  return StateNotifierProvider<ChatController, ChatControllerState>((ref) {
    return ChatController(
      provider: provider,
      session: ChatSession.create(
        id: const Uuid().v4(),
        title: sessionTitle,
        modelName: modelName,
        systemPrompt: systemPrompt,
      ),
      onMessageUpdated: onMessageUpdated,
      onErrorCallback: onError,
      onStreamCompleted: onStreamCompleted,
    );
  });
}
