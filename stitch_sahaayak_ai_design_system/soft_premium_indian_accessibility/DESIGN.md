---
name: Soft Premium Indian Accessibility
colors:
  surface: '#faf8ff'
  surface-dim: '#ced9ff'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2ff'
  on-surface: '#0c1a3b'
  on-surface-variant: '#3d494d'
  inverse-surface: '#232f51'
  inverse-on-surface: '#eef0ff'
  outline: '#6d797e'
  outline-variant: '#bcc9ce'
  surface-tint: '#00677d'
  primary: '#00677d'
  on-primary: '#ffffff'
  primary-container: '#00b4d8'
  on-primary-container: '#00414f'
  inverse-primary: '#4cd6fb'
  secondary: '#5b3cdd'
  on-secondary: '#ffffff'
  secondary-container: '#7459f7'
  on-secondary-container: '#fffbff'
  tertiary: '#006c49'
  on-tertiary: '#ffffff'
  tertiary-container: '#19bc84'
  on-tertiary-container: '#00442d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b3ebff'
  primary-fixed-dim: '#4cd6fb'
  on-primary-fixed: '#001f27'
  on-primary-fixed-variant: '#004e5f'
  secondary-fixed: '#e5deff'
  secondary-fixed-dim: '#c9bfff'
  on-secondary-fixed: '#1a0063'
  on-secondary-fixed-variant: '#441cc8'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#faf8ff'
  on-background: '#0c1a3b'
  surface-variant: '#dae2ff'
typography:
  headline-lg:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Outfit
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Outfit
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Outfit
    fontSize: 20px
    fontWeight: '400'
    lineHeight: 30px
  body-md:
    fontFamily: Outfit
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  label-lg:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Outfit
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  tap-target-min: 48px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 64px
---

## Brand & Style

The design system is engineered to bridge the gap between high-end digital sophistication and extreme functional accessibility. It targets rural and semi-literate users in India, requiring a UI that feels "government-grade" in its reliability but "modern-premium" in its execution. 

The aesthetic style is **Soft Premium Glassmorphism**. This approach uses translucent layers and soft, ambient shadows to create a clear visual hierarchy that feels light and approachable rather than dense or intimidating. By combining the cleanliness of Corporate Modernism with the tactile depth of Glassmorphism, the design system fosters trust and reduces cognitive load through clear spatial relationships. Every visual decision is filtered through a high-contrast lens to ensure WCAG AAA compliance, making the interface legible in high-glare outdoor environments common in rural areas.

## Colors

The palette is anchored by a Light Mode foundation to ensure maximum legibility under sunlight. 

- **Primary Cyan (#00B4D8):** Used for primary actions and brand recognition. It conveys modern technology and cleanliness.
- **Secondary Purple (#7B61FF):** Reserved for AI-driven features, assistance, and highlights, providing a distinct visual cue for "smart" interactions.
- **Tertiary Green (#10B981):** Utilized for success states, confirmations, and "Government-verified" indicators to build trust.
- **Dark Navy Text (#0B193A):** Replaces pure black to maintain high contrast while feeling more premium and less harsh.
- **Background (#F7F9FC):** A cool, tinted white that reduces eye strain and provides a sophisticated canvas for glassmorphic effects.

## Typography

The design system uses **Outfit** exclusively for its geometric clarity and friendly, open counters. To accommodate semi-literate users, the scale is intentionally larger than standard frameworks. 

- **Weight Strategy:** Use Medium (500) or SemiBold (600) for most body text to ensure characters do not "disappear" on lower-quality mobile displays.
- **Readability:** Line heights are generous (1.5x for body) to prevent crowding. 
- **Hierarchy:** High contrast in weight (Bold for headlines vs Regular for body) is used to guide the eye toward the most important information without requiring deep reading.

## Layout & Spacing

The layout is built on a strict **8px grid system** to maintain mathematical harmony and ease of implementation. 

- **Touch-First Philosophy:** A minimum tap target of 48px is enforced for all interactive elements to accommodate varying levels of motor precision and larger thumb-driven mobile use.
- **Grid Model:** A 12-column fluid grid is used for desktop, collapsing to a 4-column grid for mobile. 
- **Negative Space:** Generous margins (20px minimum on mobile) are used to isolate functional groups, preventing the UI from feeling cluttered or overwhelming. Elements should be grouped within "Glass" containers to create distinct mental models for different tasks.

## Elevation & Depth

Depth is used functionally, not just decoratively. This design system employs three tiers of elevation:

1.  **Level 0 (Base):** The #F7F9FC background.
2.  **Level 1 (Glass Layers):** Semi-transparent white surfaces (#FFFFFF at 70-80% opacity) with a 16px-24px backdrop blur. These are used for primary cards and content areas. They feature a subtle 1px inner border (white at 40% opacity) to simulate a glass edge.
3.  **Level 2 (Active/Floating):** Elements that require immediate attention use a soft, diffused shadow. The shadow uses the Neutral color (#0B193A) at a very low opacity (8%) with a large blur radius (20px) and a slight Y-offset (8px) to create a "lifting" effect.

Avoid stacking more than two glass layers to maintain WCAG AAA contrast for text.

## Shapes

The shape language is defined by **Soft** geometry. A standard border radius of **12px (0.75rem)** is applied to all primary containers, buttons, and input fields.

This specific radius provides a balance between the formal structure of "government" software and the approachability of a consumer-facing app. 
- **Small elements (Chips/Tags):** Use a 50% radius for a pill shape to distinguish them from actionable buttons.
- **Large Containers:** Use 24px (rounded-xl) for main dashboard cards to emphasize the "soft premium" feel.

## Components

### Buttons
Buttons must be a minimum of 48px in height. The primary button uses the Cyan (#00B4D8) background with white text. For semi-literate users, buttons should always pair a clear, universal icon with a short text label.

### Input Fields
Inputs use a solid white background (not glass) to ensure maximum contrast for text entry. Borders are 2px thick when focused, using the Secondary Purple to indicate active AI assistance or the Primary Cyan for standard entry.

### Cards
Cards are the primary vehicle for information. They utilize the Level 1 Glassmorphism style. Titles within cards should be Headline-MD (24px) to ensure they are the first thing a user sees.

### Chips & Status Indicators
Status chips (e.g., "Pending", "Approved") must use high-saturation background tints of Green or Navy with bold white text to ensure status is glanceable without reading.

### Iconography
Icons should be "Filled" or "Thick Stroke" (2px minimum) to remain legible at small sizes. Avoid thin, illustrative icons. Every icon must serve as a literal representation of the action.

### Voice Trigger (AI)
A persistent, floating action button (FAB) for voice input should be styled with a Secondary Purple gradient and a subtle pulse animation, signaling it as the primary way for semi-literate users to interact.