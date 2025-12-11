# SnapFolio 📸

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.style=for-the-badge)

**SnapFolio** is a visually rich contact management application built with Flutter.
Moving beyond simple text lists, it features a unique **responsive photo preview** system that dynamically adapts to the user's screen width, offering a gallery-first experience.

## 📱 Preview

| List View (Responsive) | Detail View (Gallery) |
|:-------------------------:|:---------------------------:|
| ![List View](./assets/screenshots/list_view.png) | ![Detail View](./assets/screenshots/detail_view.png) |
> *Please add screenshots to the `assets/screenshots/` directory and update the paths above.*

## ✨ Key Features

* **Responsive Photo Preview**
    * Utilizes `LayoutBuilder` to mathematically calculate the optimal number of photo thumbnails to display based on the available device width.
    * Intelligently displays a `+N` overlay on the last visible slot if more photos exist.
* **Adaptive UI Layout**
    * Implemented defensive coding (`TextOverflow`, `maxLines`) to prevent layout breakage regardless of text length.
    * Maintains consistent card ratios using `IntrinsicHeight` and `AspectRatio`.
* **Detail Gallery**
    * Seamless navigation to a detailed profile view.
    * Full-feature scrollable `GridView` to browse the entire photo collection of a contact.

## 🛠 Tech Stack

* **Framework:** Flutter
* **Language:** Dart
* **State Management:** (Planned: Riverpod/Provider)
* **Backend (Planned):** Firebase (Auth, Firestore, Storage)

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites

* Ensure you have the Flutter SDK installed. ([Installation Guide](https://docs.flutter.dev/get-started/install))

### Installation

1.  **Clone the repository**
    ```bash
    git clone [https://github.com/IAmRickyChoi/SnapFolio.git](https://github.com/IAmRickyChoi/SnapFolio.git)
    ```
2.  **Install dependencies**
    ```bash
    flutter pub get
    ```
3.  **Run the app**
    ```bash
    flutter run
    ```

## 📝 License

Distributed under the **MIT License**. See the `LICENSE` file for more information.

## 👤 Author

**Ricky Choi**
* GitHub: [@IAmRickyChoi](https://github.com/IAmRickyChoi)
* Zenn: [@0570yh](https://zenn.dev/0570yh)
