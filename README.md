# WTFood

**Turn the food in your fridge into a recipe.**

WTFood is a mobile application developed during an internship in collaboration
with a company. Its core idea is simple: the user takes or uploads a photo of
the food available in their fridge, the AI identifies the ingredients, and the
app creates a recipe tailored to them.

## How it works

1. Take a photo of the fridge or select one from the gallery.
2. AI vision detects the available ingredients.
3. Review and adjust the detected list.
4. Generate a complete recipe with ingredients, portions, timing, steps, and a
   chef's tip.

## Features

- Camera and gallery-based ingredient scanning.
- AI-powered ingredient recognition and recipe generation.
- Ingredient review before generating a recipe.
- User authentication and profile management.
- Fridge inventory, saved recipes, favourites, and shopping lists.
- Light and dark themes, onboarding, and contextual in-app guidance.

## Technologies

| Area | Technology |
| --- | --- |
| Mobile application | Flutter and Dart |
| State management | Provider |
| Authentication and cloud database | Firebase Authentication and Cloud Firestore |
| AI | OpenRouter API with Google Gemini vision and text models |
| Image capture | `image_picker` |
| Media storage | Cloudinary |
| Recipe imagery | Pixabay API |
| UI and experience | Material Design, Google Fonts, Lottie, ShowcaseView, and Shared Preferences |

## Getting started

### Prerequisites

- Flutter SDK compatible with Dart `^3.11.4`
- A Firebase project configured for the target platforms
- An OpenRouter API key for AI-powered scanning and recipe generation
- A Pixabay API key if recipe image search is required

### Installation

```bash
git clone <repository-url>
cd <repository-directory>/wtfood_app
cp .env.example .env
flutter pub get
flutter run
```

On Windows PowerShell, replace the copy command with:

```powershell
Copy-Item .env.example .env
```

Add your keys to `.env`:

```env
OPENROUTER_API_KEY=your_openrouter_api_key
PIXABAY_API_KEY=your_pixabay_api_key
```

The `.env` file is intentionally excluded from version control. Firebase must
also be configured for your own project before running a fork of the app.

## Project structure

```text
wtfood_app/
├── assets/       # Images, animations, and local data
├── lib/
│   ├── core/     # Theme, constants, and environment access
│   ├── features/ # Feature-specific domain and presentation code
│   ├── screens/  # Application screens
│   ├── services/ # AI, Firebase, image, and recipe integrations
│   └── widgets/  # Reusable UI components
└── test/         # Unit tests
```

## Notes

This repository contains the internship project source code. API credentials,
local IDE settings, build outputs, and generated design exports are excluded
from version control to keep the repository focused and safe to share.
