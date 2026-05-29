enum MessageType { text, postShare }

class MessageModel {
  final String messageId;
  final String fromUid;
  final String content;
  final MessageType type;
  final String? sharedPostId;
  final DateTime createdAt;

  const MessageModel({
    required this.messageId,
    required this.fromUid,
    required this.content,
    this.type = MessageType.text,
    this.sharedPostId,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String messageId) {
    return MessageModel(
      messageId: messageId,
      fromUid: map['fromUid'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      sharedPostId: map['sharedPostId'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'fromUid': fromUid,
        'content': content,
        'type': type.name,
        'sharedPostId': sharedPostId,
        'createdAt': createdAt.toIso8601String(),
      };

  MessageModel copyWith({
    String? content,
    MessageType? type,
    String? sharedPostId,
    DateTime? createdAt,
  }) {
    return MessageModel(
      messageId: messageId,
      fromUid: fromUid,
      content: content ?? this.content,
      type: type ?? this.type,
      sharedPostId: sharedPostId ?? this.sharedPostId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
