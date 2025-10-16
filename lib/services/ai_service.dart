import 'package:yene_farm/models/chat_message.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Local AI responses for common farming questions in Amharic
  final Map<String, String> _localAmharicResponses = {
    'ሰላም': 'ሰላም! የኔ እርሻ በግብርና አማካሪ እርዳታ ላይ እንኳን በደህና መጡ። እንዴት ልርዳዎት?',
    'hello': 'Hello! Welcome to YeneFarm AI assistant. How can I help you today?',
    'ውሃ ምን ያህል ማጠጣት አለብኝ': 'የውሃ መጠቀሚያ በአትክልት ዓይነት ይለያል። በትክክል ለመረዳት ምን ዓይነት አትክልት እያበቁ ነው?',
    'how much water': 'Water requirements depend on the crop type. To give precise advice, what type of crop are you growing?',
    'ለበሽታ ምን ማድረግ አለብኝ': 'የተወሰነ በሽታ ለመመዝገብ የአትክልትዎን ፎቶ ያንሱ ወይም ምልክቶቹን ይግለጹ።',
    'disease treatment': 'To identify diseases accurately, please upload a photo of your crop or describe the symptoms.',
    'ፍራፍሬ እንዴት መትከል እችላለሁ': 'ፍራፍሬ ለመትከል፦\n1. በቂ ፀሐይ ያለው ቦታ ይምረጡ\n2. ለፍራፍሬ ዓይነት ተስማሚ አፈር\n3. መደበኛ ውሃ መስጠት\n4. አጥር መጨመር\nምን ዓይነት ፍራፍሬ መትከል ትፈልጋለህ?',
    'fertilizer': 'For fertilizer recommendations:\n1. Soil testing is recommended\n2. Organic compost is best for most crops\n3. Apply during planting and growth periods\nWhat crop are you planning to fertilize?',
    'የበቅሎ እርሻ': 'የበቅሎ እርሻ ለመስራት፦\n• በተፈጥሮ አፈር ይትከሉ\n• በሳምንት 2-3 ጊዜ ውሃ ይጎንቱ\n• ከጠዋት ወይም ማታ ይጎንቱ\n• አፈር እርጥብ መሆኑን ያረጋግጡ',
    'coffee farming': 'For coffee farming:\n• Plant in shaded areas\n• Well-drained soil is essential\n• Regular pruning needed\n• Harvest when berries are red',
    'teff cultivation': 'For teff cultivation:\n• Fine seedbed preparation\n• Light irrigation frequently\n• Weed control is crucial\n• Harvest when stems turn yellow',
  };

  // Enhanced AI response with context awareness
  Future<ChatMessage> getAIResponse(String query, String language, {String? cropType, String? region}) async {
    // First, check local responses for quick answers
    final lowerQuery = query.toLowerCase();
    if (_localAmharicResponses.containsKey(lowerQuery)) {
      return ChatMessage(
        text: _localAmharicResponses[lowerQuery]!,
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
        language: language,
      );
    }

    // For complex queries, use API (mock implementation - replace with real API)
    try {
      final response = await _callAIBackend(query, language, cropType: cropType, region: region);
      return ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
        language: language,
      );
    } catch (e) {
      // Fallback response
      return ChatMessage(
        text: _getFallbackResponse(query, language),
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
        language: language,
      );
    }
  }

  Future<String> _callAIBackend(String query, String language, {String? cropType, String? region}) async {
    // Mock API call - Replace with actual OpenAI, Hugging Face, or local model
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate intelligent responses based on query content
    if (query.contains('water') || query.contains('ውሃ')) {
      return language == 'am' 
          ? 'የውሃ መጠቀሚያ በአትክልት ዓይነት፣ የአፈር አይነት እና የአየር ንብረት ይወሰናል። በአጠቃላይ አትክልቶች በሳምንት 2-3 ጊዜ ውሃ ይፈልጋሉ። ለበቈ አትክልት በተለይ አፈር እርጥብ መሆኑን ማረጋገጥ ያስፈልጋል።'
          : 'Water usage depends on crop type, soil type, and weather. Most crops need water 2-3 times per week. For leafy vegetables, ensure the soil remains moist.';
    } else if (query.contains('price') || query.contains('ዋጋ')) {
      return language == 'am'
          ? 'የአትክልት ዋጋዎች በገበያ ፍላጎት፣ ወቅት እና ቦታ ይለያያሉ። ለትክክለኛ ዋጋ በየክልሉ የዋጋ ትንበያ አማካሪዎችን ይመልከቱ። በአሁኑ ጊዜ የቴፍ ዋጋ ከETB 80-90 ከኪሎ ግራም ይለያያል።'
          : 'Crop prices vary by market demand, season, and location. Check regional price predictors for accurate pricing. Currently, teff prices range from ETB 80-90 per kilogram.';
    } else if (query.contains('disease') || query.contains('በሽታ')) {
      return language == 'am'
          ? 'የአትክልት በሽታዎችን ለመከላከል፦\n• ጤናማ ዘር ይጠቀሙ\n• አፈርን በጥራት ያዘጋጁ\n• ተገቢውን ርቀት ይጠብቁ\n• በጊዜው ቅጠሎችን ያጥፉ\nለትክክለኛ ምክር የበሽታውን ፎቶ ያንሱ።'
          : 'To prevent crop diseases:\n• Use healthy seeds\n• Prepare soil properly\n• Maintain proper spacing\n• Remove affected leaves promptly\nFor accurate advice, please upload a photo of the disease.';
    } else {
      return language == 'am'
          ? 'ለበለጠ ትክክለኛ ምክር፣ እባክዎ የሚከተሉትን ያብራሩ፦\n1. ምን ዓይነት አትክልት\n2. ቦታዎ\n3. የአፈር ሁኔታ\n4. የተጋጠሙት ችግሮች\nወይም የአትክልትዎን ፎቶ ያንሱ ለበለጠ ትክክለኛ አማካይ።'
          : 'For more accurate advice, please specify:\n1. Crop type\n2. Your location\n3. Soil condition\n4. Specific challenges faced\nOr upload a photo of your crop for precise assistance.';
    }
  }

  String _getFallbackResponse(String query, String language) {
    return language == 'am'
        ? 'እባክዎ ጥያቄዎን በበለጠ ያብራሩ። ለአብዛኛዎቹ የግብርና ጥያቄዎች ልርዳችሁ እችላለሁ። በተለይም ስለ፡\n• ውሃ መጠቀም\n• አፈር እርባታ\n• በሽታ መከላከል\n• የዕህል ዋጋ\n• የተለያዩ አትክልቶች እርሻ'
        : 'Please elaborate your question. I can help with most farming-related queries. Especially about:\n• Water usage\n• Soil fertility\n• Disease prevention\n• Crop prices\n• Various crop cultivation';
  }

  // Image analysis for crop disease detection
  Future<String> analyzeCropImage(String imagePath, String language) async {
    // Mock image analysis - Integrate with TensorFlow Lite or Google ML Kit
    await Future.delayed(const Duration(seconds: 3));
    
    return language == 'am'
        ? '🌾 ከፎቶው አጋምሼ የሚከተለውን ማየት ተችሎኛል፦\n\n✅ **ጥሩ ነገሮች:**\n• አትክልቱ በአጠቃላይ ጤናማ ይመስላል\n• አረንጓዴ ቀለም በጥሩ ሁኔታ ነው\n• እድገት በተለመደው እየሆነ ነው\n\n⚠️ **ሊያጋጥምዎት የሚችሉ ጉዳዮች:**\n• ትንሽ የተፈጥሮ ነጥቦች አሉ\n• አንዳንድ ቅጠሎች ትንሽ የተለያዩ ይመስላሉ\n\n💡 **ምክር:**\n• የበለጠ ግልጽ ፎቶ ለመመዝገብ ይሞክሩ\n• በሚቀጥሉት ቀናት ለውጦችን ይከታተሉ\n• አፈር እርጥብ መሆኑን ያረጋግጡ'
        : '🌾 **From the image analysis:**\n\n✅ **Positive Observations:**\n• The crop appears generally healthy\n• Green color is in good condition\n• Growth seems to be progressing normally\n\n⚠️ **Potential Concerns:**\n• Some natural spotting present\n• A few leaves show minor variations\n\n💡 **Recommendations:**\n• Try uploading a clearer photo for better analysis\n• Monitor for changes in the coming days\n• Ensure soil moisture levels are adequate';
  }

  // Voice response generation
  Future<void> speakResponse(String text, String language) async {
    // Implementation for text-to-speech
    // This would integrate with flutter_tts package
    // For now, it's a placeholder
    print('Speaking: $text in $language');
  }
}