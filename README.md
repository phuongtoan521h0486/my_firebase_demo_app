# My Firebase Demo App

## Instructions for Use and Testing

### 1. System Requirements
- **Operating System:** Windows, macOS, or Linux.
- **Flutter SDK Version:** 3.24.3
- **Dart SDK Version:** Comes bundled with Flutter 3.24.3.
- **Android Studio:** Version 2024.1 or above is required.
- **Hardware Requirements:** At least 8 GB of RAM is recommended for a smooth development experience.

### 2. Project Setup
1. **Extract the Project:**
    - Unzip the `my_firebase_demo_app.zip` file to your preferred location. The extracted folder should be named `my_firebase_demo_app`.

2. **Open the Project in Android Studio:**
    - Launch Android Studio (version 2024.1 or above) and open the `my_firebase_demo_app` folder.
    - Android Studio will automatically recognize the Flutter project.

3. **Install Dependencies:**
    - Open the terminal inside Android Studio.
    - Run the following command to install dependencies:
      ```bash
      flutter pub get
      ```
    - This will ensure all the necessary dependencies are installed.
4. **Environment Configuration:**
    - Make sure the project has a `.env` file inside. If it doesn't exist, refer to the `.env.example` file to set it up correctly.

### 3. Running the Project
1. **Run the Project:**
    - Connect an Android or iOS device, or use an emulator/simulator.
    - Run the following command in the terminal:
      ```bash
      flutter run
      ```
    - Alternatively, you can use the "Run" button in Android Studio to start the project.

### 4. Testing Specific Features
- **Authentication:** Test different sign-in methods (Google, Facebook, X) from the login screen.
- **Real-Time Task Management:** Verify adding, editing, deleting, and viewing tasks works seamlessly.
- **Cloud Functions:** Check the functionality of cloud functions: sending a welcome email after registration.

### Developed by GTV Team ❤