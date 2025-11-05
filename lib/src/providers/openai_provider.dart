import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_provider.dart';
import '../models/chat_message.dart';
import '../models/message_role.dart';

/// OpenAI Provider
/// OpenAI API的服务提供商实现
class OpenAiProvider implements AiProvider {
  @override
  final AiConfig config;

  /// HTTP客户端
  final http.Client _client;

  /// OpenAI API的基础URL
  static const String _defaultBaseUrl = 'https://api.openai.com/v1';

  /// 构造函数
  OpenAiProvider({required this.config, http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<void> stream({
    required List<ChatMessage> messages,
    required Function(String token) onToken,
    required Function() onDone,
    required Function(Object error) onError,
    Map<String, dynamic>? options,
  }) async {
    try {
      final request = _buildStreamRequest(messages, options);
      final response = await _client.send(request);

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        throw _parseApiError(response.statusCode, errorBody);
      }

      // 处理流式���应
      await _processStreamResponse(response.stream, onToken, onError);
      onDone();
    } catch (e) {
      if (e is AiProviderException) {
        onError(e);
      } else {
        onError(
          AiProviderException(
            message: 'Stream request failed: $e',
            type: AiProviderErrorType.network,
          ),
        );
      }
    }
  }

  @override
  Future<String> complete({
    required List<ChatMessage> messages,
    Map<String, dynamic>? options,
  }) async {
    try {
      final request = _buildCompleteRequest(messages, options);
      final response = await _client.send(request);

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        throw _parseApiError(response.statusCode, errorBody);
      }

      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      return responseData['choices'][0]['message']['content'] as String;
    } catch (e) {
      if (e is AiProviderException) {
        rethrow;
      }
      throw AiProviderException(
        message: 'Complete request failed: $e',
        type: AiProviderErrorType.network,
      );
    }
  }

  @override
  bool get isConfigured {
    return config.apiKey.isNotEmpty;
  }

  @override
  Future<List<String>> getSupportedModels() async {
    try {
      final request = http.Request(
        'GET',
        Uri.parse('${config.baseUrl ?? _defaultBaseUrl}/models'),
      );
      request.headers.addAll(_buildHeaders());

      final response = await _client.send(request);

      if (response.statusCode != 200) {
        throw AiProviderException(
          message: 'Failed to get models: ${response.statusCode}',
          type: AiProviderErrorType.serverError,
        );
      }

      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      final models = <String>[];
      for (final model in responseData['data'] as List) {
        final id = model['id'] as String;
        // 只包含GPT模型
        if (id.startsWith('gpt-')) {
          models.add(id);
        }
      }

      return models;
    } catch (e) {
      if (e is AiProviderException) {
        rethrow;
      }
      throw AiProviderException(
        message: 'Failed to get supported models: $e',
        type: AiProviderErrorType.unknown,
      );
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      final models = await getSupportedModels();
      return models.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  void reset() {
    // OpenAI provider 不需要重置状态
  }

  @override
  void dispose() {
    _client.close();
  }

  /// 构建流式请求
  http.Request _buildStreamRequest(
    List<ChatMessage> messages,
    Map<String, dynamic>? options,
  ) {
    final url = Uri.parse(
      '${config.baseUrl ?? _defaultBaseUrl}/chat/completions',
    );
    final request = http.Request('POST', url);

    request.headers.addAll(_buildHeaders());
    request.body = jsonEncode({
      'model': options?['model'] ?? config.model,
      'messages': _convertMessages(messages),
      'stream': true,
      if (config.maxTokens != null) 'max_tokens': config.maxTokens,
      if (config.temperature != null) 'temperature': config.temperature,
      if (config.topP != null) 'top_p': config.topP,
      if (config.frequencyPenalty != null)
        'frequency_penalty': config.frequencyPenalty,
      if (config.presencePenalty != null)
        'presence_penalty': config.presencePenalty,
      ...?options,
    });

    return request;
  }

  /// 构建完整请求
  http.Request _buildCompleteRequest(
    List<ChatMessage> messages,
    Map<String, dynamic>? options,
  ) {
    final url = Uri.parse(
      '${config.baseUrl ?? _defaultBaseUrl}/chat/completions',
    );
    final request = http.Request('POST', url);

    request.headers.addAll(_buildHeaders());
    request.body = jsonEncode({
      'model': options?['model'] ?? config.model,
      'messages': _convertMessages(messages),
      'stream': false,
      if (config.maxTokens != null) 'max_tokens': config.maxTokens,
      if (config.temperature != null) 'temperature': config.temperature,
      if (config.topP != null) 'top_p': config.topP,
      if (config.frequencyPenalty != null)
        'frequency_penalty': config.frequencyPenalty,
      if (config.presencePenalty != null)
        'presence_penalty': config.presencePenalty,
      ...?options,
    });

    return request;
  }

  /// 构建请求头
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${config.apiKey}',
      ...?config.headers,
    };
  }

  /// 转换消息格式
  List<Map<String, String>> _convertMessages(List<ChatMessage> messages) {
    return messages
        .map(
          (message) => {
            'role': message.role.apiName,
            'content': message.content,
          },
        )
        .toList();
  }

  /// 处理流式响应
  Future<void> _processStreamResponse(
    Stream<List<int>> stream,
    Function(String token) onToken,
    Function(Object error) onError,
  ) async {
    try {
      await for (final chunk in stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);

            if (data == '[DONE]') {
              return;
            }

            try {
              final jsonData = jsonDecode(data);
              final choices = jsonData['choices'] as List;

              if (choices.isNotEmpty) {
                final delta = choices[0]['delta'];
                if (delta['content'] != null) {
                  onToken(delta['content'] as String);
                }
              }
            } catch (e) {
              // 忽略JSON解析错误
            }
          }
        }
      }
    } catch (e) {
      onError(
        AiProviderException(
          message: 'Failed to process stream: $e',
          type: AiProviderErrorType.network,
        ),
      );
    }
  }

  /// 解析API错误
  AiProviderException _parseApiError(int statusCode, String errorBody) {
    try {
      final errorData = jsonDecode(errorBody);
      final error = errorData['error'] as Map<String, dynamic>? ?? {};

      final message = error['message'] as String? ?? 'Unknown API error';
      final code = error['code'] as String?;
      final type = error['type'] as String?;

      return AiProviderException(
        message: message,
        code: code,
        type: _mapErrorType(statusCode, type),
        details: errorData,
      );
    } catch (e) {
      return AiProviderException(
        message: 'HTTP $statusCode: $errorBody',
        type: _mapErrorType(statusCode, null),
      );
    }
  }

  /// 映射错误类型
  AiProviderErrorType _mapErrorType(int statusCode, String? apiType) {
    if (statusCode == 401 || apiType?.contains('auth') == true) {
      return AiProviderErrorType.authentication;
    } else if (statusCode == 429 || apiType?.contains('rate') == true) {
      return AiProviderErrorType.quota;
    } else if (statusCode == 408 || apiType?.contains('timeout') == true) {
      return AiProviderErrorType.timeout;
    } else if (statusCode >= 500) {
      return AiProviderErrorType.serverError;
    } else if (apiType?.contains('model') == true) {
      return AiProviderErrorType.modelUnavailable;
    } else {
      return AiProviderErrorType.unknown;
    }
  }
}
