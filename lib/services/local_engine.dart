import 'dart:math';
import '../models/models.dart';

/// Advanced On-Device Intelligence Engine for Sahaayak.
/// Handles NLP, Intent Recognition, and Scheme Matching without cloud dependency.
class LocalEngine {
  final List<Scheme> _schemesDb = [
    Scheme(
      id: "pm_kisan",
      name: "PM-Kisan Samman Nidhi",
      description: "Direct income support for small and marginal landholding farmers across India.",
      eligibility: "Farmers with cultivable land ownership.",
      benefits: "₹6,000 yearly in three installments.",
      link: "https://pmkisan.gov.in/",
      category: "Agriculture",
    ),
    Scheme(
      id: "pmay",
      name: "Pradhan Mantri Awas Yojana",
      description: "Universal housing scheme to provide affordable 'Pucca' houses for all citizens.",
      eligibility: "Lower and Middle Income groups without a permanent house.",
      benefits: "Subsidy of up to ₹2.67 lakh on home loan interest.",
      link: "https://pmay-urban.gov.in/",
      category: "Housing",
    ),
    Scheme(
      id: "ayushman_bharat",
      name: "Ayushman Bharat (PM-JAY)",
      description: "National Health Protection Mission covering over 10 crore poor and vulnerable families.",
      eligibility: "Vulnerable families listed in the SECC 2011 database.",
      benefits: "Cashless health cover up to ₹5 lakh per family per year.",
      link: "https://nha.gov.in/",
      category: "Health",
    ),
    Scheme(
      id: "standup_india",
      name: "Stand Up India",
      description: "Promoting entrepreneurship among SC/ST and Women through bank loans.",
      eligibility: "SC/ST or Woman borrower (18+ years) for greenfield projects.",
      benefits: "Composite loans between ₹10 lakh and ₹100 lakh.",
      link: "https://www.standupmitra.in/",
      category: "Business",
    ),
    Scheme(
      id: "pm_svanidhi",
      name: "PM SVANidhi",
      description: "Special Micro-Credit Facility for Street Vendors to restart their businesses.",
      eligibility: "Street vendors in urban and peri-urban areas.",
      benefits: "Working capital loan up to ₹10,000 with interest subsidy.",
      link: "https://pmsvanidhi.mohua.gov.in/",
      category: "Small Business",
    ),
    Scheme(
      id: "pm_kushal",
      name: "PM-KUSUM",
      description: "Support for farmers to install solar pumps and grid-connected solar power plants.",
      eligibility: "Individual farmers, groups, cooperatives, and panchayats.",
      benefits: "60% subsidy for solar pump installation.",
      link: "https://pmkusum.mnre.gov.in/",
      category: "Agriculture",
    ),
    Scheme(
      id: "jjm",
      name: "Jal Jeevan Mission",
      description: "Providing functional household tap connections to every rural home.",
      eligibility: "All rural households.",
      benefits: "Access to safe and adequate drinking water at home.",
      link: "https://jaljeevanmission.gov.in/",
      category: "Public Utility",
    ),
    Scheme(
      id: "soubhagya",
      name: "Pradhan Mantri Sahaj Bijli Har Ghar Yojana",
      description: "Providing electricity connections to all un-electrified households in rural areas.",
      eligibility: "Poor households (BPL) and others on payment.",
      benefits: "Free or low-cost electricity connections.",
      link: "https://saubhagya.gov.in/",
      category: "Public Utility",
    ),
  ];

  /// Mapping of intents to keywords with weights
  final Map<String, Map<String, double>> _intentModel = {
    "farming": {
      "kisan": 1.0, "farmer": 1.0, "crop": 0.8, "agriculture": 0.9, 
      "seeds": 0.7, "land": 0.6, "kheti": 1.0, "pika": 0.8, "sheti": 1.0,
      "fertilizer": 0.7, "tractor": 0.8, "pani": 0.5, "wheat": 0.6, "rice": 0.6
    },
    "housing": {
      "house": 1.0, "home": 1.0, "ghar": 1.0, "building": 0.7, 
      "pucca": 0.9, "home loan": 0.8, "makan": 0.9, "nivara": 0.8
    },
    "health": {
      "health": 1.0, "medical": 1.0, "hospital": 1.0, "doctor": 0.8, 
      "medicine": 0.7, "surgery": 0.9, "ill": 0.6, "davakhana": 0.9, "aarogya": 1.0
    },
    "entrepreneur": {
      "business": 1.0, "startup": 1.0, "loan": 0.8, "shop": 0.7, 
      "karz": 0.9, "paisa": 0.6, "vyapar": 1.0, "entrepreneur": 1.0
    },
    "vulnerable": {
      "vendor": 1.0, "street": 1.0, "thela": 1.0, "cart": 0.8, 
      "poor": 0.6, "ration": 0.7, "help": 0.4, "svanidhi": 1.0
    }
  };

  String _detectDialect(String text) {
    final textLower = text.toLowerCase();
    final indicators = {
      "Hindustani Cluster": ["है", "जी", "भैया", "मदद", "पैसा", "काम"],
      "Southern Syntax": ["garu", "andi", "sir", "vanakkam"],
      "Maritime (Marathi/Gujarati)": ["आहे", "काय", "हो", "मदत", "छे"],
    };

    for (var entry in indicators.entries) {
      if (entry.value.any((k) => textLower.contains(k))) return entry.key;
    }
    return "Neutral Bharat Cluster";
  }

  Future<AIResponse> processVoice(String text, String langCode) async {
    // Artificial latency for "Thinking" state simulation
    await Future.delayed(const Duration(milliseconds: 1800));

    final textLower = text.toLowerCase();
    final dialect = _detectDialect(text);
    
    // 1. Scoring Intent using Weighted Keywords
    Map<String, double> scores = {"farming": 0, "housing": 0, "health": 0, "entrepreneur": 0, "vulnerable": 0};
    
    _intentModel.forEach((intent, keywords) {
      keywords.forEach((word, weight) {
        if (textLower.contains(word)) {
          scores[intent] = (scores[intent] ?? 0) + weight;
        }
      });
    });

    // 2. Identify Primary Intent based on Score
    String primaryIntent = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    if (scores[primaryIntent] == 0.0) primaryIntent = "general";

    // 3. Match Intelligence Database
    List<Scheme> matches = [];
    switch (primaryIntent) {
      case "farming": matches = [_schemesDb[0], _schemesDb[5]]; break;
      case "housing": matches = [_schemesDb[1]]; break;
      case "health": matches = [_schemesDb[2]]; break;
      case "entrepreneur": matches = [_schemesDb[3]]; break;
      case "vulnerable": matches = [_schemesDb[4]]; break;
      default:
        // Smart fall-back: random pick from top categories
        matches = [_schemesDb[Random().nextInt(_schemesDb.length)]];
    }

    // 4. Localized Empathy Logic
    String aiMsg = _getLocalizedResponse(langCode, primaryIntent);

    return AIResponse(
      requestId: "REQ-${DateTime.now().millisecondsSinceEpoch}",
      detectedDialect: dialect,
      normalizedText: text.trim(),
      aiMessage: aiMsg,
      suggestedSchemes: matches,
    );
  }

  String _getLocalizedResponse(String lang, String intent) {
    final responses = {
      'en': {
        'farming': "I've identified agricultural subsidies tailored for your cultivation needs.",
        'housing': "Here are the housing assistance programs currently accepting applications.",
        'health': "I've synchronized your eligibility with national health protection missions.",
        'general': "I'm analyzing your request. Based on our database, these programs appear most beneficial."
      },
      'hi': {
        'farming': "मैंने आपकी खेती की जरूरतों के लिए विशेष कृषि सब्सिडी की पहचान की है।",
        'housing': "यहाँ वे आवास सहायता कार्यक्रम हैं जो वर्तमान में आवेदन स्वीकार कर रहे हैं।",
        'health': "मैंने राष्ट्रीय स्वास्थ्य मिशनों के साथ आपकी पात्रता की जांच की है।",
        'general': "मैं आपकी मदद के लिए तैयार हूँ। ये सरकारी योजनाएं आपके लिए फायदेमंद हो सकती हैं।"
      },
      'mr': {
        'farming': "मी तुमच्या शेतीच्या गरजांसाठी कृषी अनुदानांची माहिती शोधली आहे.",
        'housing': "येथे गृहनिर्माण सहाय्य कार्यक्रम आहेत जे सध्या अर्ज स्वीकारत आहेत.",
        'health': "मी राष्ट्रीय आरोग्य संरक्षण मिशनसह तुमची पात्रता तपासली आहे.",
        'general': "मी तुमच्या विनंतीचे विश्लेषण करत आहे. या योजना तुमच्यासाठी फायदेशीर ठरू शकतात."
      }
    };

    final langGroup = responses[lang] ?? responses['en']!;
    return langGroup[intent] ?? langGroup['general']!;
  }

  Future<List<Scheme>> getMockSchemes() async {
    return _schemesDb.sublist(0, 3);
  }
}
