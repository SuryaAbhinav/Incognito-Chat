# Incognito Chat

**Incognito Chat** is a lightweight and efficient frontend UI application for a Local Large Language Model (LLM) chatbot. Designed exclusively for MacOS and iOS, the app allows users to connect seamlessly over their home network, ensuring secure and private interactions with the backend server.

---

## Table of Contents

- [Project Description](#project-description)  
- [Technology Stack](#technology-stack)  
- [Getting Started](#getting-started)  
    - [Prerequisites](#prerequisites)  
    - [Installation](#installation)  
    - [Running the App](#running-the-app)  
- [Usage & Features](#usage--features)  
    - [Key Features](#key-features)  
    - [User Interface](#user-interface)  
    - [User Interactions](#user-interactions)  
- [License](#license)  

---

## Project Description

**Incognito Chat** is built to provide a user-friendly interface for interacting with a locally hosted LLM application. Its minimalist design, optimized for Apple devices, ensures an efficient user experience while maintaining complete data privacy. The app communicates with the backend server via API calls, delivering quick and accurate responses in a chat-based format.

---

## Technology Stack

The core technologies used in this project include:

- **Frontend:**  
  - **SwiftUI**  
  - **Swift** (Version: X.X.X)  
  - **Combine**  

- **Development Environment:**  
  - **Xcode** (Version: X.X.X)  

- **Optional Third-party Libraries:**  
  - **HighlightSwift** (For syntax highlighting in code responses)  
  - **Splash** (For rendering rich-text-based outputs)  
  - **Swift-Markdown-UI** (For Markdown-based UI elements)

---

## Getting Started

### Prerequisites

To build and run **Incognito Chat**, ensure you have the following:

- **Xcode** (Version: X.X.X or later)  
- **macOS** (Version: X.X.X or later)  
- **iOS** (Version: X.X.X or later)  

(Optional) Ensure your macOS and iOS versions meet compatibility requirements.

### Installation

1. Clone the repository to your local machine:  
   ```bash
   git clone <repository_url>
   ```

2. Navigate to the project folder and open the ```.xcworkspace``` file in Xcode.
3. Install dependencies:
    - If using CocoaPods:
    ```bash
    pod install
    ```
    - If using Swift Package Manager, dependencies will resolve automatically when the project is opened.

4. Download and set up the backend server application (Incognito Chat Backend):

    Follow the setup instructions for the backend to ensure seamless communication.

### Running the App

1. Open the project in Xcode.
2. Select a simulator or a connected device from the Xcode scheme selector.
3. Build and run the project by pressing ```Cmd + R``` or clicking the Run button in Xcode.

---

## Usage & Features

### Key Features

- Chatbot Interface:

    Interact with a locally hosted LLM via a clean and intuitive chat UI.

- Refresh Chat:

    Start a fresh conversation with the LLM by clicking the Refresh button.

### User Interface

- Message Input:
    
    Type your queries or messages in the text box provided at the bottom of the screen.
- Send Button:

    Click the Send button to receive responses from the backend.

- Chat History:
    
    View previous exchanges in the scrollable message window above the input box.

### User Interactions

1. Send Messages:

- Type a message in the input field.

- Click Send to submit the message and receive a response.

2. Refresh Chat:

- Use the Refresh button to clear the chat and start a new session.

---

## License

This project is licensed under the MIT License.

- **Permission**:
    
    You are free to download, modify, and use this project locally for personal or professional purposes.

- **Restriction**:
    
    Modifications or changes to the original repository are prohibited.

- **Disclaimer**:

    This project is provided "as is," without warranty of any kind. Use it at your own risk.

For the full license text, see the LICENSE file in the repository.

---

## Tips for Contributing

- Keep it simple and intuitive:
    
    Contributions that enhance the user experience are welcome.

- Follow best practices:
    
    Maintain code quality and consistency with the existing structure.
    
- Test your changes:
    
    Ensure the app runs smoothly on both MacOS and iOS before submitting a pull request.

---

## Screenshots

The view on MacOS:

![MacOS View](/Screenshots/MacOS%20View.png)

The view on iOS:

![iOS View](/Screenshots/iOS%20View.png)


**Happy chatting with Incognito Chat! 🚀**
