import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/message_role.dart';
import '../models/message_status.dart';
import '../themes/chat_theme.dart';

/// 消息气泡组件
/// 用于显示用户、助手和系统消息的UI组件
class MessageBubble extends StatelessWidget {
  /// 消息数据
  final ChatMessage message;

  /// 主题配置
  final ChatTheme theme;

  /// 是否显示头像
  final bool showAvatar;

  /// 是否显示时间戳
  final bool showTimestamp;

  /// 是否显示状态指示器
  final bool showStatusIndicator;

  /// 点击消息回调
  final VoidCallback? onTap;

  /// 长按消息回调
  final VoidCallback? onLongPress;

  /// 重试回调（用于失败的消息）
  final VoidCallback? onRetry;

  /// 复制消息内容回调
  final VoidCallback? onCopy;

  /// 删除消息回调
  final VoidCallback? onDelete;

  const MessageBubble({
    super.key,
    required this.message,
    required this.theme,
    this.showAvatar = true,
    this.showTimestamp = true,
    this.showStatusIndicator = true,
    this.onTap,
    this.onLongPress,
    this.onRetry,
    this.onCopy,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role.isUser;
    final isSystem = message.role.isSystem;

    return Container(
      margin: EdgeInsets.only(
        bottom: theme.messageSpacing,
        left: isUser
            ? MediaQuery.of(context).size.width *
                  (1 - theme.maxMessageWidthRatio)
            : 0,
        right: isUser
            ? 0
            : MediaQuery.of(context).size.width *
                  (1 - theme.maxMessageWidthRatio),
      ),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 助手头像（左侧）
          if (!isUser && !isSystem && showAvatar) _buildAvatar(),
          if (!isUser && !isSystem && showAvatar) const SizedBox(width: 8),

          // 消息内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // 消息气泡
                GestureDetector(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width *
                          theme.maxMessageWidthRatio,
                    ),
                    padding: theme.messagePadding,
                    decoration: BoxDecoration(
                      color: _getBubbleColor(),
                      borderRadius: _getBubbleBorderRadius(isUser),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 消息内容
                        Text(
                          message.content,
                          style: _getTextStyle(),
                          strutStyle: const StrutStyle(
                            height: 1.4,
                            forceStrutHeight: true,
                          ),
                        ),

                        // 状态指示器（仅在流式或错误时显示）
                        if (showStatusIndicator && _shouldShowStatus()) ...[
                          const SizedBox(height: 4),
                          _buildStatusIndicator(),
                        ],
                      ],
                    ),
                  ),
                ),

                // 时间戳
                if (showTimestamp) ...[
                  const SizedBox(height: 4),
                  _buildTimestamp(isUser),
                ],
              ],
            ),
          ),

          // 用户头像（右侧）
          if (isUser && showAvatar) const SizedBox(width: 8),
          if (isUser && showAvatar) _buildAvatar(),
        ],
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    String initial;
    Color avatarColor;

    switch (message.role) {
      case MessageRole.user:
        initial = 'U';
        avatarColor = theme.userBubbleColor;
        break;
      case MessageRole.assistant:
        initial = 'A';
        avatarColor = theme.assistantBubbleColor;
        break;
      case MessageRole.system:
        initial = 'S';
        avatarColor = theme.systemBubbleColor;
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: avatarColor.withValues(alpha: 0.2),
        shape: theme.useCircularAvatars ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: theme.useCircularAvatars
            ? null
            : BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: avatarColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 获取消息气泡颜色
  Color _getBubbleColor() {
    switch (message.role) {
      case MessageRole.user:
        return theme.userBubbleColor;
      case MessageRole.assistant:
        return theme.assistantBubbleColor;
      case MessageRole.system:
        return theme.systemBubbleColor;
    }
  }

  /// 获取消息文本样式
  TextStyle _getTextStyle() {
    switch (message.role) {
      case MessageRole.user:
        return theme.userTextStyle;
      case MessageRole.assistant:
        return theme.assistantTextStyle;
      case MessageRole.system:
        return theme.systemTextStyle;
    }
  }

  /// 获取消息气泡圆角
  BorderRadius _getBubbleBorderRadius(bool isUser) {
    final borderRadius = theme.bubbleBorderRadius;

    // 为用户和助手消息调整圆角，使其更贴近对话界面设计
    if (isUser) {
      return BorderRadius.only(
        topLeft: borderRadius.topLeft,
        topRight: const Radius.circular(4),
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      );
    } else {
      return BorderRadius.only(
        topLeft: const Radius.circular(4),
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      );
    }
  }

  /// 判断是否显示状态指示器
  bool _shouldShowStatus() {
    return message.status.isProcessing || message.status == MessageStatus.error;
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator() {
    switch (message.status) {
      case MessageStatus.sending:
      case MessageStatus.retrying:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.loadingColor),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              message.status.description,
              style: theme.timestampStyle.copyWith(color: theme.loadingColor),
            ),
          ],
        );

      case MessageStatus.streaming:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingIndicator(),
            const SizedBox(width: 6),
            Text(
              message.status.description,
              style: theme.timestampStyle.copyWith(
                color: theme.statusIndicatorColor,
              ),
            ),
          ],
        );

      case MessageStatus.error:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 12, color: theme.errorColor),
            const SizedBox(width: 6),
            Text(
              message.status.description,
              style: theme.timestampStyle.copyWith(color: theme.errorColor),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRetry,
                child: Icon(Icons.refresh, size: 14, color: theme.errorColor),
              ),
            ],
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建打字机效果指示器
  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 24,
      height: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_buildDot(0), _buildDot(1), _buildDot(2)],
      ),
    );
  }

  /// 构建单个点
  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.3, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: theme.statusIndicatorColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  /// 构建时间戳
  Widget _buildTimestamp(bool isUser) {
    return Padding(
      padding: EdgeInsets.only(left: isUser ? 0 : 40, right: isUser ? 40 : 0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTimestamp(message.timestamp),
            style: theme.timestampStyle,
          ),
          if (message.tokenCount != null) ...[
            const SizedBox(width: 8),
            Text(
              '${message.tokenCount} tokens',
              style: theme.timestampStyle.copyWith(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  /// 格式化时间戳
  String _formatTimestamp(DateTime timestamp) {
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
}
