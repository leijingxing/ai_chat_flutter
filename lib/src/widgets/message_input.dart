import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/chat_theme.dart';

/// 输入框状态
enum InputState {
  /// 空闲状态
  idle,

  /// 发送��
  sending,

  /// 流式回复中
  streaming,
}

/// 消息输入框组件
/// 包含文本输入框、发送按钮、停止按钮等功能的复合组件
class MessageInput extends StatefulWidget {
  /// 主题配置
  final ChatTheme theme;

  /// 初始文本
  final String initialText;

  /// 占位符文本
  final String placeholder;

  /// 是否自动聚焦
  final bool autofocus;

  /// 最大行数
  final int maxLines;

  /// 最小行数
  final int minLines;

  /// 输入状态
  final InputState state;

  /// 是否启用语音输入
  final bool enableVoiceInput;

  /// 是否启用图片输入
  final bool enableImageInput;

  /// 发送回调
  final Function(String text) onSend;

  /// 停止回调
  final VoidCallback? onStop;

  /// 语音输入回调
  final VoidCallback? onVoiceInput;

  /// 图片输入回调
  final VoidCallback? onImageInput;

  /// 文本变化回调
  final Function(String text)? onTextChanged;

  /// 键盘类型
  final TextInputType keyboardType;

  /// 输入格式化器
  final List<TextInputFormatter>? inputFormatters;

  /// 自定义输入装饰
  final InputDecoration? decoration;

  /// 自定义发送按钮
  final Widget? sendButton;

  /// 自定义停止按钮
  final Widget? stopButton;

  /// 自定义语音按钮
  final Widget? voiceButton;

  /// 自定义图片按钮
  final Widget? imageButton;

  /// 边距
  final EdgeInsets margin;

  /// 内边距
  final EdgeInsets padding;

  const MessageInput({
    super.key,
    required this.theme,
    this.initialText = '',
    this.placeholder = '输入消息...',
    this.autofocus = false,
    this.maxLines = 5,
    this.minLines = 1,
    this.state = InputState.idle,
    this.enableVoiceInput = false,
    this.enableImageInput = false,
    required this.onSend,
    this.onStop,
    this.onVoiceInput,
    this.onImageInput,
    this.onTextChanged,
    this.keyboardType = TextInputType.multiline,
    this.inputFormatters,
    this.decoration,
    this.sendButton,
    this.stopButton,
    this.voiceButton,
    this.imageButton,
    this.margin = const EdgeInsets.all(16),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();

    // 监听文本变化
    _textController.addListener(_onTextChanged);

    // 自动聚焦
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 更新初始文本
    if (widget.initialText != oldWidget.initialText &&
        _textController.text != widget.initialText) {
      _textController.text = widget.initialText;
    }
  }

  /// 处理文本变化
  void _onTextChanged() {
    final text = _textController.text;
    final wasComposing = _isComposing;
    _isComposing = text.trim().isNotEmpty;

    // 更新UI状态
    if (wasComposing != _isComposing) {
      setState(() {});
    }

    // 触发回调
    widget.onTextChanged?.call(text);
  }

  /// 发送消息
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || widget.state != InputState.idle) return;

    widget.onSend(text);

    // 清空输入框并保持焦点
    _textController.clear();
    _focusNode.requestFocus();
  }

  /// 处理键盘事件
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (HardwareKeyboard.instance.logicalKeysPressed.contains(
              LogicalKeyboardKey.shiftLeft,
            ) ||
            HardwareKeyboard.instance.logicalKeysPressed.contains(
              LogicalKeyboardKey.shiftRight,
            )) {
          // Shift + Enter: 换行
          return;
        } else {
          // Enter: 发送消息
          _sendMessage();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.theme.inputBackgroundColor,
        border: Border.all(color: widget.theme.inputBorderColor),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 左侧功能按钮
          if (widget.enableVoiceInput || widget.enableImageInput) ...[
            _buildVoiceButton(),
            if (widget.enableImageInput) ...[
              const SizedBox(width: 8),
              _buildImageButton(),
            ],
            const SizedBox(width: 8),
          ],

          // 文本输入框
          Expanded(child: _buildTextField()),

          const SizedBox(width: 8),

          // 右侧发送/停止按钮
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// 构建文本输入框
  Widget _buildTextField() {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        style: widget.theme.inputTextStyle,
        decoration:
            widget.decoration ??
            InputDecoration(
              hintText: widget.placeholder,
              hintStyle: widget.theme.inputHintStyle,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
        enabled: widget.state == InputState.idle,
        textAlignVertical: TextAlignVertical.bottom,
        expands: false,
      ),
    );
  }

  /// 构建语音输入按钮
  Widget _buildVoiceButton() {
    if (widget.voiceButton != null) {
      return widget.voiceButton!;
    }

    return GestureDetector(
      onTap: widget.onVoiceInput,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: widget.theme.inputBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.mic,
          size: 20,
          color:
              widget.theme.inputHintStyle.color?.withValues(alpha: 0.6) ??
              Colors.grey.shade600,
        ),
      ),
    );
  }

  /// 构建图片输入按钮
  Widget _buildImageButton() {
    if (widget.imageButton != null) {
      return widget.imageButton!;
    }

    return GestureDetector(
      onTap: widget.onImageInput,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: widget.theme.inputBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.image,
          size: 20,
          color:
              widget.theme.inputHintStyle.color?.withValues(alpha: 0.6) ??
              Colors.grey.shade600,
        ),
      ),
    );
  }

  /// 构建操作按钮区域
  Widget _buildActionButtons() {
    switch (widget.state) {
      case InputState.idle:
        return _buildSendButton();
      case InputState.sending:
      case InputState.streaming:
        return _buildStopButton();
    }
  }

  /// 构建发送按钮
  Widget _buildSendButton() {
    if (widget.sendButton != null) {
      return widget.sendButton!;
    }

    final canSend = _isComposing;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: canSend ? widget.theme.sendButtonColor : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.send_rounded,
        size: 18,
        color: canSend ? widget.theme.sendIconColor : Colors.grey.shade500,
      ),
    );
  }

  /// 构建停止按钮
  Widget _buildStopButton() {
    if (widget.stopButton != null) {
      return widget.stopButton!;
    }

    return GestureDetector(
      onTap: widget.onStop,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: widget.theme.errorColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.stop_rounded, size: 18, color: Colors.white),
      ),
    );
  }
}

/// 简化的消息输入框组件
/// 只包含基本的文本输入和发送功能
class SimpleMessageInput extends StatelessWidget {
  /// 主题配置
  final ChatTheme theme;

  /// 占位符文本
  final String placeholder;

  /// 输入状态
  final InputState state;

  /// 发送回调
  final Function(String text) onSend;

  /// 停止回调
  final VoidCallback? onStop;

  const SimpleMessageInput({
    super.key,
    required this.theme,
    this.placeholder = '输入消息...',
    this.state = InputState.idle,
    required this.onSend,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return MessageInput(
      theme: theme,
      placeholder: placeholder,
      state: state,
      enableVoiceInput: false,
      enableImageInput: false,
      onSend: onSend,
      onStop: onStop,
      maxLines: 3,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
