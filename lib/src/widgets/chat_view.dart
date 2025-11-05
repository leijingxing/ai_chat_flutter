import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';
import '../themes/chat_theme.dart';
import 'message_bubble.dart';
import 'message_input.dart';

/// 聊天界面组件
/// 完整的聊天界面，包含消息列表、输入框和应用栏
class ChatView extends StatefulWidget {
  /// 聊天控制器
  final ChatController controller;

  /// 主题配置
  final ChatTheme theme;

  /// 应用栏标题
  final String? title;

  /// 是否显示应用栏
  final bool showAppBar;

  /// 应用栏前置组件
  final Widget? leading;

  /// 应用栏操作组件列表
  final List<Widget>? actions;

  /// 背景组件
  final Widget? background;

  /// 欢迎消息（当没有消息时显示）
  final Widget? welcomeMessage;

  /// 加载指示器组件
  final Widget? loadingIndicator;

  /// 错误消息组件
  final Widget? errorWidget;

  /// 空状态组件
  final Widget? emptyStateWidget;

  /// 消息列表内边距
  final EdgeInsets padding;

  /// 是否启用自动滚动
  final bool autoScroll;

  /// 滚动控制器
  final ScrollController? scrollController;

  /// 消息点击回调
  final Function(ChatMessage message)? onMessageTap;

  /// 消息长按回调
  final Function(ChatMessage message)? onMessageLongPress;

  /// 消息重试回调
  final Function(ChatMessage message)? onMessageRetry;

  /// 消息复制回调
  final Function(ChatMessage message)? onMessageCopy;

  /// 消息删除回调
  final Function(ChatMessage message)? onMessageDelete;

  /// 自定义输入框组件
  final Widget? inputBuilder;

  const ChatView({
    super.key,
    required this.controller,
    required this.theme,
    this.title,
    this.showAppBar = true,
    this.leading,
    this.actions,
    this.background,
    this.welcomeMessage,
    this.loadingIndicator,
    this.errorWidget,
    this.emptyStateWidget,
    this.padding = const EdgeInsets.all(16),
    this.autoScroll = true,
    this.scrollController,
    this.onMessageTap,
    this.onMessageLongPress,
    this.onMessageRetry,
    this.onMessageCopy,
    this.onMessageDelete,
    this.inputBuilder,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late ChatControllerState _controllerState;
  VoidCallback? _removeControllerListener;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 启动淡入动画
    _fadeAnimationController.forward();
    _controllerState = widget.controller.status;
    _removeControllerListener = widget.controller.addListener((state) {
      if (!mounted) return;
      setState(() {
        _controllerState = state;
      });
    });
  }

  @override
  void didUpdateWidget(covariant ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _removeControllerListener?.call();
      _controllerState = widget.controller.status;
      _removeControllerListener = widget.controller.addListener((state) {
        if (!mounted) return;
        setState(() {
          _controllerState = state;
        });
      });
    }

    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController == null) {
        _scrollController.dispose();
      }
      _scrollController = widget.scrollController ?? ScrollController();
    }
  }

  @override
  void dispose() {
    _removeControllerListener?.call();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    _fadeAnimationController.dispose();
    super.dispose();
  }

  /// 自动滚动到底部
  Future<void> _scrollToBottom() async {
    if (!widget.autoScroll) return;

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// 处理消息发送
  void _handleSendMessage(String text) {
    widget.controller.sendMessage(text).then((_) {
      _scrollToBottom();
    });
  }

  /// 处理停止流式回复
  void _handleStop() {
    widget.controller.stopStreaming();
  }

  /// 处理消息重试
  void _handleRetryMessage(ChatMessage message) {
    widget.controller.retryMessage(message.id).then((_) {
      _scrollToBottom();
    });
  }

  /// 处理消息复制
  void _handleCopyMessage(ChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('消息已复制'), duration: const Duration(seconds: 1)),
    );
  }

  /// 处理消息删除
  void _handleDeleteMessage(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除消息'),
        content: const Text('确定要删除这条消息吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              widget.controller.deleteMessage(message.id);
              Navigator.of(context).pop();
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget? _buildAppBar() {
    if (!widget.showAppBar) return null;

    return AppBar(
      title: Text(
        widget.title ?? widget.controller.session.title,
        style: widget.theme.appBarTextStyle,
      ),
      backgroundColor: widget.theme.appBarColor,
      elevation: 0,
      centerTitle: true,
      leading: widget.leading,
      actions:
          widget.actions ??
          [
            // 默认操作按钮
            if (widget.controller.session.messageCount > 0)
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('清空对话'),
                      content: const Text('确定要清空所有对话记录吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.controller.clearMessages();
                            Navigator.of(context).pop();
                          },
                          child: const Text('清空'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
    );
  }

  /// 构建消息列表
  Widget _buildMessageList() {
    final messages = widget.controller.messages;

    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      reverse: false,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _fadeAnimationController,
                        curve: Interval(
                          index * 0.1,
                          (index + 1) * 0.1,
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                child: MessageBubble(
                  message: message,
                  theme: widget.theme,
                  showAvatar: widget.theme.showAvatars,
                  showTimestamp: widget.theme.showTimestamps,
                  showStatusIndicator: widget.theme.showStatusIndicators,
                  onTap: () => widget.onMessageTap?.call(message),
                  onLongPress: () => widget.onMessageLongPress?.call(message),
                  onRetry: () => _handleRetryMessage(message),
                  onCopy: () => _handleCopyMessage(message),
                  onDelete: () => _handleDeleteMessage(message),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    if (widget.emptyStateWidget != null) {
      return widget.emptyStateWidget!;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.welcomeMessage != null) ...[
            widget.welcomeMessage!,
          ] else ...[
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: widget.theme.avatarTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              '开始新的对话',
              style: widget.theme.appBarTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Text('输入消息开始与AI助手对话', style: widget.theme.timestampStyle),
          ],
        ],
      ),
    );
  }

  /// 构建输入框
  Widget _buildInput() {
    if (widget.inputBuilder != null) {
      return widget.inputBuilder!;
    }

    final controllerState = _controllerState;
    final inputState = switch (controllerState) {
      ChatControllerState.idle => InputState.idle,
      ChatControllerState.sending ||
      ChatControllerState.streaming => InputState.streaming,
      ChatControllerState.error => InputState.idle,
    };

    return MessageInput(
      theme: widget.theme,
      state: inputState,
      onSend: _handleSendMessage,
      onStop: _handleStop,
      enableVoiceInput: true,
      enableImageInput: false,
      placeholder: '输入消息...',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: widget.theme.backgroundColor,
      body: Stack(
        children: [
          // 背景组件
          if (widget.background != null)
            Positioned.fill(child: widget.background!),

          // 主内容区域
          Column(
            children: [
              // 消息列表
              Expanded(child: _buildMessageList()),

              // 输入框
              _buildInput(),
            ],
          ),

          // 加载指示器
          if (_controllerState == ChatControllerState.sending &&
              widget.loadingIndicator != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
                child: widget.loadingIndicator!,
              ),
            ),
        ],
      ),
    );
  }
}

/// 简化的聊天界面组件
/// 提供基本的聊天功能，配置更简单
class SimpleChatView extends StatelessWidget {
  /// 聊天控制器
  final ChatController controller;

  /// 主题配置
  final ChatTheme? theme;

  /// 应用栏标题
  final String? title;

  /// 欢迎消息
  final String? welcomeMessage;

  /// 消息发送回调
  final Function(String text)? onSend;

  const SimpleChatView({
    super.key,
    required this.controller,
    this.theme,
    this.title,
    this.welcomeMessage,
    this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return ChatView(
      controller: controller,
      theme: theme ?? ChatTheme.light(),
      title: title,
      welcomeMessage: welcomeMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  welcomeMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : null,
      onMessageTap: (message) {
        // 默认消息点击行为
        HapticFeedback.lightImpact();
      },
      onMessageLongPress: (message) {
        // 默认长按行为
        HapticFeedback.mediumImpact();
      },
      onMessageCopy: (message) {
        Clipboard.setData(ClipboardData(text: message.content));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('消息已复制'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      inputBuilder: SimpleMessageInput(
        theme: theme ?? ChatTheme.light(),
        state: controller.status == ChatControllerState.streaming
            ? InputState.streaming
            : InputState.idle,
        onSend: onSend ?? (text) => controller.sendMessage(text),
        onStop: controller.stopStreaming,
      ),
    );
  }
}
