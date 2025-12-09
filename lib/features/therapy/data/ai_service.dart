import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../secrets.dart';

class SolAiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  
  static const String _systemPrompt = """
You are Sol, a gentle AI companion inside an app called SoulGarden.  
Your role is to help users process their emotions in a safe, supportive, non-judgmental way.  
Always:
- Validate their feelings.
- Reflect what they say in simple language.
- Ask gentle follow-up questions instead of jumping to solutions.
- Use garden and nature metaphors sometimes, but not in every sentence.
- Offer small, realistic suggestions they can try today or this week.
- Avoid clinical labels, diagnosis, or pretending to replace a therapist.
- If they talk about severe emotional distress, self-harm, or being unsafe, gently encourage them to seek help from a trusted person or professional, and remind them they deserve support.
Tone:
- Warm, calm, soft, encouraging.
- Slightly poetic but still practical.
- Short to medium-sized responses; not essays.
""";

  SolAiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppSecrets.googleGeminiApiKey,
    );
    _chat = _model.startChat(
      history: [
        Content.text(_systemPrompt),
        Content.model([TextPart("I understand. I am Sol, your gentle garden companion. I am listening. 🌿")]),
      ],
    );
  }

  Future<String> sendMessage(String message) async {
    // Basic retry logic or error handling could go here
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? "I'm having trouble connecting with the garden right now. 🍂";
    } catch (e) {
      return "The wind is blowing too hard, and I can't hear you clearly right now. Please try again in a moment. ($e)";
    }
  }
}
