# 🛰️ ResourceRadar AI
> **Google Solution Challenge 2026** — Transforming humanitarian crisis response with real-time, AI-powered resource allocation.

ResourceRadar AI is a comprehensive platform designed to bridge the gap between reported needs and available resources during humanitarian crises. By leveraging **Gemini 1.5 Pro**, **Google Cloud**, and **Flutter**, it provides a seamless ingestion pipeline for field data, automated intelligent triage, and optimized resource matching.

---

## 🌟 Key Features

- **🛡️ Multimodal AI Triage**: Integrated Gemini 1.5 Pro to verify and score reported needs using text, images, and geolocation data.
- **📱 Field Agent App**: A robust Flutter mobile application optimized for low-connectivity environments with offline-first Firestore persistence.
- **🏗️ Event-Driven Backend**: A scalable microservices architecture built with Node.js/TypeScript and Python, orchestrated via Google Cloud Pub/Sub.
- **🛰️ Intelligent Normalization**: Automatic geocoding and data canonicalization using Google Maps Platform APIs.
- **🤖 Autonomous Matching**: ANN-based resource matching to connect volunteer skills and NGO supplies to high-urgency zones.
- **🚛 Optimized Routing**: Capacitated Vehicle Routing Problem (CVRP) solving using Google Routes Optimization API.

---

## 🛠️ Tech Stack

### Frontend & Mobile
- **Flutter**: Cross-platform mobile app for Field Agents.
- **Next.js**: (Planned) Premium coordinator dashboard for real-time situational awareness.
- **Lucide Icons**: Modern, consistent iconography across all interfaces.

### Backend & AI
- **Node.js (TypeScript)**: High-performance data ingestion (Normalizer, SMS Webhook).
- **Python (FastAPI)**: AI-heavy services (Triage, Matching, Routing).
- **Gemini 1.5 Pro/Flash**: Multimodal reasoning, parsing unstructured SMS, and risk assessment.
- **Firebase**: Firestore (Real-time DB), Firebase Functions, and Auth.

### Infrastructure
- **Google Cloud Platform**: Pub/Sub, Vertex AI, Maps Platform, Routes Optimization.
- **Docker**: Containerized services for consistent deployment.

---

## 📂 Project Structure

```text
├── apps/
│   ├── field-agent/      # Flutter mobile application
│   └── coordinator/      # (Planned) Next.js Dashboard
├── backend/
│   ├── normaliser/       # TS service for data cleaning & geocoding
│   ├── triage-service/   # Python service for Gemini AI analysis
│   ├── matching-service/ # Resource-to-need allocation engine
│   └── routing-service/  # Fleet optimization using Routes API
├── functions/            # Firebase Cloud Functions (Triggers)
├── data/                 # Sample datasets and schemas
├── docs/                 # PRD, Architecture diagrams, and API specs
└── infra/                # Infrastructure-as-code (Terraform/Docker)
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x+)
- Node.js (v20+)
- Python (3.11+)
- Google Cloud Project with Gemini API access

### Configuration
1. **Sanitize Environment**: Copy `.env.example` to `.env` in the respective service directories.
2. **Firebase Setup**:
   - Create a Firebase project.
   - Update `apps/field-agent/lib/firebase_options.dart` with your actual credentials.
3. **API Keys**:
   - Enable **Gemini API** via Google AI Studio or Vertex AI.
   - Enable **Maps JavaScript API**, **Geocoding API**, and **Routes Optimization API**.

---

## 📋 What's Left To Do (Roadmap)

### [Phase 2] Mobile & Data Collection
- [ ] Implement **Full Image Compression** pipeline before upload.
- [ ] Add **Biometric Auth** for Field Agent security.

### [Phase 3] Matching & Routing Intelligence
- [ ] Complete **ANN Implementation** in `matching-service` using Vertex AI.
- [ ] Integrate **Real-time Traffic Data** into `routing-service`.

### [Phase 4] Premium Coordinator Dashboard
- [ ] Build **Next.js Dashboard** with interactive ward-level heatmaps.
- [ ] Implement **AI Reasoning Sidebar** to show Gemini's triage logic.

### [Phase 5] SMS & Analytics
- [ ] finalize **Hinglish/Hindi SMS Parsing** using Gemini 1.5 Flash.
- [ ] Build **Crisis Impact Reports** (PDF generation).

---

## 📄 License

This project is licensed under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for details.

---

Developed for the **Google Solution Challenge 2026**.
