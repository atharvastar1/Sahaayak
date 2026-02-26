import 'dart:math';
import '../models/models.dart';

/// Ported logic from the Python Neural Engine to pure Dart/Flutter.
/// This allows the app to run completely offline without any other language dependencies.
class LocalEngine {
  final List<Scheme> _schemesDb = [
    Scheme(
      id: "pm_kisan",
      name: "PM-Kisan Samman Nidhi",
      description: "Direct income support for small and marginal landholding farmers across India.",
      eligibility: "Farmers with cultivable land ownership.",
      benefits: "₹6,000 yearly in three installments of ₹2,000 each.",
      link: "https://pmkisan.gov.in/",
    ),
    Scheme(
      id: "pmay",
      name: "Pradhan Mantri Awas Yojana",
      description: "Universal housing scheme to provide affordable 'Pucca' houses for all citizens.",
      eligibility: "Lower and Middle Income groups without a permanent house.",
      benefits: "Subsidy of up to ₹2.67 lakh on home loan interest.",
      link: "https://pmay-urban.gov.in/",
    ),
    Scheme(
      id: "ayushman_bharat",
      name: "Ayushman Bharat (PM-JAY)",
      description: "National Health Protection Mission covering over 10 crore poor and vulnerable families.",
      eligibility: "Vulnerable families listed in the SECC 2011 database.",
      benefits: "Cashless health cover up to ₹5 lakh per family per year.",
      link: "https://nha.gov.in/",
    ),
    Scheme(
      id: "standup_india",
      name: "Stand Up India",
      description: "Promoting entrepreneurship among SC/ST and Women through bank loans.",
      eligibility: "SC/ST or Woman borrower (18+ years) for greenfield projects.",
      benefits: "Composite loans between ₹10 lakh and ₹100 lakh.",
      link: "https://www.standupmitra.in/",
    ),
    Scheme(
      id: "pm_svanidhi",
      name: "PM SVANidhi",
      description: "Special Micro-Credit Facility for Street Vendors to restart their businesses.",
      eligibility: "Street vendors in urban and peri-urban areas.",
      benefits: "Working capital loan up to ₹10,000 with interest subsidy.",
      link: "https://pmsvanidhi.mohua.gov.in/",
    )
  ];

  String _detectDialect(String text) {
    final textLower = text.toLowerCase();
    final keywords = {
      "Indo-Aryan (North)": ["खेती", "किसान", "पैसा", "मदत", "घर", "मकान", "लोन"],
      "Dravidian (South)": ["ಸಹಾಯ", "ರೈತ", "ಸಹಾಯ", "உதவி", "விவசாயி"],
      "Indo-Aryan (East)": ["সাহায্য", "চাষী", "টাকা"],
      "Indo-Aryan (West)": ["मदत", "शेतकरी", "पैसे"],
    };

    for (var entry in keywords.entries) {
      if (entry.value.any((k) => textLower.contains(k))) {
        return entry.key;
      }
    }
    return "Standard Regional Cluster";
  }

  String _generateEmpatheticResponse() {
    final templates = [
      "I hear your request and I'm ready to help. Here are the government schemes that match your current needs.",
      "Searching the National Informatics Database... I've synchronized the most beneficial programs for you.",
      "Greetings. Based on your unique situation, the government provides these support systems to empower you.",
      "Analyzing your query... I have identified specialized schemes that can provide the financial assistance you seek."
    ];
    return templates[Random().nextInt(templates.length)];
  }

  Future<AIResponse> processVoice(String text) async {
    await Future.delayed(const Duration(milliseconds: 1500)); 

    final dialect = _detectDialect(text);
    final aiMsg = _generateEmpatheticResponse();
    final textLower = text.toLowerCase();
    
    List<Scheme> matches = [];
    if (["farmer", "kisan", "crop", "खेती", "cultivation", "seeds"].any((k) => textLower.contains(k))) {
      matches.add(_schemesDb[0]);
    }
    if (["house", "building", "home", "ghar", "घर", "pucca"].any((k) => textLower.contains(k))) {
      matches.add(_schemesDb[1]);
    }
    if (["health", "medical", "hospital", "ill", "surgery", "medicine"].any((k) => textLower.contains(k))) {
      matches.add(_schemesDb[2]);
    }
    if (["business", "bank", "loan", "startup", "entrepreneur", "sc", "st", "women"].any((k) => textLower.contains(k))) {
      matches.add(_schemesDb[3]);
    }
    if (["vendor", "street", "cart", "shop", "thela"].any((k) => textLower.contains(k))) {
      matches.add(_schemesDb[4]);
    }

    if (matches.isEmpty) {
      matches = [_schemesDb[Random().nextInt(_schemesDb.length)]];
    }

    return AIResponse(
      requestId: "REQ-${DateTime.now().millisecondsSinceEpoch}",
      detectedDialect: dialect,
      normalizedText: text.trim(),
      aiMessage: aiMsg,
      suggestedSchemes: matches,
    );
  }
}
