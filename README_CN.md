# 🧠 AI Chat Flutter

一个 **可定制的 Flutter AI 对话界面组件库**，用于快速构建类似 ChatGPT、Claude、Gemini 等智能对话界面。支持 **流式回复、气泡样式自定义、消息状态管理** 等特性，轻松打造现代化 AI 聊天体验。

## ✨ 功能特性

* 💬 **流式回复**：支持实时输出，模拟打字机效果
* 🎨 **气泡样式自定义**：轻松自定义用户与助手消息外观
* 🔄 **消息状态管理**：内置发送中、已发送、失败等状态
* 📜 **历史记录展示**：支持加载历史对话记录
* 🧩 **高度可扩展**：可自由接入任意 AI Provider（OpenAI、Claude、自建接口等）
* 🌗 **暗黑模式支持**：自动适配系统主题
* 💾 **本地数据存储**：基于 Hive 的数据持久化
* 🎯 **Riverpod 状态管理**：响应式状态管理

## 🚀 快速开始

### 1️⃣ 添加依赖

在项目 `pubspec.yaml` 中添加：

```yaml
dependencies:
  ai_chat_flutter:
    path: ../ai_chat_flutter  # 本地开发
  # 或
  # ai_chat_flutter: ^0.1.0  # 发布版本
```

然后执行：

```bash
flutter pub get
```

### 2️⃣ 导入包

```dart
import 'package:ai_chat_flutter/ai_chat_flutter.dart';
```

### 3️⃣ 基础使用示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_chat_flutter/ai_chat_flutter.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat Demo',
      theme: ThemeData(useMaterial3: true),
      home: const ChatExamplePage(),
    );
  }
}

class ChatExamplePage extends StatefulWidget {
  const ChatExamplePage({super.key});

  @override
  State<ChatExamplePage> createState() => _ChatExamplePageState();
}

class _ChatExamplePageState extends State<ChatExamplePage> {
  late final ChatController _controller;

  @override
  void initState() {
    super.initState();

    // 创建聊天控制器
    _controller = ChatController.create(
      provider: MockAiProvider(), // 使用Mock Provider进行演示
      sessionTitle: 'AI对话',
      modelName: 'mock-gpt-4',
      systemPrompt: SystemPrompts.assistant,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: SimpleChatView(
        controller: _controller,
        theme: PresetThemes.iosLight, // 使用预设主题
        welcomeMessage: '您好！我是AI助手，有什么可以帮助您的吗？',
      ),
    );
  }
}
```

## 📦 核心组件

### ChatController
聊天控制器，负责管理消息状态和与AI Provider的交互：

```dart
// 创建控制器
final controller = ChatController.create(
  provider: OpenAiProvider(
    config: AiConfig(
      apiKey: 'your-api-key',
      model: 'gpt-3.5-turbo',
    ),
  ),
  sessionTitle: 'AI对话',
);

// 发送消息
await controller.sendMessage('你好！');

// 清空消息
await controller.clearMessages();
```

### ChatView
完整的聊天界面组件：

```dart
ChatView(
  controller: controller,
  theme: ChatTheme.dark(), // 深色主题
  title: 'AI助手',
  showAppBar: true,
  autoScroll: true,
  onMessageTap: (message) => print('点击消息: ${message.content}'),
  onMessageLongPress: (message) => print('长按消息'),
)
```

### ChatTheme
自定义聊天界面主题：

```dart
final customTheme = ChatTheme.custom(
  primaryColor: Colors.blue,
  backgroundColor: Colors.white,
  userBubbleColor: Colors.blue.shade600,
  assistantBubbleColor: Colors.grey.shade200,
);
```

## 🎨 主题定制

### 预设主题

```dart
// iOS风格浅色主题
PresetThemes.iosLight

// iOS风格深色主题
PresetThemes.iosDark

// 蓝色主题
PresetThemes.blue

// 绿色主题
PresetThemes.green

// 紫色主题
PresetThemes.purple
```

### 自定义主题

```dart
final theme = ChatTheme(
  userBubbleColor: Colors.blue,
  assistantBubbleColor: Colors.grey.shade200,
  userTextStyle: const TextStyle(color: Colors.white),
  assistantTextStyle: const TextStyle(color: Colors.black),
  messageSpacing: 12.0,
  showAvatars: true,
  showTimestamps: true,
);
```

## 🤖 AI Provider

### Mock AI Provider（用于测试）

```dart
final mockProvider = MockAiProvider();
```

### OpenAI Provider

```dart
final openaiProvider = OpenAiProvider(
  config: AiConfig(
    apiKey: 'your-openai-api-key',
    model: 'gpt-3.5-turbo',
    maxTokens: 1000,
    temperature: 0.7,
  ),
);
```

### 自定义 Provider

```dart
class MyAiProvider implements AiProvider {
  @override
  AiConfig get config => /* 配置信息 */;

  @override
  Future<void> stream({
    required List<ChatMessage> messages,
    required Function(String) onToken,
    required Function() onDone,
    required Function(Object) onError,
    Map<String, dynamic>? options,
  }) async {
    // 实现流式对话逻辑
  }

  @override
  Future<String> complete({
    required List<ChatMessage> messages,
    Map<String, dynamic>? options,
  }) async {
    // 实现完整对话逻辑
    return "回复内容";
  }

  // 实现其他必需方法...
}
```

## 📱 示例应用

项目包含完整的示例应用，展示了库的各种功能：

```bash
cd example
flutter run
```

示例应用特性：
- 🎨 主题切换（浅色/深色）
- ⚙️ 模型配置
- 💬 流式对话演示
- 📋 消息操作（复制、删除、重试）
- 🎯 建议标签快速发送

## 📁 项目结构

```
ai_chat_flutter/
├── lib/
│   ├── ai_chat_flutter.dart     # 主库导出文件
│   └── src/
│       ├── controllers/         # 控制器
│       │   └── chat_controller.dart
│       ├── models/              # 数据模型
│       │   ├── chat_message.dart
│       │   ├── chat_session.dart
│       │   ├── message_role.dart
│       │   └── message_status.dart
│       ├── providers/           # AI服务提供商
│       │   ├── ai_provider.dart
│       │   ├── mock_ai_provider.dart
│       │   └── openai_provider.dart
│       ├── services/            # 服务类
│       │   └── hive_service.dart
│       ├── themes/              # 主题配置
│       │   └── chat_theme.dart
│       ├── widgets/             # UI组件
│       │   ├── chat_view.dart
│       │   ├── message_bubble.dart
│       │   └── message_input.dart
│       └── hive_types.dart      # Hive类型定义
├── example/                     # 示例应用
│   ├── lib/
│   │   └── main.dart
│   └── pubspec.yaml
└── pubspec.yaml
```

## 🔧 开发环境

- Flutter: >=3.10.0
- Dart: >=3.0.0
- Riverpod: ^2.4.9
- Hive: ^2.2.3

## 📄 许可证

本项目基于 **MIT License** 开源。

欢迎提交 PR 或 issue，一起完善 Flutter AI 对话生态！

## 🤝 贡献

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📞 支持

如果您在使用过程中遇到问题，欢迎：

- 📋 提交 [Issue](https://github.com/your-username/ai_chat_flutter/issues)
- 💬 参与 [讨论](https://github.com/your-username/ai_chat_flutter/discussions)
- 📧 发送邮件至 your-email@example.com

---

⭐ 如果这个项目对您有帮助，请给我们一个 Star！