class Scheme {
  final String id;
  final String name;
  final String description;
  final String eligibility;
  final String benefits;
  final String? link;
  final String? category;

  Scheme({
    required this.id,
    required this.name,
    required this.description,
    required this.eligibility,
    required this.benefits,
    this.link,
    this.category,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      eligibility: json['eligibility'],
      benefits: json['benefits'],
      link: json['link'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'eligibility': eligibility,
      'benefits': benefits,
      'link': link,
      'category': category,
    };
  }
}

class AIResponse {
  final String requestId;
  final String detectedDialect;
  final String normalizedText;
  final String aiMessage;
  final List<Scheme> suggestedSchemes;
  final String? audioUrl;

  AIResponse({
    required this.requestId,
    required this.detectedDialect,
    required this.normalizedText,
    required this.aiMessage,
    required this.suggestedSchemes,
    this.audioUrl,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    var list = json['suggested_schemes'] as List;
    List<Scheme> schemesList = list.map((i) => Scheme.fromJson(i)).toList();

    return AIResponse(
      requestId: json['request_id'],
      detectedDialect: json['detected_dialect'],
      normalizedText: json['normalized_text'],
      aiMessage: json['ai_message'],
      suggestedSchemes: schemesList,
      audioUrl: json['audio_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'detected_dialect': detectedDialect,
      'normalized_text': normalizedText,
      'ai_message': aiMessage,
      'suggested_schemes': suggestedSchemes.map((e) => e.toJson()).toList(),
      'audio_url': audioUrl,
    };
  }
}
