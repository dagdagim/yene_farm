import 'package:hive/hive.dart';

part 'chat_message.g.dart';

enum MessageType {
  text,
  image,
  voice,
  imageAnalysis,
  priceInfo,
  weatherAlert,
}

@HiveType(typeId: 4)
class ChatMessage {
  @HiveField(0)
  final String text;
  
  @HiveField(1)
  final bool isUser;
  
  @HiveField(2)
  final DateTime timestamp;
  
  @HiveField(3)
  final MessageType messageType;
  
  @HiveField(4)
  final String language;
  
  @HiveField(5)
  final String? imageUrl;
  
  @HiveField(6)
  final String? audioUrl;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.messageType = MessageType.text,
    required this.language,
    this.imageUrl,
    this.audioUrl,
  });
}