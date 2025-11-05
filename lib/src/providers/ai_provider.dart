import 'dart:async';
import '../models/chat_message.dart';

/// AI配置选项
class AiConfig {
  /// API密钥
  final String apiKey;

  /// 基础URL
  final String? baseUrl;

  /// 模型名称
  final String model;

  /// 最大令牌数
  final int? maxTokens;

  /// 温度参数（控制回复的随机性）
  final double? temperature;

  /// 顶部P采样参数
  final double? topP;

  /// 频率惩罚参数
  final double? frequencyPenalty;

  /// 存在惩罚参数
  final double? presencePenalty;

  /// 自定义请求头
  final Map<String, String>? headers;

  /// 超时时间（秒）
  final int? timeout;

  const AiConfig({
    required this.apiKey,
    this.baseUrl,
    required this.model,
    this.maxTokens,
    this.temperature,
    this.topP,
    this.frequencyPenalty,
    this.presencePenalty,
    this.headers,
    this.timeout,
  });

  /// 从JSON创建配置对象
  factory AiConfig.fromJson(Map<String, dynamic> json) {
    return AiConfig(
      apiKey: json['apiKey'] as String,
      baseUrl: json['baseUrl'] as String?,
      model: json['model'] as String,
      maxTokens: json['maxTokens'] as int?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['topP'] as num?)?.toDouble(),
      frequencyPenalty: (json['frequencyPenalty'] as num?)?.toDouble(),
      presencePenalty: (json['presencePenalty'] as num?)?.toDouble(),
      headers: (json['headers'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
      timeout: json['timeout'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'model': model,
      'maxTokens': maxTokens,
      'temperature': temperature,
      'topP': topP,
      'frequencyPenalty': frequencyPenalty,
      'presencePenalty': presencePenalty,
      'headers': headers,
      'timeout': timeout,
    };
  }

  /// 创建配置副本
  AiConfig copyWith({
    String? apiKey,
    String? baseUrl,
    String? model,
    int? maxTokens,
    double? temperature,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
    Map<String, String>? headers,
    int? timeout,
  }) {
    return AiConfig(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      headers: headers ?? this.headers,
      timeout: timeout ?? this.timeout,
    );
  }
}

/// AI Provider抽象类
/// 定义了AI服务提供商需要实现的接口
abstract class AiProvider {
  /// Provider配置
  AiConfig get config;

  /// 流式对话接口
  ///
  /// [messages] 历史对话消息列表
  /// [onToken] 接收到新token时的回调函数
  /// [onDone] 流式输出完成时的回调函数
  /// [onError] 发生错误时的回调函数
  /// [options] 额外的选项参数
  Future<void> stream({
    required List<ChatMessage> messages,
    required Function(String token) onToken,
    required Function() onDone,
    required Function(Object error) onError,
    Map<String, dynamic>? options,
  });

  /// 完整对话接口（非流式）
  ///
  /// [messages] 历史对话消息列表
  /// [options] 额外的选项参数
  /// 返回完整的回复内容
  Future<String> complete({
    required List<ChatMessage> messages,
    Map<String, dynamic>? options,
  });

  /// 检查Provider是否已正确配置
  bool get isConfigured;

  /// 获取支持的模型列表
  Future<List<String>> getSupportedModels();

  /// 测试连接
  Future<bool> testConnection();

  /// 重置Provider状态
  void reset();

  /// 释放资源
  void dispose();
}

/// AI Provider异常类
class AiProviderException implements Exception {
  /// 错误消息
  final String message;

  /// 错误代码
  final String? code;

  /// 错误详情
  final dynamic details;

  /// 异常类型
  final AiProviderErrorType type;

  const AiProviderException({
    required this.message,
    this.code,
    this.details,
    this.type = AiProviderErrorType.unknown,
  });

  @override
  String toString() {
    return 'AiProviderException(type: $type, message: $message, code: $code)';
  }
}

/// AI Provider错误类型枚举
enum AiProviderErrorType {
  /// 网络错误
  network,

  /// 认证错误
  authentication,

  /// 配额不足
  quota,

  /// 模型不可用
  modelUnavailable,

  /// 请求超时
  timeout,

  /// 参数错误
  invalidParameters,

  /// 服务器错误
  serverError,

  /// 未知错误
  unknown,
}
