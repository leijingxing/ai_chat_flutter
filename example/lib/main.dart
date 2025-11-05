import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_chat_flutter/ai_chat_flutter.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AIChatApp(),
    ),
  );
}

/// AI聊天示例应用
/// 展示ai_chat_flutter库的基本用法和功能特性
class AIChatApp extends StatelessWidget {
  const AIChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat Demo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const ChatHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 聊天主页
class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  late ChatController _chatController;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _initializeChatController();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  /// 初始化聊天控制器
  void _initializeChatController() {
    // 创建Mock AI Provider（用于演示）
    final mockProvider = MockAiProvider();

    // 创建聊天控制器
    _chatController = ChatController.create(
      provider: mockProvider,
      sessionTitle: 'AI对话演示',
      modelName: 'mock-gpt-4',
      systemPrompt: SystemPrompts.assistant,
      onMessageUpdated: (message) {
        // 消息更新时的回调
        debugPrint(
            '消息更新: ${message.role.description} - ${message.status.description}');
      },
      onError: (error) {
        // 错误处理回调
        _showErrorSnackBar(error);
      },
      onStreamCompleted: () {
        // 流式回复完成回调
        debugPrint('流式回复完成');
      },
    );
  }

  /// 显示错误提示
  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('错误: $error'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: '确定',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('AI Chat Demo'),
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      actions: [
        // 主题切换按钮
        PopupMenuButton<ThemeMode>(
          icon: const Icon(Icons.palette),
          onSelected: (ThemeMode mode) {
            setState(() {
              _themeMode = mode;
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ThemeMode.light,
              child: Row(
                children: const [
                  Icon(Icons.light_mode),
                  SizedBox(width: 8),
                  Text('浅色主题'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.dark,
              child: Row(
                children: const [
                  Icon(Icons.dark_mode),
                  SizedBox(width: 8),
                  Text('深色主题'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.system,
              child: Row(
                children: const [
                  Icon(Icons.settings_brightness),
                  SizedBox(width: 8),
                  Text('跟随系统'),
                ],
              ),
            ),
          ],
        ),
        // 设置按钮
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showSettingsDialog,
        ),
      ],
    );
  }

  /// 显示设置对话框
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: Text('库版本: ${LibraryInfo.version}'),
              subtitle: Text(LibraryInfo.description),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: Text('消息数量: ${_chatController.messages.length}'),
              subtitle: Text('会话标题: ${_chatController.session.title}'),
            ),
            ListTile(
              leading: const Icon(Icons.model_training),
              title: Text('模型: ${_chatController.session.modelName ?? "默认"}'),
              subtitle: const Text('点击切换模型'),
              onTap: _showModelSelectionDialog,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              _chatController.clearMessages();
              Navigator.of(context).pop();
              _showSuccessSnackBar('对话已清空');
            },
            child: const Text('清空对话'),
          ),
        ],
      ),
    );
  }

  /// 显示模型选择对话框
  void _showModelSelectionDialog() {
    Navigator.of(context).pop(); // 关闭设置对话框

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择AI模型'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Mock GPT-3.5'),
              subtitle: const Text('模拟模型，用于演示'),
              onTap: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('已切换到 Mock GPT-3.5');
              },
            ),
            ListTile(
              title: const Text('Mock GPT-4'),
              subtitle: const Text('模拟高级模型，用于演示'),
              onTap: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('已切换到 Mock GPT-4');
              },
            ),
            ListTile(
              title: const Text('自定义模型'),
              subtitle: const Text('配置自定义API'),
              onTap: () {
                Navigator.of(context).pop();
                _showCustomModelDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 显示自定义模型配置对话框
  void _showCustomModelDialog() {
    final apiKeyController = TextEditingController();
    final modelController = TextEditingController(text: 'gpt-3.5-turbo');
    final baseUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配置自定义模型'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: '模型名称',
                border: OutlineInputBorder(),
                hintText: 'gpt-3.5-turbo',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Base URL (可选)',
                border: OutlineInputBorder(),
                hintText: 'https://api.openai.com/v1',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final apiKey = apiKeyController.text.trim();
              final model = modelController.text.trim();
              final baseUrl = baseUrlController.text.trim();

              if (apiKey.isNotEmpty && model.isNotEmpty) {
                // 这里可以创建新的OpenAI Provider
                Navigator.of(context).pop();
                final target = baseUrl.isEmpty ? '默认接口' : '接口：$baseUrl';
                _showSuccessSnackBar('模型配置已保存（$target）');
              } else {
                _showErrorSnackBar('请填写必要的配置信息');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 显示成功提示
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 获取当前主题
  ChatTheme _getCurrentTheme() {
    switch (_themeMode) {
      case ThemeMode.light:
        return PresetThemes.iosLight;
      case ThemeMode.dark:
        return PresetThemes.iosDark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark
            ? PresetThemes.iosDark
            : PresetThemes.iosLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _themeMode == ThemeMode.dark
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: ChatView(
          controller: _chatController,
          theme: _getCurrentTheme(),
          title: 'AI对话演示',
          welcomeMessage: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.smart_toy,
                size: 80,
                color: Colors.blue.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                '欢迎使用AI聊天演示',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                '这是一个基于ai_chat_flutter库的演示应用\n您可以尝试与AI助手进行对话',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildSuggestionChip('你好'),
                  _buildSuggestionChip('今天天气怎么样？'),
                  _buildSuggestionChip('给我讲个笑话'),
                  _buildSuggestionChip('介绍一下Flutter'),
                  _buildSuggestionChip('帮我写一首诗'),
                ],
              ),
            ],
          ),
          onMessageTap: (message) {
            _showMessageDetails(message);
          },
          onMessageLongPress: (message) {
            _showMessageActions(message);
          },
        ),
      ),
    );
  }

  /// 构建建议标签
  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _chatController.sendMessage(text);
      },
      avatar: const Icon(Icons.send, size: 16),
    );
  }

  /// 显示消息详情
  void _showMessageDetails(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${message.role.description}消息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态: ${message.status.description}'),
            Text('时间: ${message.timestamp.toString().substring(0, 19)}'),
            if (message.tokenCount != null)
              Text('Tokens: ${message.tokenCount}'),
            const SizedBox(height: 12),
            const Text('内容:'),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(message.content),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message.content));
              Navigator.of(context).pop();
              _showSuccessSnackBar('已复制到剪贴板');
            },
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }

  /// 显示消息操作菜单
  void _showMessageActions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('复制消息'),
            onTap: () {
              Navigator.of(context).pop();
              Clipboard.setData(ClipboardData(text: message.content));
              _showSuccessSnackBar('已复制到剪贴板');
            },
          ),
          if (message.role.isUser)
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('重新发送'),
              onTap: () {
                Navigator.of(context).pop();
                _chatController.retryMessage(message.id);
              },
            ),
          if (message.role.isUser || message.role.isAssistant)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除消息', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _chatController.deleteMessage(message.id);
                _showSuccessSnackBar('消息已删除');
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
