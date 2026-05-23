# Sahaayak AI — UI/UX Feature & Aesthetics Report

This report documents the design aesthetics, UI/UX mechanics, interactive features, and "look and feel" of the Sahaayak mobile application and web dashboard. 

---

## 🎨 Visual Design Tokens & Themes

Sahaayak follows a modern, corporate-grade design system utilizing premium glassmorphism card layouts, subtle shadows, and vibrant neon status cues.

| Token / Asset | Specification | Visual Representation & UX Purpose |
| :--- | :--- | :--- |
| **Typography** | **Google Fonts 'Outfit'** | Sans-serif with weights from 300 to 900. Large, rounded letters provide high readability for rural/semi-literate users. |
| **Primary Theme** | **Soft Premium Light Mode** | Base canvas: `#F7F9FC` (Soft blue-grey). Surface cards: `#FFFFFF` (Pure white). Provides a clean, government-portal-grade atmosphere. |
| **Main Text** | **Deep Elite Navy** | Color: `#0B193A`. Softens the contrast compared to pure black, reducing cognitive fatigue. |
| **Accent Colors** | **Vibrant Tech Neons** | **Cyan** (`#00B4D8`), **Purple** (`#7B61FF`), **Green** (`#10B981`), **Red** (`#FF4757`). Cues active status indicators and functional divisions. |
| **Glow & Shadows** | **Layered Box Shadows** | Soft shadows (`rgba(11, 25, 58, 0.04)`) blended with neon glowing backdrops for highlighting interactive actions. |

---

## 📱 Mobile App UI/UX Overview (Flutter Client)

The mobile client is built in Flutter, optimized for touch, voice-first triggers, and physical tactile feedback.

### 1. Core Visual Elements
- **The Silicon Orb (Liquid Mic)**: Located on the home screen, this floating, glowing circular mic button pulses dynamically to represent active, recording, and idle states.
- **Haptic Feedback**: Integrates custom device vibration sequences (`haptic_service.dart`) to confirm button taps, voice recognition starts, and response arrivals, which is critical for blind or low-literacy users.
- **Dialect Chip Selectors**: Rounded toggle pills allowing users to select regional dialects (e.g. Bhojpuri, Bundeli) to hint the translation model.

### 2. Primary Screens & Layouts
- **`home_screen.dart`**: Houses the central Liquid Mic orb, greeting widget, and quick-access categories.
- **`dashboard_screen.dart`**: Standardized scheme card layouts presenting matched schemes sorted by reciprocal rank. Each card displays:
  - **Scheme Category Badge** (e.g., *Agriculture, Rural & Environment*)
  - **Key Benefits Summary** (Clean bulleted format)
  - **Eligibility Checklist**
- **`guided_coach_screen.dart`**: An interactive, multi-turn assistant chat frame showing progress markers (Step 1 of 3) to guide users through scheme applications.
- **`whatsapp_chat_screen.dart`**: Mockup of an omni-channel WhatsApp thread interface for seamless integration.

---

## 💻 Web Dashboard PWA Overview (`sahaayak_web/`)

The single-page web app is a responsive dashboard tailored for regional coordinators, CSC operators, and citizen self-service.

```
┌─────────────────────────────────────────────────────────────────┐
│  Brand (Sahaayak)       Search Bar  [Status: Online]  Avatar    │
├───────────────────────┬─────────────────────────────────────────┤
│ 👤 Liquid Mic         │                                         │
│ 📊 Command Center     │           Active View Panel             │
│ 🔒 Smart Vault        │                                         │
│ 🌐 Support Grid       │        (Liquid Mic Voice Assistant /     │
│ ⚡ GenAI Architecture │         RAG Search / Document Vault)     │
├───────────────────────┤                                         │
│ 🔮 Groq Status Badge  │                                         │
└───────────────────────┴─────────────────────────────────────────┘
```

### 1. Navigation Sidebar
- **Engine Status Badge**: Located in the footer. Displays the current active backend LLM engine (e.g. `GROQ ENGINE` in purple with a pulsing status dot).
- **Engine Toggle**: Allows coordinators to dynamically toggle high-performance/standard processing modes.

### 2. Active Tab Views

#### 🎙️ Tab 1: Liquid Mic Voice Assistant
- A large center heading: **"Bharat Ki Awaaz — Voice AI for Bharat"**.
- A glowing central voice orb with hover-active scales. Clicking it opens a dynamic microphone listening dialog.
- **Web Speech API integration**: Converts voice input to text in real-time using Indian language accents.

#### 📊 Tab 2: Citizen Command Center
- **Key Metrics Grid**: Metric widgets showing statistics like "Schemes Loaded", "Session Memory Size", and "Query Latency".
- **Scheme Search**: Input search bar with auto-suggest capability.
- **Match Grid**: Displays matched scheme cards containing interactive sliders, details accordions, and thumbs-up/down feedback buttons (RLHF).

#### 🔒 Tab 3: Secured Smart Vault
- A mock storage environment representing digitized citizen documents (Aadhar, PAN, Land Records).
- Displays visual document locks and "Verified" green badges showing integrations with DigiLocker.

#### 🌐 Tab 4: National Support Grid
- Grid cards featuring emergency contacts, local CSC (Common Service Centre) location maps, and grievance cell numbers.

#### ⚡ Tab 5: GenAI Architecture Stack
- An interactive vector pipeline diagram explaining how data moves through:
  `Voice Input` ➔ `Bhashini Translator` ➔ `Groq LLM Engine` ➔ `FAISS DB` ➔ `gTTS Output`.

---

## 🌟 Look & Feel Summary

Sahaayak achieves a **premium, trustworthy, and modern** aesthetic. 
- The use of **glassmorphism** (white frosted panels over clean light backgrounds) matches elite corporate design standards.
- Micro-animations (floating logo, pulsing indicators, glowing hover cards) make the interface feel alive and highly responsive.
- Decoupling all content into clean card panels keeps the information accessible and digestible, satisfying the diverse literacy levels of rural Indian citizens.
