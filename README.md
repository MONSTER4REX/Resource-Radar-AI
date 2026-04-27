# 🛰️ ResourceRadar AI
### Real-time Humanitarian Resource Allocation via Multimodal AI

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Next.js](https://img.shields.io/badge/Dashboard-Next.js_14-black)](https://nextjs.org)
[![Flutter](https://img.shields.io/badge/Apps-Flutter_3.x-02569B)](https://flutter.dev)
[![Gemini](https://img.shields.io/badge/AI-Gemini_1.5_Flash-8E75B2)](https://deepmind.google/technologies/gemini/)

**ResourceRadar AI** is a state-of-the-art humanitarian platform designed to bridge the "last-mile" gap in disaster response. By combining multimodal AI triage with vector-based volunteer matching, it ensures that help reaches those who need it most, in seconds, not hours.

---

## 🚀 Key Features

- **🧠 Multimodal Triage**: Automated verification of help requests using **Gemini 1.5 Flash**. Analyzes text (English/Hindi/Hinglish) and photos to confirm legitimacy and calculate urgency (0-100).
- **⚡ Vector Matching Engine**: Uses **Vertex AI / ANN** to find the nearest, best-skilled volunteers for any given crisis.
- **📱 Dual-App Ecosystem**:
    - **Field Agent App**: Ultra-low-bandwidth reporting for victims and first responders.
    - **Volunteer App**: Task-focused interface for responders with real-time mission routing.
- **🗺️ Live Command Center**: A Next.js 14 dashboard for coordinators with interactive Google Maps integration and AI-driven insights.

## 🏗️ Architecture

```mermaid
graph TD
    A[Field Agent App] -->|Photo + Text| B(Firestore)
    B -->|Trigger| C[Triage Service]
    C -->|Gemini 1.5 Flash| D{Verification & Urgency}
    D -->|Verified| E[Matching Service]
    E -->|Vertex AI| F[Volunteer App]
    F -->|Accept Mission| G[Mission Routing]
    D -->|Insights| H[Coordinator Dashboard]
```

## 📂 Repository Structure

- `apps/field-agent/`: Flutter app for reporting needs.
- `apps/volunteer/`: Flutter app for responders.
- `apps/coordinator-nextjs/`: Next.js 14 management dashboard.
- `backend/triage-service/`: Python/Gemini service for signal analysis.
- `backend/matching-service/`: Python service for volunteer allocation.

## 🛠️ Quick Start

### 1. Prerequisites
- Flutter SDK (3.16+)
- Node.js (18+)
- Python (3.10+)
- Google Cloud Project with Gemini API & Maps SDK enabled.

### 2. Environment Setup
Copy `.env.example` to `.env` in the root directory and add your API keys:
```bash
GEMINI_API_KEY=your_key
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=your_key
GOOGLE_CLOUD_PROJECT=your_project_id
```

### 3. Run Locally
```bash
# Start Triage Service
cd backend/triage-service && pip install -r requirements.txt && python src/listener.py

# Start Coordinator Dashboard
cd apps/coordinator-nextjs && npm install && npm run dev
```

## ⚖️ License
Distributed under the **Apache License 2.0**. See `LICENSE` for more information.

---
Built with ❤️ for humanity by [ResourceRadar Team]
