# 🤖 SIMY - AI Personal Assistant

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Gemini AI](https://img.shields.io/badge/Google%20Gemini-8E75B2?style=for-the-badge&logo=googlebard&logoColor=white)

**SIMY** is a smart AI personal assistant built with Flutter. It integrates the **Google Gemini API** to provide intelligent conversational experiences, multimodal vision capabilities, and local memory management.

## 📱 Key Features

* **🧠 Smart & Responsive:** Powered by the `gemini-2.5-flash` model for fast and accurate responses.
* **👁️ Multimodal Vision:** Capable of "seeing" and analyzing images uploaded from the gallery or camera.
* **💾 Local Persistence:** Chat history is automatically saved locally on the device using shared preferences, ensuring conversations are never lost.
* **🎨 Modern UI:** Clean chat interface with full Markdown support (Bold, Code Blocks, Lists) and message timestamps.
* **🔒 Secure:** API Keys are safely managed using Environment Variables (`.env`).

## 🛠️ Tech Stack

* **Frontend:** Flutter & Dart (Cross-platform iOS & Android).
* **AI Core:** Google Generative AI SDK (Gemini).
* **Local Storage:** Shared Preferences (JSON serialization).
* **State Management:** Native `setState` (Clean Architecture & Separation of Concerns).

## 📸 Screenshots
<p align="center">

<img width="1206" height="2622" alt="SIMY_3" src="https://github.com/user-attachments/assets/048637e9-6101-42ac-a2fa-471412bbdfdd" />
<img width="1206" height="2622" alt="SIMY_2" src="https://github.com/user-attachments/assets/7538edec-c07a-43a0-93e0-a263dbcd3572" />
<img width="1206" height="2622" alt="SIMY_1" src="https://github.com/user-attachments/assets/bad0a1ea-7b65-4292-8a31-093256127e5c" />

</p>

## 🚀 Getting Started

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/viansuryajayaa/SIMY-AI-Assistant.git](https://github.com/viansuryajayaa/SIMY-AI-Assistant.git)
    ```
2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```
3.  **Setup Environment**
    Create a `.env` file in the root directory and add your Gemini API Key:
    ```env
    GEMINI_API_KEY=YOUR_API_KEY_HERE
    ```
4.  **Run the App**
    ```bash
    flutter run
    ```
