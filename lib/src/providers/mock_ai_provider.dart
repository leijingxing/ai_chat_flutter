import 'dart:async';
import 'dart:math';
import 'ai_provider.dart';
import '../models/chat_message.dart';
import '../models/message_role.dart';

/// Mock AI Provider
/// 用于测试和演示的模拟AI服务提供商
class MockAiProvider implements AiProvider {
  @override
  AiConfig get config => const AiConfig(
    apiKey: 'mock-api-key',
    model: 'mock-model',
    temperature: 0.7,
    maxTokens: 1000,
  );

  /// 预设的回复模板
  static const List<String> _responseTemplates = [
    '这是一个很好的问题！让我来详细为您解答...',
    '根据我的理解，您想了解的是...',
    '我很乐意帮助您解决这个问题。���先...',
    '这是一个复杂的话题，我们可以从几个方面来讨论...',
    '感谢您的提问！基于我掌握的信息...',
    '让我为您分析一下这个问题的关键点...',
    '您提出的这个问题很有意思。事实上...',
    '关于这个问题，不同的人可能会有不同的看法，但我认为...',
  ];

  /// 随机数生成器
  final Random _random = Random();

  /// 流式回复的延迟时间范围（毫秒）
  final int _minDelay = 50;
  final int _maxDelay = 200;

  @override
  Future<void> stream({
    required List<ChatMessage> messages,
    required Function(String token) onToken,
    required Function() onDone,
    required Function(Object error) onError,
    Map<String, dynamic>? options,
  }) async {
    try {
      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: _random.nextInt(1000) + 500));

      // 生成回复内容
      final response = _generateResponse(messages);
      final words = response.split(' ');

      // 模拟流式输出
      for (int i = 0; i < words.length; i++) {
        // 模拟打字机效果
        await Future.delayed(
          Duration(
            milliseconds: _random.nextInt(_maxDelay - _minDelay) + _minDelay,
          ),
        );

        // 发送当前单词（添加空格，除了最后一个单词）
        final token = i == words.length - 1 ? words[i] : '${words[i]} ';
        onToken(token);

        // 模拟偶发的错误（5%概率）
        if (_random.nextDouble() < 0.05) {
          onError(
            const AiProviderException(
              message: '模拟网络错误',
              type: AiProviderErrorType.network,
            ),
          );
          return;
        }
      }

      // 完成流式输出
      onDone();
    } catch (e) {
      onError(
        AiProviderException(
          message: 'Mock provider error: $e',
          type: AiProviderErrorType.unknown,
        ),
      );
    }
  }

  @override
  Future<String> complete({
    required List<ChatMessage> messages,
    Map<String, dynamic>? options,
  }) async {
    try {
      // 模拟网络延迟
      await Future.delayed(
        Duration(milliseconds: _random.nextInt(2000) + 1000),
      );

      // 生成并返回完整回复
      return _generateResponse(messages);
    } catch (e) {
      throw AiProviderException(
        message: 'Mock provider error: $e',
        type: AiProviderErrorType.unknown,
      );
    }
  }

  @override
  bool get isConfigured => true;

  @override
  Future<List<String>> getSupportedModels() async {
    // 模拟获取支持的模型列表
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      'mock-gpt-3.5-turbo',
      'mock-gpt-4',
      'mock-claude-3',
      'mock-gemini-pro',
    ];
  }

  @override
  Future<bool> testConnection() async {
    try {
      // 模拟连接测试
      await Future.delayed(const Duration(milliseconds: 500));
      return _random.nextDouble() > 0.1; // 90%成功率
    } catch (e) {
      return false;
    }
  }

  @override
  void reset() {
    // Mock provider 不需要重置状态
  }

  @override
  void dispose() {
    // Mock provider 不需要释放资源
  }

  /// 生成模拟回复内容
  String _generateResponse(List<ChatMessage> messages) {
    // 获取最后一条用户消息
    final lastUserMessage = messages.lastWhere(
      (msg) => msg.role.isUser,
      orElse: () => messages.isEmpty
          ? ChatMessage.user(id: 'default', content: '你好')
          : messages.first,
    );

    // 基于用户消息生成回复
    final userContent = lastUserMessage.content.toLowerCase();
    String response;

    // 根据关键词选择回复模板
    if (userContent.contains('你好') || userContent.contains('hello')) {
      response = '您好！很高兴为您服务。我是一个AI助手，可以帮助您解答问题、提��信息和建议。请问有什么可以帮助您的吗？';
    } else if (userContent.contains('天气')) {
      response = '很抱歉，我无法获取实时天气信息。建议您查看天气应用或网站获取最新的天气预报。如果您有其他问题，我很乐意为您解答！';
    } else if (userContent.contains('时间')) {
      final now = DateTime.now();
      response =
          '现在时间是 ${now.year}年${now.month}月${now.day}日 ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    } else if (userContent.contains('谢谢') || userContent.contains('感谢')) {
      response = '不客气！很高兴能帮助到您。如果还有其他问题，请随时告诉我。祝您生活愉快！';
    } else if (userContent.contains('再见') || userContent.contains('拜拜')) {
      response = '再见！期待下次与您交流。如果有任何需要帮助的地方，随时欢迎您回来咨询。祝您一切顺利！';
    } else {
      // 随机选择一个回复模板
      final template =
          _responseTemplates[_random.nextInt(_responseTemplates.length)];

      // 添加一些具体内容
      final topics = ['人工智能', '机器学习', '自然语言处理', '数据分析', '软件开发'];
      final topic = topics[_random.nextInt(topics.length)];

      response =
          '$template $topic 是一个非常有趣和前沿的领域。随着技术的不断发展，它在各个行业都有着广泛的应用前景。如果您对这个话题感兴趣，我们可以深入探讨相关的技术细节、应用场景或者发展趋势。';
    }

    // 随机调整回复长度
    final targetLength = _random.nextInt(200) + 100; // 100-300字符
    if (response.length > targetLength) {
      response = '${response.substring(0, targetLength)}...';
    } else if (response.length < targetLength / 2) {
      // 如果太短，添加一些通用内容
      response += ' 这个话题涉及很多方面，包括技术原理、实际应用、未来前景等等。我们可以从您最感兴趣的部分开始讨论。';
    }

    return response;
  }
}
