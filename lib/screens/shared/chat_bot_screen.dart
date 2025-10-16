import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yene_farm/providers/chatbot_provider.dart';
import 'package:yene_farm/widgets/ai_chat_bubble.dart';
import 'package:yene_farm/utils/colors.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickAndAnalyzeImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      final provider = Provider.of<ChatBotProvider>(context, listen: false);
      provider.analyzeCropImage(image.path);
      _scrollToBottom();
    }
  }

  Future<void> _takePhotoAndAnalyze() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      final provider = Provider.of<ChatBotProvider>(context, listen: false);
      provider.analyzeCropImage(image.path);
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final provider = Provider.of<ChatBotProvider>(context, listen: false);
      provider.sendMessage(text);
      _textController.clear();
      _scrollToBottom();
    }
  }

  void _showImageSourceDialog() {
    final languageProvider = Provider.of<ChatBotProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: YeneFarmColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: YeneFarmColors.primaryGreen),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndAnalyzeImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: YeneFarmColors.primaryGreen),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhotoAndAnalyze();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'YeneFarm AI Assistant',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: YeneFarmColors.primaryGreen,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                Provider.of<ChatBotProvider>(context, listen: false).setLanguage(value);
              },
              icon: const Icon(Icons.language_rounded, color: Colors.white),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'am', child: Text('አማርኛ')),
                const PopupMenuItem(value: 'en', child: Text('English')),
                const PopupMenuItem(value: 'om', child: Text('Afan Oromo')),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
              onPressed: () {
                Provider.of<ChatBotProvider>(context, listen: false).clearChat();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatBotProvider>(
                builder: (context, provider, child) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages[index];
                      return AiChatBubble(message: message);
                    },
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Consumer<ChatBotProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              if (provider.isLoading)
                LinearProgressIndicator(
                  backgroundColor: YeneFarmColors.primaryGreen.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(YeneFarmColors.primaryGreen),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Camera Button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: YeneFarmColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt_rounded, size: 20),
                      color: YeneFarmColors.primaryGreen,
                      onPressed: _showImageSourceDialog,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Text Input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: YeneFarmColors.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: YeneFarmColors.border),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: provider.selectedLanguage == 'am' 
                              ? 'ጥያቄዎን ይጻፉ...' 
                              : 'Type your question...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Voice/Send Button
                  GestureDetector(
                    onTap: provider.isListening ? null : _sendMessage,
                    onLongPress: () {
                      if (!provider.isLoading) {
                        Provider.of<ChatBotProvider>(context, listen: false).toggleListening();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: provider.isListening 
                            ? YeneFarmColors.sunsetGradient
                            : YeneFarmColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: YeneFarmColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        provider.isListening ? Icons.mic_off_rounded : Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Voice Listening Indicator
              if (provider.isListening)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mic_rounded, size: 16, color: YeneFarmColors.warningRed),
                      const SizedBox(width: 4),
                      Text(
                        provider.selectedLanguage == 'am' ? 'ድምጽ እየተሰማ ነው...' : 'Listening...',
                        style: const TextStyle(
                          color: YeneFarmColors.warningRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}