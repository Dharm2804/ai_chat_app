# ChatApp - Real-Time AI-Powered Chat App

**ChatApp** is a modern, feature-rich chat application built using **Flutter** and **Dart**, with **Firebase** as the backend. It offers real-time messaging, AI-powered features like image-to-text and speech-to-text generation, and seamless chat management functionalities. Whether you're looking to chat with friends or leverage AI capabilities, ChatApp has you covered!

## Features

- **User Authentication**: Secure login and registration using Firebase Authentication (email/password, anonymous, or other supported methods).
- **Real-Time Messaging**: Instant messaging powered by Firebase Firestore for a smooth and responsive chat experience.
- **Image-to-Text Generation**: Upload an image, and the AI extracts text from it (powered by an AI integration).
- **Speech-to-Text Generation**: Convert spoken words into text using AI-driven speech recognition.
- **Share Chat as PDF**: Export your chat conversations as PDF files for easy sharing.
- **Chat History**: View your past conversations with an intuitive chat history interface.
- **Stop Generating**: Halt AI text generation mid-process if needed.
- **Copy AI-Generated Answers**: Easily copy AI-generated text to your clipboard for quick use.

## Screenshots

<div style="display: flex; gap: 10px;">
  <img src="https://github.com/user-attachments/assets/df500ecb-0dd6-46a1-85c2-401b78252651" width="200" />
  <img src="https://github.com/user-attachments/assets/4869ccf4-3f1d-4c71-a6ee-ac0010614ac9" width="200" />
  <img src="https://github.com/user-attachments/assets/988a970d-6c96-435d-b966-c8fdd2a4e710" width="200" />
  <img src="https://github.com/user-attachments/assets/f907472a-6309-4427-ab0a-394b37ffc896" width="200" />
</div>
<div style="display: flex; gap: 10px;">
  <img src="https://github.com/user-attachments/assets/35fd36f9-0606-4195-9c18-e863006a7609" width="200" />
  <img src="https://github.com/user-attachments/assets/96d0d789-175e-4131-85c2-5d96eaadfb8f" width="200" />
  <img src="https://github.com/user-attachments/assets/54916c8c-bb4f-49a6-b947-d3f1b3aaad8d" width="200" />
  <img src="https://github.com/user-attachments/assets/189d3f62-2c1d-4e58-ab47-ff2b113b27ed" width="200" />
</div>
<div style="display: flex; gap: 10px;">
  <img src="https://github.com/user-attachments/assets/afd69050-8125-4672-9a53-ba7628fd4f9f" width="200" />
  <img src="https://github.com/user-attachments/assets/05b9c5dc-e576-48c4-b688-e622527584a0" width="200" />
  <img src="https://github.com/user-attachments/assets/368d9752-a613-42f5-9355-36177474470e" width="200" />
  <img src="https://github.com/user-attachments/assets/b167f7f2-f455-49b2-81c2-11f73835e108" width="200" />
</div>

## Prerequisites

Before you begin, ensure you have the following installed:  
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.x.x or later)  
- [Dart](https://dart.dev/get-dart) (included with Flutter)  
- [Firebase Account](https://firebase.google.com/)  
- An IDE like [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)  
- (Optional) Emulator or physical device for testing  

## Dependencies
Key packages used in this project:

- **firebase_core**: Firebase initialization
- **firebase_auth**: User authentication
- **cloud_firestore**: Real-time database
- **firebase_storage**: (Optional) For image uploads
- **speech_to_text**: Speech-to-text functionality
- **pdf**: PDF generation for chat export

*(Add any other AI or UI packages you used)*  
Full list available in `pubspec.yaml`.

## 🚀 Usage

### 1. Authentication
```mermaid
graph LR
    A[Launch App] --> B{Account?}
    B -->|Yes| C[Login]
    B -->|No| D[Sign Up]
    C --> E[Chat Dashboard]
    D --> E
```

### Usage
- **Sign Up/Login**: Create an account or log in using your credentials.
- **Start Chatting**: Send real-time messages to other users.
- **AI Features**:
  - Upload an image to extract text.
  - Use the mic to convert speech to text.
- **Manage Chats**:
  - View chat history.
  - Export chats as PDF.
  - Copy or stop AI-generated responses as needed.



