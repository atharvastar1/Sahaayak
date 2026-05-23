# Sahaayak UI/UX Generation Prompt

## 🎯 Master Prompt for Creating Production-Grade UI Mockups

Use this prompt with Claude API or design tools to generate beautiful, accessible, and production-ready UI mockups and prototypes.

---

## Prompt 1: Home Screen Mobile App

```
You are a professional mobile UI/UX designer creating a production-grade Flutter app for Sahaayak, 
an AI-powered government scheme discovery platform for rural India.

DESIGN REQUIREMENTS:
- Target Users: Rural, semi-literate, voice-first users across India (age 18-65)
- Platform: Flutter mobile app (responsive for phones 4.5" to 6.5")
- Design System: Modern glassmorphism with soft shadows and neon accents
- Accessibility: WCAG AAA compliant, designed for screen readers

VISUAL SPECIFICATIONS:
Typography:
  - Font: Google Fonts 'Outfit' (weights: 400, 600, 700)
  - Greeting: 32px bold, color #0B193A
  - Body: 16px regular, color #6B7A95
  - Caption: 12px regular, color #A0AEC0

Colors (Light Mode - Default):
  - Canvas Background: #F7F9FC
  - Card Surface: #FFFFFF
  - Primary Text: #0B193A
  - Secondary Text: #6B7A95
  - Accent Primary: #00B4D8 (Cyan)
  - Accent Success: #10B981 (Green)

Layout (360px width mobile):
  1. Header Bar (56px height)
     - Left: Sahaayak logo (32px)
     - Right: Status badge (🟢 Online) + Avatar (40px circle)
     - Background: White, shadow: rgba(11,25,58,0.04)
  
  2. Greeting Section (72px)
     - Top padding: 16px
     - Greeting text: "Namaste, Raj" (dynamic based on time of day)
     - Subtext: "Your personal scheme assistant" (14px, secondary text)
     - Background: Canvas color
  
  3. The Liquid Mic Orb (120px diameter)
     - Centered on screen
     - Background: Radial gradient cyan (#00B4D8) with glow effect
     - Border: Glowing neon shadow, 8px blur radius
     - Inner icon: Microphone (24px white)
     - Visual State: Subtle 2-second pulse animation (0.9 → 1.0 scale)
     - Haptic: None (idle state)
     - Interactive: Tap to open voice input modal
  
  4. Dialect Selector (48px height, full width)
     - Label: "Select Your Language" (14px, bold)
     - Pills (rounded buttons): [Hindi ✓] [Bhojpuri] [Marathi] [More...]
     - Selected: Cyan background, white text
     - Unselected: #F0F4F9 background, #0B193A text
     - Padding: 8px per pill
     - Spacing: 8px between pills, horizontal scroll if needed
  
  5. Quick Action Grid (2 columns, 4 items)
     - Items: 📋 Schemes, 🎯 Guided Help, 🔒 My Docs, 🆘 Support
     - Card Size: 160px × 120px per item
     - Card Background: White with 12px radius
     - Card Shadow: 0 2px 8px rgba(11,25,58,0.08)
     - Card Hover: Shadow increases to 0 8px 24px rgba(11,25,58,0.12), translate Y -4px
     - Icon: 40px, color #00B4D8
     - Label: 14px bold, centered below icon
  
  6. Recent Search Section (56px)
     - Label: "Recent" (12px caption)
     - Pill: "🔍 Farming Subsidy Scheme" (clickable, searches)
     - Background: #F0F4F9, padding 8px 16px, radius 20px
  
  7. Bottom Safe Area: 16px padding

INTERACTIVE BEHAVIORS:
  - Tap Liquid Mic → Modal slides up from bottom (300ms animation, springy ease)
  - Tap dialect → Haptic double-tap, selection updates instantly
  - Tap quick action → Navigation with fade transition (250ms)
  - Pull to refresh → Refresh recent schemes (haptic pulse during load)

ACCESSIBILITY:
  - All text has semantic heading tags (<h1>, <h2>, etc.)
  - Mic button: aria-label="Voice input for scheme search"
  - Dialect pills: role="radio" with aria-checked
  - Focus indicators: 2px blue outline on all interactive elements
  - Screen reader support: "Greeting, Select dialect, Liquid Mic button, Quick Actions"

OUTPUT:
Create a detailed HTML/CSS mockup with React component structure that shows:
1. Visual mockup (wireframe + colors)
2. Responsive layout code (fits 360px width)
3. Animation keyframes (pulse, tap, transitions)
4. Accessibility attributes (ARIA, semantic HTML)
5. Haptic feedback triggers (where applicable)

Style with inline CSS using the exact colors specified. Make it feel premium and modern.
```

---

## Prompt 2: Voice Input Modal

```
Create the voice input modal/overlay for the Sahaayak mobile app that appears when users tap the Liquid Mic.

DESIGN REQUIREMENTS:
- Modal Type: Bottom sheet (slides up from bottom)
- Animation: 300ms cubic-bezier(0.34, 1.56, 0.64, 1) - springy entrance
- Background: Semi-transparent overlay (#000000 with 40% opacity)
- Modal Height: 80% of viewport (leaving ~20% of home screen visible above)
- Border Radius: 24px top corners only

VISUAL SPECIFICATIONS:
Header Section (60px):
  - Drag Handle: 4px × 40px pill, #D0D5E0, centered top
  - Title: "Listening..." (32px bold, cyan #00B4D8)
  - Subtitle: "Apna sawal pucho" (Hindi: Ask your question) - 14px secondary text
  - Close Button: Top-right, 32px circle, icon X in dark navy

Waveform Visualization (180px height):
  - Display: Real-time audio input waveform
  - Animation: 12 bars, each animating independently based on audio frequency
  - Bar Height Range: 20px - 120px
  - Bar Width: 6px
  - Spacing: 8px between bars
  - Color: Gradient from cyan #00B4D8 to purple #7B61FF
  - Animation Speed: Synchronized to audio input (updates every 50ms)
  - Effect: Bars grow/shrink smoothly with ease-in-out timing (100ms)

Transcription Display (Variable height):
  - Background: #F7F9FC with 8px padding
  - Border Radius: 8px
  - Text: Live transcription (updated every 300ms)
  - Font: 16px regular, color #0B193A
  - Example: "Mujhe farming ke liye subsidy deni hai" (I need farming subsidy)
  - Line Height: 1.6 for readability
  - Max Height: 100px with scroll if longer
  - Confidence Indicator: Small grey percentage (e.g., "93% confident") below text

Controls Section (100px):
  - Layout: 2 buttons, centered, vertical stack
  - Button 1: [🔴 Stop Recording] (Primary style, red #FF4757)
    - Size: 56px diameter circle (tap target 48px minimum)
    - Icon: Filled red circle with white square inside
    - Haptic on tap: Continuous buzz (vibration) stops
  
  - Button 2: [🎤 Retry] (Secondary style, gray)
    - Size: 48px diameter circle
    - Icon: Microphone icon, cyan #00B4D8
    - Haptic on tap: Double-tap pattern (50ms + 50ms pause + 50ms)

Status Indicators:
  - Recording Duration: "00:23" (timer, secondary color, top-right of waveform)
  - Listening Status: "🟢 Listening" (animated pulsing green dot with text)

INTERACTIVE BEHAVIORS:
  - Start: When modal opens, immediately start listening (Web Speech API)
  - Real-time Transcription: Display partial results as user speaks
  - Auto-submit: After 2 seconds of silence, automatically submit query
  - Manual Stop: Red button stops recording and submits immediately
  - Retry: Clears transcription, starts listening again
  - Close Modal: X button or swipe-down gesture
  - Backdrop Tap: Close modal (if outside of modal area)

ACCESSIBILITY:
  - aria-label="Voice input modal"
  - aria-live="polite" on transcription area (announces updates to screen readers)
  - aria-atomic="true" on status indicators
  - aria-describedby="waveform-description" (description: "Real-time audio waveform")
  - Focus Management: Focus trap inside modal, return to mic button on close
  - Keyboard: Escape key closes modal

HAPTIC FEEDBACK:
  - Modal entrance: Soft vibration (50ms)
  - Recording active: Continuous pulsing haptic (200ms intervals)
  - Silence detected: Double-tap pattern (haptic confirmation)
  - Stop/Submit: Single strong pulse (100ms)

OUTPUT:
Create a full-screen HTML/React component mockup showing:
1. Modal structure with semi-transparent backdrop
2. Animated waveform visualization (SVG or canvas-based)
3. Live transcription text area
4. Control buttons with proper styling
5. CSS animations for smooth transitions
6. Accessibility attributes (ARIA, focus management)
7. Haptic trigger annotations

Make it feel responsive, modern, and indicate real-time audio processing through animation.
```

---

## Prompt 3: Dashboard Screen (Scheme Results)

```
Create the main dashboard screen showing government scheme search results for Sahaayak mobile app.

DESIGN REQUIREMENTS:
- Screen: Full-height scrollable dashboard
- Content: List of matched government schemes
- Layout: Vertical scrolling card layout (1 card per row)
- Target Width: 360px mobile
- Background: Canvas color #F7F9FC

HEADER SECTION (72px, fixed):
  - Left: Back button (24px, dark navy, tap area 40px square)
  - Center: "Matched Schemes" title (20px bold)
  - Right: Filter button (24px icon, tap area 40px square)
  - Background: White with subtle shadow
  - Border Bottom: 1px #E5E9F0

FILTER INDICATOR:
  - Below header: "14 schemes found | Sort by: Relevance ▼"
  - Font: 12px secondary text
  - Padding: 12px 16px
  - Background: Canvas color

SCHEME CARD (Variable height, ~220px collapsed):
  Layout Structure:
  
  ┌─────────────────────────────────────┐
  │ 🌾 Agriculture & Rural Development  │ ← Category badge
  │ ─────────────────────────────────────│
  │ PM-KISAN Scheme                     │ ← Scheme title (18px bold)
  │ "Direct Income Support for Farmers" │ ← Subtitle (14px secondary)
  │ ─────────────────────────────────────│
  │ Key Benefits:                        │
  │ ✓ ₹6000 per year direct transfer   │
  │ ✓ Free crop insurance option        │
  │ ✓ Digital payment to Aadhaar       │
  │ ─────────────────────────────────────│
  │ [View Eligibility ▼]  [👍] [Apply] │
  └─────────────────────────────────────┘

VISUAL SPECIFICATIONS:

Category Badge (Top-Left):
  - Shape: Rounded pill with icon
  - Background: Purple #7B61FF
  - Text: White, 12px bold
  - Padding: 6px 12px
  - Icon: 16px left-aligned (e.g., 🌾 farming)
  - Position: 16px from top-left of card

Scheme Title:
  - Font: 18px bold, color #0B193A
  - Margin: 12px (top), 16px (sides)
  - Max lines: 2

Scheme Subtitle:
  - Font: 14px italic, color #6B7A95
  - Margin: 4px (top), 16px (sides)
  - Italicized for distinction

Benefits List:
  - Format: Bulleted list with checkmarks
  - Icon: ✓ (green #10B981)
  - Text: 14px regular, color #0B193A
  - Line Height: 1.6
  - Margin: 12px (top), 16px (sides)
  - Max items shown: 3 (with "More..." if truncated)

Card Footer (Action Row):
  - Layout: Horizontal flex, space-between
  - Button 1: [▼ View Eligibility] (text button, left-aligned)
    - Font: 14px bold, cyan #00B4D8
    - Tap area: Full height (48px minimum)
    - Expands to show eligibility checklist when tapped
  - Button 2: [👍] (icon button)
    - Circle, 44px
    - Color: Light grey, toggles to cyan when selected
    - Haptic: Light tap feedback
  - Button 3: [📋 Apply Now] (primary button)
    - Background: Cyan #00B4D8
    - Text: White, 14px bold
    - Padding: 12px 20px
    - Border Radius: 20px
    - Tap area: 48px height
    - Haptic: Double-tap pattern on success

EXPANDED ELIGIBILITY SECTION:
  When "View Eligibility" is tapped, card expands to show:
  
  ┌─────────────────────────────────────┐
  │ Eligibility Checklist               │
  │ ─────────────────────────────────────│
  │ ☐ You must be an Indian citizen   │
  │ ☐ Own agricultural land           │
  │ ☐ Not above income limit (₹2L)    │
  │ ☐ Bank account linked to Aadhaar │
  │                                    │
  │ Progress: 2 of 4 completed ▓▓░░  │
  │                                    │
  │ [Get Help Applying]  [Upload Docs] │
  └─────────────────────────────────────┘

CARD STYLING:
  - Background: White
  - Border Radius: 12px
  - Padding: 16px
  - Margin: 12px 12px (horizontal gutters)
  - Shadow: 0 2px 8px rgba(11,25,58,0.08)
  - Shadow on Hover: 0 8px 24px rgba(11,25,58,0.12)
  - Hover Effect: Translate Y -4px, shadow lift (200ms ease)
  - Border Left: 4px #00B4D8 on active/selected card

PAGINATION & LOAD MORE:
  - At bottom of list: "Load More" button
  - Font: 16px bold, cyan #00B4D8
  - Background: Transparent with 2px cyan border
  - Padding: 12px 24px
  - Centered horizontally
  - Margin: 24px (top/bottom)
  - Loading state: Spinner animation

INTERACTIVE BEHAVIORS:
  - Tap scheme card → Expand eligibility (300ms animation)
  - Tap "Apply Now" → Navigate to guided coach screen (250ms fade)
  - Tap "👍" (Helpful) → Toggle selection, show toast "Thanks for feedback!"
  - Scroll down → Load more schemes (infinite scroll with lazy loading)
  - Pull to refresh → Refresh results
  - Swipe up → Collapse expanded card

ACCESSIBILITY:
  - aria-label="Scheme card: PM-KISAN, 14 schemes matched"
  - aria-expanded="false" (on eligibility section, toggles on expand)
  - aria-live="polite" on load-more section
  - aria-describedby="benefit-list" on benefits section
  - Role="region" on main results area
  - Keyboard: Tab through cards, Enter to expand/collapse, Tab to action buttons

EMPTY STATE (if no results):
  ┌─────────────────────────────────────┐
  │ 🔍 No Schemes Found                 │
  │                                      │
  │ "Koi yojana match nahi hua"          │
  │ (No matching scheme found)           │
  │                                      │
  │ Try:                                 │
  │ • Use simpler search terms           │
  │ • Change your preferences            │
  │ • Browse all schemes                 │
  │                                      │
  │ [📋 View All Schemes]                │
  │ [🎤 Try Voice Search]                │
  └─────────────────────────────────────┘

OUTPUT:
Create a detailed mockup showing:
1. Header with navigation
2. 3-4 sample scheme cards with realistic government data
3. One card in expanded state showing eligibility
4. Load more button at bottom
5. Proper spacing and typography
6. Hover/active states with CSS transitions
7. Accessibility annotations
8. Responsive behavior (scrolling, card stacking)

Make it look professional, trustworthy, and easy to scan for quick decisions.
```

---

## Prompt 4: Web Dashboard (Liquid Mic Voice Assistant Tab)

```
Create the web dashboard interface for Sahaayak showing the "Liquid Mic Voice Assistant" tab.

DESIGN REQUIREMENTS:
- Platform: Progressive Web App (PWA) / Responsive Web Design
- Target Width: 1280px (desktop), responsive down to 768px (tablet)
- Framework: React / HTML5 with modern CSS
- Design System: Premium glassmorphism, soft shadows, neon accents
- Browser Support: Chrome, Firefox, Safari (latest 2 versions)

LAYOUT STRUCTURE:
┌─────────────────────────────────────────────────────────────────┐
│ Sahaayak Logo    Search [_______]   Status: 🟢 Online    Avatar │
├──────────┬──────────────────────────────────────────────────────┤
│ 🎤 Voice │                                                      │
│ 📊 Dash  │  Tab Content Area:                                   │
│ 🔒 Vault │                                                      │
│ 🌐 Grid  │  ┌─────────────────────────────────────────────┐   │
│ ⚡ Arch  │  │ "Bharat Ki Awaaz — Voice AI for Bharat"    │   │
│          │  │ ───────────────────────────────────────────│   │
│          │  │                                             │   │
│          │  │       ┌──────────────────────┐             │   │
│          │  │       │ 🎤 Glowing Orb       │ ← 200px   │   │
│          │  │       │ (Pulse animation)    │             │   │
│          │  │       └──────────────────────┘             │   │
│          │  │                                             │   │
│          │  │  Listening Indicator (Waveform):           │   │
│          │  │  ▁▂▃▄▅▆▇█▇▆▅▄▃▂▁ (animated)              │   │
│          │  │                                             │   │
│          │  │  Transcription:                             │   │
│          │  │  "Mujhe farming subsidy ke baare mein..."  │   │
│          │  │                                             │   │
│          │  │  [🔴 Stop]  [Settings ⚙️]                 │   │
│          │  └─────────────────────────────────────────────┘   │
│          │                                                      │
├──────────┼──────────────────────────────────────────────────────┤
│ GROQ ⚙️  │                                                      │
│ Engine   │                                                      │
│ [Toggle] │                                                      │
└──────────┴──────────────────────────────────────────────────────┘

HEADER NAVIGATION (60px height):
  - Left: Sahaayak Logo (32px, dark navy)
  - Center: Search bar (input field, width 300px)
    - Placeholder: "Search schemes or ask a question..."
    - Font: 14px, color #A0AEC0
    - Focus: 2px cyan border, blue glow
    - Icon: 🔍 right-aligned in input
  
  - Right: Status badge + Avatar
    - Status: "🟢 Online" (green dot + text, 12px) OR "🔴 Offline"
    - Avatar: 40px circle, user initials or image
    - Dropdown menu on avatar tap (Settings, Logout, etc.)

SIDEBAR NAVIGATION (240px width, fixed):
  - Background: White with 1px border-right #E5E9F0
  - Padding: 16px
  - Navigation Items (vertical list):
    1. 🎤 Liquid Mic Voice Assistant (currently active)
       - Active indicator: Left 4px cyan border
       - Background: #F0F4F9 (hover/active)
    2. 📊 Citizen Command Center
    3. 🔒 Secured Smart Vault
    4. 🌐 National Support Grid
    5. ⚡ GenAI Architecture Stack
  
  - Sidebar Footer:
    - Engine Status Badge (60px from bottom)
    - Label: "GROQ ENGINE" (12px bold, purple #7B61FF)
    - Status Dot: Pulsing green (indicates active processing)
    - Toggle Switch: ON/OFF for engine modes

MAIN CONTENT AREA (1040px width on desktop):
  - Background: Canvas color #F7F9FC
  - Padding: 32px
  - Responsive: Full-width on tablet, single-column on mobile

VOICE ASSISTANT TAB CONTENT:

1. Hero Section (Top):
   - Title: "Bharat Ki Awaaz — Voice AI for Bharat" (40px bold, dark navy)
   - Subtitle: "Ask any question about government schemes in your local language"
   - Font: 18px secondary text
   - Text Alignment: Center
   - Margin: 32px bottom

2. Liquid Mic Orb (Central Focus):
   - Size: 200px diameter circle
   - Visual: Glassmorphism effect with gradient
     - Background: Radial gradient (cyan #00B4D8 center, semi-transparent edges)
     - Border: Neon glow (box-shadow: 0 0 40px rgba(0, 180, 216, 0.4))
     - Inner Icon: Microphone (60px white)
   - Animation: Pulse 2s ease-in-out infinite (0.9 → 1.0 scale)
   - Cursor: Pointer
   - Hover: Scale 1.05, glow intensifies

3. Waveform Visualization (Below Orb):
   - SVG-based animated bars
   - Layout: 20 bars, responsive spacing
   - Bar Dimensions: 8px width, 20-120px height range
   - Spacing: 6px between bars
   - Color: Gradient from cyan #00B4D8 (left) to purple #7B61FF (right)
   - Animation: Synced to audio input, updates every 50ms
   - Height animation: 100ms cubic-bezier(0.4, 0.0, 0.2, 1)
   - Hidden when idle, animates when listening

4. Transcription Display:
   - Background: White card, 12px radius
   - Padding: 24px
   - Width: 60% of content area (responsive)
   - Font: 18px regular, #0B193A
   - Line Height: 1.6
   - Border-left: 4px cyan (#00B4D8)
   - Live updates: New text appears with fade-in animation (200ms)
   - Scrollable if text exceeds height
   - Cursor: Text cursor (non-selectable, user feedback only)

5. Status Indicator:
   - Text: "🎤 Listening..." OR "🔄 Processing..." OR "✅ Ready for input"
   - Font: 14px bold, secondary text
   - Animated icon: Pulsing or spinning based on state
   - Position: Below transcription

6. Control Buttons (Below Transcription):
   - Layout: Horizontal flex, center-aligned, gap 16px
   
   - Button 1: [🔴 Stop Listening]
     - Style: Primary (cyan background #00B4D8)
     - Padding: 12px 24px
     - Font: 14px bold, white
     - Border Radius: 20px
     - Tap area: 48px height
     - Hover: Brighten by 10%, lift shadow
     - Only visible when recording
   
   - Button 2: [⚙️ Settings]
     - Style: Secondary (transparent, cyan border)
     - Padding: 12px 24px
     - Font: 14px bold, cyan
     - Always visible
     - Tap: Opens settings modal

7. Settings Modal (Optional):
   - Title: "Voice Settings"
   - Options:
     - Language: [Dropdown: Hindi, Bhojpuri, Marathi, etc.]
     - Input Volume: [Slider, 0-100%]
     - Output Speed: [Slider, 0.8x - 1.5x]
     - Accent Strength: [Slider, 0-100%]
   - Buttons: [Cancel] [Save Settings]

RESPONSIVE BEHAVIOR:

Desktop (1280px+):
  - Sidebar: Full width (240px)
  - Content: Full width with max-width 1040px
  - Orb size: 200px
  - Layout: Centered single column

Tablet (768px - 1279px):
  - Sidebar: Collapsible (60px icon-only, expandable on tap)
  - Content: Full width
  - Orb size: 160px
  - Padding: 16px (reduced)

Mobile (< 768px):
  - Sidebar: Bottom navigation (5 icons in 50px bar)
  - Content: Full-width, single column
  - Padding: 12px
  - Orb size: 120px
  - Title: 28px (scaled down)

ANIMATIONS:

Idle State:
  - Orb: 2s pulse (0.9 → 1.0 scale), ease-in-out, infinite
  - Glow: Subtle breathing effect

Recording State:
  - Orb: Pulsing glow intensifies (0.4 → 0.8 opacity)
  - Waveform: Active, bars animating with audio
  - Status: "🎤 Listening..." with animated microphone

Processing State:
  - Orb: Rotating ring border (1s linear infinite)
  - Waveform: Fade out
  - Status: "🔄 Processing..." with rotating icon

Success/Response State:
  - Orb: Green glow + checkmark animation (500ms bounce)
  - Status: "✅ Ready for input"
  - Response displays in transcription area

ACCESSIBILITY:

HTML Structure:
  <main role="main">
    <h1>Bharat Ki Awaaz — Voice AI for Bharat</h1>
    <div id="voice-assistant" role="region" aria-label="Voice assistant">
      <button 
        id="mic-button" 
        aria-label="Voice input microphone button"
        aria-pressed="false"
      >🎤</button>
      
      <div 
        id="waveform" 
        aria-hidden="true"
        role="img"
        aria-label="Animated audio waveform"
      ></div>
      
      <output
        id="transcription"
        aria-live="polite"
        aria-atomic="false"
        aria-label="Voice input transcription"
      ></output>
      
      <div id="status" aria-live="assertive">
        🎤 Listening...
      </div>
    </div>
  </main>

ARIA Attributes:
  - aria-label on mic button: "Start voice input"
  - aria-pressed: Toggles between "true" (recording) and "false" (idle)
  - aria-live="polite" on transcription: Announces updates
  - aria-live="assertive" on status: High-priority announcements
  - role="region" on voice assistant container
  - aria-describedby on waveform: "Animated visualization of audio input"

Focus Management:
  - Mic button: Always focusable via Tab
  - Focus indicator: 2px blue outline
  - Settings button: Tab-accessible after mic button
  - Escape key: Stops recording if active

OUTPUT:
Create a complete, interactive web mockup showing:
1. Full responsive layout (desktop, tablet, mobile views)
2. Sidebar navigation with active states
3. Centered voice orb with glassmorphism effect
4. Animated waveform visualization (SVG)
5. Live transcription area
6. Control buttons
7. CSS animations (pulse, waveform, transitions)
8. Accessibility attributes (ARIA, semantic HTML)
9. Responsive behavior with media queries
10. Hover/active states for all interactive elements

Make it feel premium, modern, and inspire confidence in users.
```

---

## Prompt 5: Guided Coach (Multi-Step Application Form)

```
Create the guided coach screen for Sahaayak, a step-by-step application wizard helping users apply for government schemes.

DESIGN REQUIREMENTS:
- Type: Multi-step form wizard (3-7 steps depending on scheme)
- Platform: Flutter mobile (responsive 360px width)
- Pattern: Progressive disclosure (one step at a time)
- Accessibility: Large touch targets, simple language, Hindi translations

LAYOUT STRUCTURE:
┌─────────────────────────────────┐
│ ← Back    Application Progress  │
├─────────────────────────────────┤
│                                 │
│ Step 2 of 5 (Eligibility)       │
│ ████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ │
│ (Progress bar)                  │
│                                 │
│ Verify Land Ownership           │
│ "Your land details are key"     │
│ ─────────────────────────────   │
│                                 │
│ How much agricultural land      │
│ do you own?                     │
│ (हिंदी अनुवाद)                  │
│                                 │
│ ○ Less than 1 hectare           │
│ ● 1 - 5 hectares        [2021] │
│ ○ 5 - 10 hectares              │
│ ○ More than 10 hectares        │
│                                 │
│ 💡 Tip: This determines your   │
│    subsidy amount and support.  │
│                                 │
│ [← Back]  [Continue →]         │
│                                 │
└─────────────────────────────────┘

HEADER SECTION (72px):
  - Back Button: Left-aligned, 32px circle touch target
    - Icon: ← (back arrow, 20px)
    - Tap: Returns to previous step (animation: slide right 250ms)
    - Color: Dark navy #0B193A
  
  - Title: "Application Progress" (18px bold, centered)
  - Right: Optional "Save" icon if form has changes

PROGRESS INDICATOR SECTION (80px):
  - Step Count: "Step 2 of 5" (14px secondary text, left-aligned)
  - Progress Bar: Full-width, 4px height
    - Background: #E5E9F0 (light grey)
    - Filled: Cyan #00B4D8 (40% filled for step 2 of 5)
    - Border Radius: 4px
    - Animation: Smooth transition when moving to next step (300ms ease)
  - Completed Indicator: Checkmarks (✓) on completed steps
  - Current Indicator: Blue dot on current step

STEP CONTENT SECTION (Dynamic height):

Step Title:
  - Font: 24px bold, dark navy #0B193A
  - Margin: 24px (top), 16px (sides)
  - Example: "Verify Land Ownership"

Step Description:
  - Font: 14px secondary text #6B7A95
  - Margin: 8px (top), 16px (sides)
  - Italicized, supportive tone
  - Example: "Your land details are key to determining your subsidy"

Question Text:
  - Font: 18px regular, dark navy #0B193A
  - Margin: 24px (top), 16px (sides)
  - Language: Simple, conversational
  - Translation: Hindi translation in smaller text (12px, secondary color)

INPUT COMPONENT TYPES:

TYPE 1: Radio Buttons (Single Select)
  ┌─────────────────────────────┐
  │ ○ Option 1                  │ ← 48px height touch area
  │   Supporting text (optional)│
  │                             │
  │ ● Option 2          [2021]  │ ← Selected state (blue dot)
  │   Supporting text            │
  │                             │
  │ ○ Option 3                  │
  │   Supporting text            │
  └─────────────────────────────┘

  Visual Spec:
    - Container: Full width card, white background
    - Height: 48px per option (minimum tap target)
    - Padding: 16px
    - Radio button: 20px circle
      - Unselected: 2px stroke, dark navy
      - Selected: Filled cyan (#00B4D8)
      - Animation: Fill animation on tap (200ms ease)
    - Label Text: 16px regular, #0B193A
    - Support Text (optional): 12px secondary, #6B7A95
    - Spacing between options: 8px

TYPE 2: Text Input
  ┌─────────────────────────────┐
  │ [Input field                │ ← 48px height
  │  Placeholder: "Enter..."    │
  │  Value: "Raj Kumar"         │
  │                             │
  │ Character count: 8/50]      │
  └─────────────────────────────┘

  Visual Spec:
    - Background: White
    - Border: 2px solid #E5E9F0
    - Border Radius: 8px
    - Padding: 12px 16px
    - Font: 16px regular, #0B193A
    - Focus: 2px cyan border, glow box-shadow
    - Height: 48px (minimum)
    - Error state: Red border, error icon
    - Success state: Green check icon

TYPE 3: Number/Amount Input
  ┌────────────────────────────┐
  │ [₹] [__________]           │ ← Currency symbol + input
  │                 [1,00,000] │ ← Formatted with commas
  │ Hint: max ₹25,00,000       │
  └────────────────────────────┘

TYPE 4: Dropdown Select
  ┌────────────────────────────┐
  │ [District ▼]               │ ← 48px height
  │ [Bihar]                    │ ← Currently selected
  │                            │
  │ Tap expands to:            │
  │ ○ Andhra Pradesh           │
  │ ○ Assam                    │
  │ ● Bihar                    │
  │ ○ Chhattisgarh             │
  └────────────────────────────┘

TYPE 5: Checkbox (Multiple Select)
  ┌────────────────────────────┐
  │ ☑ I have Aadhaar           │ ← Checked
  │ ☐ I have PAN card          │ ← Unchecked
  │ ☑ I have bank account      │
  │ ☐ I have land deed         │
  └────────────────────────────┘

TYPE 6: Date Picker
  ┌────────────────────────────┐
  │ Date of Birth              │
  │ [15 March 1985] [📅]       │ ← Tap opens native picker
  │                            │
  │ Age: 39 years (auto-calc)  │
  └────────────────────────────┘

HELPER SECTION:
  - Location: Below input field
  - Icon: 💡 (light bulb in cyan)
  - Background: Light blue #F0F4F9
  - Border-left: 4px cyan
  - Padding: 12px
  - Border Radius: 8px
  - Font: 14px secondary text
  - Example: "This determines your subsidy amount and support eligibility."
  - Animation: Fade-in (200ms) when step loads

VALIDATION & ERROR HANDLING:

Success State (Field Valid):
  - Border: 2px green #10B981
  - Icon: ✓ green checkmark (right side)
  - Animation: Checkmark bounce-in (300ms)

Error State (Field Invalid):
  - Border: 2px red #FF4757
  - Icon: ⚠ red warning (right side)
  - Error message below field
  - Font: 12px red, bold
  - Example: "Please select at least one option"
  - Animation: Shake (50px left-right, 3× oscillation)

NAVIGATION BUTTONS (Bottom, 80px):
  - Layout: Two-button horizontal layout
  - Background: White bar, shadow above
  - Position: Fixed at bottom (safe area padding)
  - Spacing: 16px between buttons

  Left Button: [← Back]
    - Style: Secondary (transparent, navy text)
    - Width: 45%
    - Height: 48px
    - Font: 14px bold
    - Padding: 12px 20px
    - Tap: Navigate to previous step
    - Disabled on step 1

  Right Button: [Continue →]
    - Style: Primary (cyan background #00B4D8)
    - Width: 45%
    - Height: 48px
    - Font: 14px bold, white
    - Padding: 12px 20px
    - Border Radius: 20px
    - Tap: Validate & move to next step
    - Loading state: Spinner inside, disabled
    - Error state: Shows error toast, button remains active

STEP PROGRESSION:

Step 1: Personal Information
  - Name (text input)
  - Date of Birth (date picker)
  - Mobile Number (phone input with country code)

Step 2: Eligibility (Radio buttons)
  - Land ownership amount (4 options)
  - Income category (3 options)

Step 3: Documents (Checkboxes)
  - Aadhaar (checkbox)
  - PAN Card (checkbox)
  - Bank account (checkbox)
  - Land deed (checkbox)

Step 4: Address Details (Text inputs)
  - Village name
  - District (dropdown)
  - State (dropdown)

Step 5: Bank Details (Text inputs)
  - Bank name (dropdown)
  - Account number
  - IFSC code

Step 6: Document Upload (File input)
  - Upload Aadhaar photo
  - Upload land deed scans

Step 7: Review & Submit
  - Show summary of all filled information
  - Option to edit any step
  - Final submit button

INTERACTIVE BEHAVIORS:
  - Field validation: Real-time on blur (when user moves to next field)
  - Auto-save: Save to local storage every 5 seconds
  - Progress bar: Animate on step change (300ms)
  - Back button: Always returns to previous step (animation: slide right 250ms)
  - Continue button: Only enabled when all required fields are valid
  - Loading: Show spinner on continue (during validation)

ACCESSIBILITY:
  - aria-label on radio buttons: "Option 1 of 4"
  - aria-describedby on inputs: Links to helper text
  - aria-invalid="true" on error fields
  - aria-live="polite" on error messages
  - Keyboard: Tab through fields, Enter to submit, Escape to go back
  - Screen reader: Announces step number, required fields, errors

OFFLINE SUPPORT:
  - Save progress to local storage
  - Show toast: "Saving offline..." when no internet
  - Badge: "Pending upload" on step 7
  - Allow resume on app restart

OUTPUT:
Create a detailed mockup showing:
1. Multiple step screens (show 2-3 different steps)
2. Different input types (radio, text, dropdown, etc.)
3. Error and success states
4. Progress bar animation
5. Helper text sections
6. Navigation buttons
7. Accessibility attributes
8. Responsive behavior
9. Haptic feedback triggers

Make it feel guided, safe, and encourage users to complete the application.
```

---

# How to Use These Prompts

## Option 1: Direct Usage with Claude API

```python
import anthropic

client = anthropic.Anthropic(api_key="your-api-key")

prompt = """
[Paste one of the prompts above, e.g., "Prompt 1: Home Screen Mobile App"]
"""

message = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=4000,
    messages=[
        {"role": "user", "content": prompt}
    ]
)

print(message.content[0].text)
```

## Option 2: Interactive Prompt Refinement

Start with a prompt, review the output, then refine:

```
"Great start! Now add dark mode colors and adjust the spacing to 8px grid."
```

## Option 3: Use with Design Tools

- **Figma**: Copy prompt into Figma's "AI Generate" feature
- **Penpot**: Use as design specification for manual component creation
- **Adobe XD**: Use as wireframe reference for mockup creation

## Option 4: Code Generation

Combine these prompts with a code-focused prompt:

```
"Using the design specifications from [insert prompt], generate React 
component code with:
- Tailwind CSS styling
- Accessible HTML structure
- Responsive media queries
- Animation keyframes
- TypeScript types
```

---

# Tips for Best Results

1. **Use Iteratively**: Start with one screen, refine, then move to next
2. **Combine Prompts**: Reference multiple prompts to maintain design consistency
3. **Request Variations**: Ask for "dark mode version" or "tablet layout"
4. **Ask for Code**: "Generate React component code for this design"
5. **Request Accessibility**: Explicitly ask for WCAG audit or accessibility annotations
6. **Request Animations**: Ask for "CSS keyframes" or "animation specifications"
7. **Color Adjustments**: Request specific color swaps or dark mode variants
8. **Responsive Designs**: Ask for "mobile, tablet, desktop versions"

---

**Created**: May 2026  
**Version**: 1.0 Production-Ready  
**Status**: Ready for immediate use with Claude, Figma, or design teams
