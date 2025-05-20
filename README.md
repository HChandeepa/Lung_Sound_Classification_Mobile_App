# PulmoSense AI - Mobile App

PulmoSense AI is a mobile-based deep learning application for **lung sound classification**, aimed at assisting healthcare professionals in diagnosing respiratory conditions efficiently and accurately. The app leverages deep learning and Flutter technologies to offer a modern, intelligent, and user-friendly diagnostic tool.

---

## 🚀 Features

- 🔐 Secure login/signup with Firebase Authentication
- 🧑‍⚕️ Add and manage patient profiles
- 🎧 Upload and analyze auscultation recordings
- 🧠 AI-based classification: Healthy or Diseased
- 📋 Detailed patient history logs
- 🩺 Diagnosis results with condition-specific breakdowns
- 🌐 Firebase integration for real-time sync and storage

---

## 🧠 AI Model Integration

PulmoSense AI incorporates a **two-phase deep learning pipeline**:

1. **Binary CNN Model** – Determines if the patient is Healthy or Diseased  
2. **Ensemble Classifier (CNN / CNN-LSTM)** – If diseased, identifies the condition (e.g., Asthma, Pneumonia, COPD)

The AI inference runs via a Flask API deployed on **Hugging Face Spaces**, which the mobile app communicates with using HTTP requests.

---

## 📱 Tech Stack

| Layer     | Technology           |
|-----------|----------------------|
| Frontend  | Flutter (Dart)       |
| Backend   | Firebase (Auth + Firestore) |
| ML Models | Python (CNN, CNN-LSTM) |
| API       | Flask                |
| Hosting   | Hugging Face Spaces  |

---

## 📂 Project Structure (Flutter)

lung_sound_system/
└── lib/
└── screens/
├── add_patient.dart
├── dashboard.dart
├── forgot_password.dart
├── Healthy diagnosis page.dart
├── history_page.dart
├── history_page copy.dart
├── login.dart
├── new_patients_auscultation.dart
├── patient_details_page.dart
├── profile_page.dart
├── select_patient.dart
├── signup.dart
├── splash.dart
└── firebase_options.dart
└── main.dart


---

## 🧪 How to Use

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pulmosense-ai.git
   cd pulmosense-ai/lung_sound_system

2. **Install Flutter dependencies**
   ```bash
   flutter pub get

3. **Run the app**
   ```bash
   flutter run
