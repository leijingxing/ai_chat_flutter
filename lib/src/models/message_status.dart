import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_status.g.dart';

/// 消息状态枚举
/// 定义了消息在生命周期中的不同状态
@HiveType(typeId: 0)
@JsonEnum()
enum MessageStatus {
  /// 发送中 - 用户刚发送消息，等待AI响应
  @HiveField(0)
  sending,

  /// 流式输出中 - AI正在逐字输出回复
  @HiveField(1)
  streaming,

  /// 已完成 - AI回复完成
  @HiveField(2)
  sent,

  /// 失败 - 请求失败或超时
  @HiveField(3)
  error,

  /// 重试中 - 重新发送消息
  @HiveField(4)
  retrying,
}

/// 消息状态扩展方法
extension MessageStatusExtension on MessageStatus {
  /// 获取状态的中文描述
  String get description {
    switch (this) {
      case MessageStatus.sending:
        return '发送中';
      case MessageStatus.streaming:
        return '输入中';
      case MessageStatus.sent:
        return '已发送';
      case MessageStatus.error:
        return '发送失败';
      case MessageStatus.retrying:
        return '重试中';
    }
  }

  /// 判断是否正在处理中（发送中、流式中、重试中）
  bool get isProcessing =>
      this == MessageStatus.sending ||
      this == MessageStatus.streaming ||
      this == MessageStatus.retrying;

  /// 判断是否为最终状态（已完成、失败）
  bool get isFinal => this == MessageStatus.sent || this == MessageStatus.error;
}
