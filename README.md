<p align="center">
  <img src="assets/logo.png" width="150" alt="Sahaayak Logo">
</p>

<h1 align="center" style="font-weight: 900; letter-spacing: -1px;">
  SAHAAYAK — The Enterprise Citizen AI
</h1>

<p align="center">
  <i>A professional, AI-powered citizen assistant bridging the digital divide for rural populations in India.</i>
  <br/>
  <b>Tactile Elite Mobile App</b> • <b>Ultra-Premium Web Platform</b> • <b>Offline Intelligence</b> • <b>Dialect Recognition</b>
</p>

---

## Interface Showcase 

We designed the **"Tactile Elite"** interface for radical accessibility. Deep shadows, vibrant glassmorphism, and large touch targets ensure users of all technological literacy levels feel confident and empowered.

For enterprise scale, we also deployed a companion **"Ultra-Premium Web Architecture"** mirroring the flutter experience 1:1, featuring pure-white glassmorphic dashboards, deep indigo typography, and massive interaction states designed natively with HTML/CSS.

<p align="center">
  <img src="assets/screenshots/screenshot_emulator.png" width="280">&nbsp;:&nbsp;
  <img src="assets/screenshots/dashboard_screenshot.png" width="280">&nbsp;&nbsp;
  <img src="assets/screenshots/microscreen_screenshot.png" width="280">
</p>
<p align="center">
  <i>(Left to Right): Accessible Language Selection, Live Citizen Dashboard, AI Voice Recognition</i>
</p>

---

## The Sahaayak Vision

Sahaayak isn't just an app; it's a dedicated public service companion. It empowers citizens to claim the benefits they deserve by replacing bureaucratic red-tape with conversational AI. 

By leveraging **offline-capable machine learning**, empathetic voice design, and premium aesthetics, Sahaayak turns the daunting task of scheme application into a guided, supportive journey.

---

## Core Capabilities

### Voice-First Architecture
Sahaayak is built from the ground up for voice. The primary interaction is driven through a vibrant **"Liquid Mic"** that pulsates, shimmers, and responds to natural language and regional dialects. It's an intelligent companion that listens.

### Web Intelligence & Feature Parity
The new **MNC-Grade Native Web Application** serves as the central command hub. Engineered natively via HTML/CSS/JS, it possesses 100% interactive parity with the mobile frontend including: Smart Vault Verification, The Local Engine offline simulator, Voice processing, and Live Market Data.

### Local "Zero-Cloud" Intelligence 
Rural networks are unreliable. Our robust `LocalEngine` guarantees offline scheme matching, intent recognition, and dialect parsing. Privacy and functionality are preserved, even at 0 bars of cell reception.

### Seamless Cloud Synchronisation
When networks are strong, Sahaayak scales. The `AICoordinator` seamlessly toggles between the local model and our scalable **Python/FastAPI** backend for LLM-powered reasoning and Whisper STT precision.

### The Smart Vault
A secure, locally encrypted digital repository. When a citizen uploads an Aadhaar or Ration Card, our simulated AI OCR extraction runs a "Tactile Verify" sweep to validate hardware-secured records. 

### Citizen Dashboard & News Marquee
A dynamic hub displaying real-time market rates for vital commodities (Wheat, Rice, Diesel), an active live marquee of government news updates, and real-time Citizen Pulse engagement analytics.

---

## Technical Stack

<table align="center" width="100%">
  <tr>
    <td align="center" width="25%"><b>Mobile Frontend</b></td>
    <td width="75%"><code>Flutter</code> (Cross-platform compilation ready)</td>
  </tr>
  <tr>
    <td align="center"><b>Web Platform</b></td>
    <td>Native <code>HTML5</code> / <code>Vanilla CSS3</code> / <code>Vanilla JS</code> configured on port 8000</td>
  </tr>
  <tr>
    <td align="center"><b>Backend Service</b></td>
    <td><code>Python 3.10</code> powered by <code>FastAPI</code></td>
  </tr>
  <tr>
    <td align="center"><b>UI/UX Design</b></td>
    <td>Custom **Tactile Elite System** (Silicon shadows, Elite Color Gradients, Glassmorphism cards)</td>
  </tr>
</table>

---

## Running the Architecture

### Prerequisites
*   **Flutter SDK** (`3.x` or higher) targetting Android/iOS.
*   **Android Studio / Xcode** for emulators or physical testing devices.
*   **Python 3.x** for natively hosting the Web Architecture.

### Running the Ultra-Premium Web App

1. Configure Python to host the exact native build directory:
    ```bash
    cd Sahaayak/flutter_sahaayak/sahaayak_web
    python3 -m http.server 8000
    ```
2. Navigate immediately to `http://localhost:8000` inside your browser.

### Running the Tactical Flutter Mobile Client

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/atharvastar1/Sahaayak.git
    cd Sahaayak/flutter_sahaayak
    ```

2.  **Fetch Flutter Packages**
    ```bash
    flutter clean && flutter pub get
    ```

3.  **Run the Experience**
    ```bash
    flutter run
    ```

---

<p align="center">
  <b>Sahaayak is Built for Bharat. Focused on Inclusion.</b><br>
  <i>Crafted with care and code.</i>
</p>
