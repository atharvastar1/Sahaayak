# Sahaayak AI — UI/UX Feature & Aesthetics Expanded Report

This document presents a comprehensive, 100% exhaustive audit of the visual design system, interaction patterns, micro-animations, screen layouts, and backend handshakes for both the Sahaayak mobile application and web PWA dashboard.

---

## 🏛️ 1. Core Visual Design Tokens

Sahaayak implements a unified styling system based on elite corporate design guidelines (Apple & Google Standard). It prioritizes accessibility, soft layouts, high contrast, and dynamic neon signals.

### 🎨 Color Palette & Variables
```css
/* Web CSS variables & Flutter equivalents */
--bg-base:      #F7F9FC;     /* Light blue-grey canvas (Flutter: SahaayakTheme.background - Color(0xFFF2F2F7)) */
--bg-surface:   #FFFFFF;     /* Pure white cards (Flutter: SahaayakTheme.surface) */
--text-main:    #0B193A;     /* Elite Navy instead of black (Flutter: SahaayakTheme.primaryDark - Color(0xFF1D1D1F)) */
--text-muted:   #64748B;     /* Slate grey (Flutter: SahaayakTheme.textSecondary - Color(0xFF86868B)) */

/* Accent & Status Indicators */
--cyan:         #00B4D8;     /* Primary Active Accent (Flutter: Color(0xFF007AFF) Apple Blue) */
--purple:       #7B61FF;     /* AI Engine Indicator (Flutter: SahaayakTheme.accentAI - Color(0xFF6366F1)) */
--green:        #10B981;     /* Verified Status (Flutter: SahaayakTheme.success - Color(0xFF34C759)) */
--red:          #FF4757;     /* High Alert / SOS (Flutter: Color(0xFFFF2D55)) */
--warning:      #F5A623;     /* Offline Warning (Flutter: SahaayakTheme.warning - Color(0xFFFF9500)) */
```

### 💫 Premium Gradients & Glows
- **Apple Gradient**: `LinearGradient(colors: [Color(0xFF007AFF), Color(0xFF00C7BE)])` (For primary buttons and progress bars).
- **AI Aura Gradient**: `LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)])` (Used for AI state transitions).
- **Glassmorphic Borders**: Thin white borders (`border: 1px solid rgba(255, 255, 255, 0.5)` with `BackdropFilter` blur of `10px`).
- **Glow Shadow**: `box-shadow: 0 12px 30px rgba(0, 180, 216, 0.2)` (Cyan glow for active buttons).

### ✍️ Typography Hierarchy
- **Primary Typeface**: **Google Fonts 'Outfit'** (Clean, rounded sans-serif designed for readability).
- **Display Large**: `fontSize: 48, fontWeight: w800, letterSpacing: -2`
- **Display Medium (Headers)**: `fontSize: 34, fontWeight: w700, letterSpacing: -1`
- **Headline Medium**: `fontSize: 26, fontWeight: w600`
- **Body Text**: `fontSize: 18, fontWeight: w500, height: 1.5`
- **Labels (Caps)**: `fontSize: 14, fontWeight: w700, letterSpacing: 1.2`

---

## 📱 2. Flutter Mobile Client UI/UX Audit

The mobile client is built in Flutter, optimized for voice-first interactions, touch gestures, and rich haptic feedback.

```
┌────────────────────────────────────────┐
│ [OFFLINE]      (Animated Logo)     [💬] │
├────────────────────────────────────────┤
│                                        │
│          Namaste, Ramesh Ji            │
│         How can I help you?            │
│                                        │
│                                        │
│                 ( (🎙️) )               │
│               TAP TO SPEAK             │
│                                        │
│                                        │
│  QUICK EXPLORE                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │  🚜     │  │  🎓     │  │  🏥     │ │
│  │ Farmer  │  │ Student │  │ Health  │ │
│  └─────────┘  └─────────┘  └─────────┘ │
└────────────────────────────────────────┘
```

### A. Core Screens & Feature Architecture

#### 1. Splash Screen (`splash_screen.dart`)
- **Visuals**: Features a centered floating brand logo with an interactive loading line bar (`line-loader`).
- **Animations**: Uses background floating radial orbs (`glow-orb` and `glow-orb-2`) moving in alternating directions to give a depth layer.

#### 2. Home Screen (`home_screen.dart`)
- **Namaste Header**: Displays personalized greetings based on regional selections.
- **Search Dialog**: Triggered by tapping the central mic. Displays a dark indigo overlay (`Color(0xFF1a1a2e)`) with rounded borders, a search text field, and language-specific hint prompts (e.g. `"मुझे किसान योजना के बारे में बताओ"` for Hindi).
- **Quick Explore Widgets**: Bento cards representing major user personas: Farmer (🚜), Student (🎓), and Health (🏥).
- **Recent Insights**: Horizontal scroll cards containing previous queries, matched scheme counts, and direct review shortcuts.

#### 3. Citizen Dashboard Screen (`dashboard_screen.dart`)
- **Grain Ticker**: Scrolling horizontal list showing live commodity market rates (Wheat ₹2,450, Rice ₹3,100, Diesel ₹89.62) with custom icons.
- **News Marquee**: Sliding alert bar showing live scheme alerts (e.g. next PM-Kisan installment date).
- **Life Milestones**: Horizontal card deck including "I'm getting Married" (Wedding Grants), "I had a Child" (Kanya Sumangala), "I need a Home" (Housing Subsidy).
- **Citizen Pulse**: Real-time stats card displaying: Matches (14), Profile Completeness (85%), and Pending Verification (2) with a green pulsing network indicator.
- **Smart Match Banner**: Call-to-action blue card pointing directly to the guided coach.

#### 4. Smart Vault Screen (`vault_screen.dart`)
- **Document List**: Cards for Aadhaar (UIDAI Verified), Ration Card (Family Verified), and Voter ID (Pending).
- **Scanner Overlay**: Simulated QR camera scanner utilizing a high-tech custom grid paint (`GridPainter`) and a horizontal neon laser bar sliding up and down via a repeating `moveY` animation.
- **Local Security Banner**: Bottom card showing local hardware encryption key compliance.

#### 5. Helpline Screen (`helpline_screen.dart`)
- **Emergency Grid**: Interactive Police (100) and Ambulance (108) cards.
- **Support Contacts**: UP East, Women, and Farmer support items featuring custom call buttons (`Icons.call_rounded`) styled in emerald green.
- **Voice SOS**: Shimmering AI SOS notification card advising voice triggers (*"Shout HELP HELP to alert"*).

#### 6. Guided Coach Screen (`guided_coach_screen.dart`)
- **MNC Stepper**: A horizontal progress bar divided into 4 segments that fills dynamically.
- **Stepping Cards**:
  - *Identity Step*: Mock numeric PIN entry boxes.
  - *Scanner Step*: Mini documents scan window with sliding laser line.
  - *Family Step*: 4 profile avatars in a row with green validation checkmarks.
  - *Submit Step*: Encrypted upload validation card.
- **Audio Prompts**: Automatically triggers text-to-speech instructions (`VoiceService.speak`) upon step transitions.

### B. Micro-Animations & Haptics
- **Tactile Responses (`haptic_service.dart`)**:
  - `HapticService.light()`: Triggers on back navigation, tab selections, and secondary switches.
  - `HapticService.medium()`: Triggers on positive actions like next step, option card taps.
  - `HapticService.heavy()`: Triggers on microphone initialization and document scanner launch.
  - `HapticService.success()`: Triggers on transaction/upload completion.
- **Pulsing Orbs**: Silicon orb utilizes a scale loop (`begin: 1.0, end: 1.08`) over `2.seconds` to simulate human breathing/waiting cycles.

---

## 💻 3. Web PWA Dashboard UI/UX Audit

The web PWA is a responsive, single-page application built on top of a dark/light glassmorphic UI, serving regional coordinators and citizens.

```
┌────────────────────────────────────────────────────────┐
│  Brand (Sahaayak)    Search Box (⌘K)     [Online]  [Avatar]│
├────────────────────┬───────────────────────────────────┤
│ 🎙️ Liquid Mic      │                                   │
│ 📊 Command Center  │     [ Selected Language Grid ]    │
│ 🔒 Smart Vault     │                                   │
│ 🌐 Support Grid    │         (Multi-lingual            │
│ ⚡ Architecture     │          Pills Selection)         │
├────────────────────┤                                   │
│ 🔮 Groq Active     │                                   │
└────────────────────┴───────────────────────────────────┘
```

### A. Initialization & Language Grid
On first launch, the user is presented with a full-screen blurred overlay featuring a language selection grid supporting all **23 languages** with native script labels:
- **Punjabi** (ਪੰ), **Telugu** (తె), **Tamil** (த), **Kannada** (ಕ), **Malayalam** (മ), **Bengali** (বা), **Gujarati** (ગ), **Odia** (ଓ), **Assamese** (অ), **Urdu** (اردו), **Nepali** (ने), **Sindhi** (سن), **Kashmiri** (کش), **Maithili** (मै), **Konkani** (को), **Dogri** (डो), **Sanskrit** (सं), **Manipuri** (ꯃꯅꯤ), **Santali** (ᱥᱟ), **Bodo** (ब').
- The submit button "Initialize System" stays disabled until a language card is selected.

### B. Navigation Sidebar
- **Menu Items**: Core navigation tabs with hover-glow transformations: Liquid Mic, Dashboard, Smart Vault, Helpline, Architecture, and Help Center.
- **Active Engine Badge**: Dynamic card displaying the active LLM provider (e.g. `GROQ ENGINE` in purple with a glowing status dot).
- **On-Device Toggle**: A premium toggle switch allowing coordinators to simulate network-disconnected local mode.

### C. Active Tab Views

#### 🎙️ Liquid Mic
- Center banner: **"Bharat Ki Awaaz — Voice AI for Bharat"**.
- Features a glowing central microphone button surrounded by two radial ripples.
- **Dialect Normalization Hint**: Dynamic pills enabling regional dialect selection (Bhojpuri, Ahirani, Bundeli, Magahi).
- **Speech Recognition (STT)**: Invokes the browser's Web Speech API customized to Indian accents (`en-IN`, `hi-IN`).
- **Analysis Card**: Shows JSON intent confidence, parsed query text, and matched scheme summary.

#### 📊 Citizen Command Center
- **Bento Grid**: Main hero pending count card, grain price widgets, profile progress bar (85%), and life event boxes.
- **RAG Matches**: Detailed search result widgets presenting rank, eligibility cards, dynamic benefits accordions, and thumbs-up/down RLHF feedback logs.

#### 🔒 Secured Smart Vault
- Frost-glass layout showing Aadhaar and Ration Card documents alongside verified security badges.
- Features a simulated biometric validation overlay.

#### 🌐 National Support Grid
- Emergency police/ambulance boxes alongside regional helpline cards (UP East, Women, Farmer) with green call button buttons.

#### ⚡ Architecture Pipeline Diagram
- Displays a visual pipeline using responsive HTML/CSS boxes tracing:
  `Mic Input` ➔ `Bhashini Translator` ➔ `Groq Llama Inference` ➔ `Local FAISS DB` ➔ `gTTS Synthesizer`.

---

## ⚡ 4. Backend-Frontend Handshake Integrations

The user interfaces communicate with the FastAPI backend through a structured JSON protocol:

### 🔑 Authentication & Headers
- All requests require the `X-API-Key` header verified against `SAHAAYAK_API_KEY` (in production) or run in passwordless Dev mode.

### 🌐 API Endpoint Responses & Mapping

#### 1. `/health` Status
- **Response Map**:
  ```json
  {
    "status": "ok",
    "environment": "development",
    "schemes_loaded": 3397,
    "models_ready": true,
    "cache_size": 0,
    "llm_engine": "groq"
  }
  ```
- **UI Action**: Green pulse dot is initialized; "Secure Connection" status is rendered in top bar.

#### 2. `/engine` Details
- **Response Map**:
  ```json
  {
    "engine": "groq",
    "primary": "Groq Cloud Inference",
    "model": "llama-3.3-70b-versatile",
    "provider": "Groq",
    "status": "active"
  }
  ```
- **UI Action**: Renders the dynamic active engine badge (`llama-3.3-70b-versatile` inside the PWA sidebar).

#### 3. `/chat` (RAG Query Execution)
- **Request payload**:
  ```json
  {
    "message": "किसानों के लिए कोई योजना है?",
    "session_id": "session_8819",
    "language_hint": "hi",
    "life_event": "farmer"
  }
  ```
- **Response payload**:
  - `language_detected`: `"hi"` (Triggers layout translation).
  - `text`: Fully synthesized response in regional script.
  - `audio_base64`: Base64 MP3 voice string (played immediately by browser audio layer).
  - `schemes`: Array of matched schemes, benefits, eligibility, and ranks mapped to cards.
