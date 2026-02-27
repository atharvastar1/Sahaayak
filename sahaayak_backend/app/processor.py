import pandas as pd
import random
from typing import List, Dict

class SahaayakProcessor:
    def __init__(self, csv_path: str):
        self.df = pd.read_csv(csv_path)
        self.dialects = {
            "bhojpuri": ["हमके", "चाहिए", "खेती", "लइका", "बउआ", "रउआ", "कइसे", "काहे", "हमार"],
            "marathi": ["मला", "पाहिजे", "शेतकरी", "मदत", "भावा", "कसा", "कुठे", "माझं", "पोरगा"],
            "punjabi": ["ਮੈਨੂੰ", "ਚਾਹੀਦਾ", "ਕਿਸਾਨ", "ਮਦਦ", "ਕਿਵੇਂ", "ਕਿੱਥੇ", "ਮੇਰਾ"],
            "hindi": ["मुझे", "चाहिए", "किसान", "मदद", "कैसे", "कहाँ", "मेरा"]
        }

    def normalize_dialect(self, text: str) -> Dict[str, str]:
        """
        Critical Innovation: Dialect Normalization.
        Identifies dialect and performs semantic mapping.
        """
        text_lower = text.lower()
        detected_dialect = "standard"
        
        for dialect, keywords in self.dialects.items():
            if any(k in text_lower for k in keywords):
                detected_dialect = dialect
                break
        
        # Simplified mapping: In a real app, this would use a small LLM or translation model
        normalized_text = f"[Mapped from {detected_dialect}]: {text}"
        
        return {
            "dialect": detected_dialect,
            "normalized_text": normalized_text
        }

    def match_schemes(self, context: str) -> List[Dict]:
        """
        Intelligence & Matching: Matches context against the schemes database.
        In a real app, this would use a vector search in PostgreSQL or an LLM call.
        """
        context_lower = context.lower()
        matches = []
        
        # Simple keyword matching for demonstration
        keywords_to_category = {
            "farmer": "Farmer",
            "kisan": "Farmer",
            "crop": "Farmer",
            "खेती": "Farmer",
            "house": "Housing",
            "home": "Housing",
            "ghar": "Housing",
            "health": "Health",
            "hospital": "Health",
            "medical": "Health",
            "business": "Business",
            "loan": "Business",
            "shop": "Street Vendor",
            "vendor": "Street Vendor",
            "student": "Student",
            "school": "Student",
            "pension": "General",
            "insurance": "General"
        }
        
        matched_categories = set()
        for k, cat in keywords_to_category.items():
            if k in context_lower:
                matched_categories.add(cat)
        
        if matched_categories:
            matches = self.df[self.df['category'].isin(matched_categories)].to_dict('records')
        else:
            # Fallback to general schemes or random ones
            matches = self.df.sample(min(3, len(self.df))).to_dict('records')
            
        return matches

    def generate_ai_response(self, schemes: List[Dict], dialect: str) -> str:
        """
        Generates an empathetic response.
        """
        if not schemes:
            return "I couldn't find any specific schemes for you right now, but I'm looking."
        
        response_templates = [
            f"I understand your needs. Based on your {dialect} request, I found these schemes for you.",
            f"Greetings. I've analyzed your situation and identified these helpful government programs.",
            f"Here are the schemes that match your profile. I hope these provide the support you are looking for."
        ]
        return random.choice(response_templates)
