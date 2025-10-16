import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:yene_farm/models/chat_message.dart';
import 'package:yene_farm/services/ai_service.dart';

class ChatBotProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  final List<ChatMessage> _messages = [];
  bool _isListening = false;
  bool _isLoading = false;
  String _selectedLanguage = 'am';
  String _userRegion = 'Addis Ababa';
  String _userCropType = '';

  List<ChatMessage> get messages => _messages;
  bool get isListening => _isListening;
  bool get isLoading => _isLoading;
  String get selectedLanguage => _selectedLanguage;

  ChatBotProvider() {
    _initializeSpeech();
    _initializeTTS();
    _addWelcomeMessage();
  }

  void _initializeSpeech() async {
    bool available = await _speechToText.initialize();
    if (!available) {
      print('Speech recognition not available');
    }
  }

  void _initializeTTS() async {
    await _flutterTts.setLanguage("am-ET");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text: _selectedLanguage == 'am' 
          ? 'ሰላም! የYeneFarm AI አማካሪ ነኝ 🌾\n\nበግብርና፣ የዕህል ዋጋ፣ የበሽታ መከላከል እና ሌሎችም ረዳት ልጠይቅ?\n\nእርዳታ ለማግኘት ፡\n• ጥያቄዎን ይጻፉ\n• ድምጽ ይጠቀሙ (🎤)\n• የአትክልት ፎቶ ያንሱ (📷)'
          : 'Hello! I am YeneFarm AI Assistant 🌾\n\nHow can I help with farming, crop prices, disease prevention, and more?\n\nTo get assistance:\n• Type your question\n• Use voice (🎤)\n• Upload crop photo (📷)',
      isUser: false,
      timestamp: DateTime.now(),
      messageType: MessageType.text,
      language: _selectedLanguage,
    );
    _messages.add(welcomeMessage);
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      messageType: MessageType.text,
      language: _selectedLanguage,
    );
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    // Get AI response
    try {
      final aiResponse = await _aiService.getAIResponse(
        text, 
        _selectedLanguage,
        cropType: _userCropType,
        region: _userRegion,
      );
      _messages.add(aiResponse);
      
      // Speak the response
      await _speakResponse(aiResponse.text);
    } catch (e) {
      final errorMessage = ChatMessage(
        text: _selectedLanguage == 'am'
            ? 'ይቅርታ፣ ምላሽ ለመስጠት አልተቻለም። እባክዎ እንደገና ይሞክሩ።'
            : 'Sorry, I could not generate a response. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
        language: _selectedLanguage,
      );
      _messages.add(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize();
    
    if (available) {
      _isListening = true;
      notifyListeners();
      
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            sendMessage(result.recognizedWords);
            _isListening = false;
            notifyListeners();
          }
        },
        localeId: _selectedLanguage == 'am' ? 'am_ET' : 'en_US',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  Future<void> _speakResponse(String text) async {
    await _flutterTts.speak(text);
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    _initializeTTS(); // Reinitialize TTS with new language
    notifyListeners();
  }

  void setUserContext(String region, String cropType) {
    _userRegion = region;
    _userCropType = cropType;
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  void analyzeCropImage(String imagePath) async {
    _isLoading = true;
    notifyListeners();

    // Add user image message
    final imageMessage = ChatMessage(
      text: _selectedLanguage == 'am' ? 'የአትክልት ፎቶ አቀረብኩ' : 'I uploaded a crop photo',
      isUser: true,
      timestamp: DateTime.now(),
      messageType: MessageType.image,
      language: _selectedLanguage,
      imageUrl: imagePath,
    );
    _messages.add(imageMessage);
    notifyListeners();

    try {
      final analysis = await _aiService.analyzeCropImage(imagePath, _selectedLanguage);
      final analysisMessage = ChatMessage(
        text: analysis,
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.imageAnalysis,
        language: _selectedLanguage,
      );
      _messages.add(analysisMessage);
      
      // Speak the analysis
      await _speakResponse(analysis);
    } catch (e) {
      final errorMessage = ChatMessage(
        text: _selectedLanguage == 'am'
            ? 'የምስል ትንተና አልተሳካም። እባክዎ እንደገና ይሞክሩ።'
            : 'Image analysis failed. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
        language: _selectedLanguage,
      );
      _messages.add(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }
}