# Sahaayak - The Citizen AI

Sahaayak is a next-generation AI assistant designed to bridge the digital divide for rural India. By combining multi-dialect voice intelligence with a premium, accessible user interface, Sahaayak empowers every citizen to navigate government schemes and services with ease.

## Key Features

### Liquid Mic Technology
- Voice-First Interaction: Citizens can speak in their native dialect.
- Real-time Visualization: A glowing, tactile "Silicon Orb" provides instant feedback.
- Dialect Normalization: High-precision AI translates local dialects into actionable queries.

### Enterprise Web Dashboard
- Glassmorphic Design: A premium, modern interface with floating glow orbs and soft surfaces.
- Bento Grid Layout: Organized, high-contrast cards for a professional and accessible experience.
- Staggered Animations: Smooth, cinematic entrance for all UI elements.

### Omni-Channel Chat
- Official Identity: Verified "Sahaayak BharatBot" branding for trust.
- Seamless Transition: Move from voice interaction to a full-screen interactive chat hub.
- Interactive Experience: Familiar chat interface optimized for government service delivery.

### Premium Branding and Animation
- Animated SVG Logo: A breathing, floating logo integrated across Mobile and Web.
- Elite Design Tokens: High-end blur effects, custom shadows, and refined typography.

## Project Structure

This is a monorepo containing the following components:

- /sahaayak_backend: FastAPI backend providing the AI pipeline (STT, Dialect Normalization, Matching, TTS).
- /sahaayak_web: Enterprise-grade web dashboard for citizen insights.
- /lib: Flutter source code for the mobile application.

## Technology Stack

- Frontend: Flutter (Mobile), Vanilla JS/HTML5/CSS3 (Web)
- Backend: FastAPI (Python)
- Machine Learning: OpenAI Whisper (STT), Coqui TTS (TTS), BGE Embeddings, FAISS (Vector Search)
- Data Processing: Pandas, Apache Parquet
- Design: Glassmorphism, Bento Grid Layout, Outfit Typography

## Getting Started

### Backend Setup
Follow the instructions in the [Backend README](sahaayak_backend/README.md) to set up and run the service.

### Mobile and Web Setup
Refer to the respective project directories and their documentation for environment-specific setup instructions.

## Authors

- Team Percepta

## License

This project is licensed under the MIT License.
