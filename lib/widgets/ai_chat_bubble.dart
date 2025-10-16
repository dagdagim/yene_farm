import 'package:flutter/material.dart';
import 'package:yene_farm/models/chat_message.dart';
import 'package:yene_farm/utils/colors.dart';

class AiChatBubble extends StatelessWidget {
  final ChatMessage message;

  const AiChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(),
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? YeneFarmColors.primaryGreen.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: message.isUser
                          ? YeneFarmColors.primaryGreen.withOpacity(0.3)
                          : YeneFarmColors.border,
                    ),
                    boxShadow: message.isUser ? [] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.messageType == MessageType.imageAnalysis)
                        _buildImageAnalysisHeader(),
                      Text(
                        message.text,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: YeneFarmColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: YeneFarmColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: const CircleAvatar(
        backgroundColor: YeneFarmColors.primaryGreen,
        radius: 16,
        child: Icon(Icons.agriculture_rounded, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: const CircleAvatar(
        backgroundColor: YeneFarmColors.accentYellow,
        radius: 16,
        child: Icon(Icons.person_rounded, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildImageAnalysisHeader() {
    return const Column(
      children: [
        Row(
          children: [
            Icon(Icons.photo_camera_rounded, size: 18, color: YeneFarmColors.primaryGreen),
            SizedBox(width: 6),
            Text(
              '🌾 Image Analysis',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: YeneFarmColors.primaryGreen,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Divider(color: YeneFarmColors.border),
        SizedBox(height: 8),
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}