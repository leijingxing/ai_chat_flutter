import 'package:flutter/material.dart';

/// 聊天界面主��配置类
/// 定义了聊天界面的各种样式和主题设置
class ChatTheme {
  /// 用户消息气泡颜色
  final Color userBubbleColor;

  /// 助手消息气泡颜色
  final Color assistantBubbleColor;

  /// 系统消息气泡颜色
  final Color systemBubbleColor;

  /// 用户消息文本样式
  final TextStyle userTextStyle;

  /// 助手消息文本样式
  final TextStyle assistantTextStyle;

  /// 系统消息文本样式
  final TextStyle systemTextStyle;

  /// 消息气泡圆角半径
  final BorderRadius bubbleBorderRadius;

  /// 消息间距
  final double messageSpacing;

  /// 消息内边距
  final EdgeInsets messagePadding;

  /// 输入框背景色
  final Color inputBackgroundColor;

  /// 输入框边框色
  final Color inputBorderColor;

  /// 输入框文本样式
  final TextStyle inputTextStyle;

  /// 输入框提示文本样式
  final TextStyle inputHintStyle;

  /// 发送按钮颜色
  final Color sendButtonColor;

  /// 发送按钮图标颜色
  final Color sendIconColor;

  /// 背景颜色
  final Color backgroundColor;

  /// 顶部应用栏颜色
  final Color appBarColor;

  /// 顶部应用栏文本样式
  final TextStyle appBarTextStyle;

  /// 时间戳文本样式
  final TextStyle timestampStyle;

  /// 消息状态指示器颜色
  final Color statusIndicatorColor;

  /// 错误消息颜色
  final Color errorColor;

  /// 加载指示器颜色
  final Color loadingColor;

  /// 滚动条颜色
  final Color scrollbarColor;

  /// 分隔线颜色
  final Color dividerColor;

  /// 头像背景色
  final Color avatarBackgroundColor;

  /// 头像文本颜色
  final Color avatarTextColor;

  /// 消息最大宽度比例（0.0-1.0）
  final double maxMessageWidthRatio;

  /// 是否显示头像
  final bool showAvatars;

  /// 是否显示时间戳
  final bool showTimestamps;

  /// 是否显示消息状态
  final bool showStatusIndicators;

  /// 是否使用圆形头像
  final bool useCircularAvatars;

  /// 构造函数
  const ChatTheme({
    this.userBubbleColor = const Color(0xFF007AFF),
    this.assistantBubbleColor = const Color(0xFFF2F2F7),
    this.systemBubbleColor = const Color(0xFFFFEAA7),
    this.userTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    this.assistantTextStyle = const TextStyle(
      color: Color(0xFF1C1C1E),
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    this.systemTextStyle = const TextStyle(
      color: Color(0xFF666666),
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
    ),
    this.bubbleBorderRadius = const BorderRadius.all(Radius.circular(18)),
    this.messageSpacing = 12.0,
    this.messagePadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    this.inputBackgroundColor = Colors.white,
    this.inputBorderColor = const Color(0xFFE5E5EA),
    this.inputTextStyle = const TextStyle(
      color: Color(0xFF1C1C1E),
      fontSize: 16,
    ),
    this.inputHintStyle = const TextStyle(
      color: Color(0x8C8C8C93),
      fontSize: 16,
    ),
    this.sendButtonColor = const Color(0xFF007AFF),
    this.sendIconColor = Colors.white,
    this.backgroundColor = const Color(0xFFF2F2F7),
    this.appBarColor = const Color(0xFFF7F7F7),
    this.appBarTextStyle = const TextStyle(
      color: Color(0xFF1C1C1E),
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
    this.timestampStyle = const TextStyle(
      color: Color(0x8C8C8C93),
      fontSize: 12,
    ),
    this.statusIndicatorColor = const Color(0xFF34C759),
    this.errorColor = const Color(0xFFFF3B30),
    this.loadingColor = const Color(0xFF007AFF),
    this.scrollbarColor = const Color(0x8C8C8C4D),
    this.dividerColor = const Color(0x8C8C8C33),
    this.avatarBackgroundColor = const Color(0xFFE5E5EA),
    this.avatarTextColor = const Color(0xFF666666),
    this.maxMessageWidthRatio = 0.75,
    this.showAvatars = true,
    this.showTimestamps = true,
    this.showStatusIndicators = true,
    this.useCircularAvatars = true,
  });

  /// 创建浅色主题
  factory ChatTheme.light() {
    return const ChatTheme(
      backgroundColor: Colors.white,
      inputBackgroundColor: Color(0xFFF9F9F9),
      userBubbleColor: Color(0xFF007AFF),
      assistantBubbleColor: Color(0xFFF2F2F7),
    );
  }

  /// 创建深色主题
  factory ChatTheme.dark() {
    return const ChatTheme(
      backgroundColor: Color(0xFF1C1C1E),
      inputBackgroundColor: Color(0xFF2C2C2E),
      inputBorderColor: Color(0xFF38383A),
      userBubbleColor: Color(0xFF0A84FF),
      assistantBubbleColor: Color(0xFF38383A),
      userTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      assistantTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      systemTextStyle: TextStyle(
        color: Color(0x99AEAEB2),
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontStyle: FontStyle.italic,
      ),
      inputTextStyle: TextStyle(color: Colors.white, fontSize: 16),
      inputHintStyle: TextStyle(color: Color(0x99AEAEB2), fontSize: 16),
      appBarColor: Color(0xFF2C2C2E),
      appBarTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      timestampStyle: TextStyle(color: Color(0x99AEAEB2), fontSize: 12),
      avatarBackgroundColor: Color(0xFF38383A),
      avatarTextColor: Color(0x99AEAEB2),
      scrollbarColor: Color(0x99AEAEB2),
      dividerColor: Color(0x8C8C8C33),
    );
  }

  /// 创建自定义颜色主题
  factory ChatTheme.custom({
    required Color primaryColor,
    required Color backgroundColor,
    bool isDark = false,
  }) {
    return ChatTheme(
      backgroundColor: backgroundColor,
      userBubbleColor: primaryColor,
      assistantBubbleColor: isDark
          ? const Color(0xFF38383A)
          : const Color(0xFFF2F2F7),
      inputBackgroundColor: isDark
          ? const Color(0xFF2C2C2E)
          : const Color(0xFFF9F9F9),
      inputBorderColor: isDark
          ? const Color(0xFF38383A)
          : const Color(0xFFE5E5EA),
      userTextStyle: TextStyle(
        color: isDark ? Colors.white : Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      assistantTextStyle: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      appBarColor: isDark ? const Color(0xFF2C2C2E) : backgroundColor,
      appBarTextStyle: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      sendButtonColor: primaryColor,
      inputTextStyle: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        fontSize: 16,
      ),
      inputHintStyle: TextStyle(
        color: isDark ? const Color(0x99AEAEB2) : const Color(0x8C8C8C93),
        fontSize: 16,
      ),
      avatarBackgroundColor: isDark
          ? const Color(0xFF38383A)
          : const Color(0xFFE5E5EA),
      avatarTextColor: isDark
          ? const Color(0x99AEAEB2)
          : const Color(0xFF666666),
    );
  }

  /// 创建主题副本
  ChatTheme copyWith({
    Color? userBubbleColor,
    Color? assistantBubbleColor,
    Color? systemBubbleColor,
    TextStyle? userTextStyle,
    TextStyle? assistantTextStyle,
    TextStyle? systemTextStyle,
    BorderRadius? bubbleBorderRadius,
    double? messageSpacing,
    EdgeInsets? messagePadding,
    Color? inputBackgroundColor,
    Color? inputBorderColor,
    TextStyle? inputTextStyle,
    TextStyle? inputHintStyle,
    Color? sendButtonColor,
    Color? sendIconColor,
    Color? backgroundColor,
    Color? appBarColor,
    TextStyle? appBarTextStyle,
    TextStyle? timestampStyle,
    Color? statusIndicatorColor,
    Color? errorColor,
    Color? loadingColor,
    Color? scrollbarColor,
    Color? dividerColor,
    Color? avatarBackgroundColor,
    Color? avatarTextColor,
    double? maxMessageWidthRatio,
    bool? showAvatars,
    bool? showTimestamps,
    bool? showStatusIndicators,
    bool? useCircularAvatars,
  }) {
    return ChatTheme(
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      assistantBubbleColor: assistantBubbleColor ?? this.assistantBubbleColor,
      systemBubbleColor: systemBubbleColor ?? this.systemBubbleColor,
      userTextStyle: userTextStyle ?? this.userTextStyle,
      assistantTextStyle: assistantTextStyle ?? this.assistantTextStyle,
      systemTextStyle: systemTextStyle ?? this.systemTextStyle,
      bubbleBorderRadius: bubbleBorderRadius ?? this.bubbleBorderRadius,
      messageSpacing: messageSpacing ?? this.messageSpacing,
      messagePadding: messagePadding ?? this.messagePadding,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputBorderColor: inputBorderColor ?? this.inputBorderColor,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      inputHintStyle: inputHintStyle ?? this.inputHintStyle,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      sendIconColor: sendIconColor ?? this.sendIconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      appBarColor: appBarColor ?? this.appBarColor,
      appBarTextStyle: appBarTextStyle ?? this.appBarTextStyle,
      timestampStyle: timestampStyle ?? this.timestampStyle,
      statusIndicatorColor: statusIndicatorColor ?? this.statusIndicatorColor,
      errorColor: errorColor ?? this.errorColor,
      loadingColor: loadingColor ?? this.loadingColor,
      scrollbarColor: scrollbarColor ?? this.scrollbarColor,
      dividerColor: dividerColor ?? this.dividerColor,
      avatarBackgroundColor:
          avatarBackgroundColor ?? this.avatarBackgroundColor,
      avatarTextColor: avatarTextColor ?? this.avatarTextColor,
      maxMessageWidthRatio: maxMessageWidthRatio ?? this.maxMessageWidthRatio,
      showAvatars: showAvatars ?? this.showAvatars,
      showTimestamps: showTimestamps ?? this.showTimestamps,
      showStatusIndicators: showStatusIndicators ?? this.showStatusIndicators,
      useCircularAvatars: useCircularAvatars ?? this.useCircularAvatars,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatTheme &&
        other.userBubbleColor == userBubbleColor &&
        other.assistantBubbleColor == assistantBubbleColor &&
        other.systemBubbleColor == systemBubbleColor &&
        other.userTextStyle == userTextStyle &&
        other.assistantTextStyle == assistantTextStyle &&
        other.systemTextStyle == systemTextStyle &&
        other.bubbleBorderRadius == bubbleBorderRadius &&
        other.messageSpacing == messageSpacing &&
        other.messagePadding == messagePadding &&
        other.inputBackgroundColor == inputBackgroundColor &&
        other.inputBorderColor == inputBorderColor &&
        other.inputTextStyle == inputTextStyle &&
        other.inputHintStyle == inputHintStyle &&
        other.sendButtonColor == sendButtonColor &&
        other.sendIconColor == sendIconColor &&
        other.backgroundColor == backgroundColor &&
        other.appBarColor == appBarColor &&
        other.appBarTextStyle == appBarTextStyle &&
        other.timestampStyle == timestampStyle &&
        other.statusIndicatorColor == statusIndicatorColor &&
        other.errorColor == errorColor &&
        other.loadingColor == loadingColor &&
        other.scrollbarColor == scrollbarColor &&
        other.dividerColor == dividerColor &&
        other.avatarBackgroundColor == avatarBackgroundColor &&
        other.avatarTextColor == avatarTextColor &&
        other.maxMessageWidthRatio == maxMessageWidthRatio &&
        other.showAvatars == showAvatars &&
        other.showTimestamps == showTimestamps &&
        other.showStatusIndicators == showStatusIndicators &&
        other.useCircularAvatars == useCircularAvatars;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      userBubbleColor,
      assistantBubbleColor,
      systemBubbleColor,
      userTextStyle,
      assistantTextStyle,
      systemTextStyle,
      bubbleBorderRadius,
      messageSpacing,
      messagePadding,
      inputBackgroundColor,
      inputBorderColor,
      inputTextStyle,
      inputHintStyle,
      sendButtonColor,
      sendIconColor,
      backgroundColor,
      appBarColor,
      appBarTextStyle,
      timestampStyle,
      statusIndicatorColor,
      errorColor,
      loadingColor,
      scrollbarColor,
      dividerColor,
      avatarBackgroundColor,
      avatarTextColor,
      maxMessageWidthRatio,
      showAvatars,
      showTimestamps,
      showStatusIndicators,
      useCircularAvatars,
    ]);
  }
}
