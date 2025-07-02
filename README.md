# 🍽️ Personalized Restaurant Recommendation Web App


A **cross-platform web application** for **personalized restaurant recommendations** leveraging **Flutter, Firebase, Google Places API, and advanced NLP models (Gemma-2-2b-it)**. The system automatically scrapes, processes, and analyzes restaurant reviews to extract structured insights for delivering **contextual, relevant recommendations** based on dietary preferences, allergens, budget, and occasion.

---

## 🚀 Features

 **Flutter frontend** (web/mobile-ready) with responsive UI and Google Sign-In authentication.  
 **Firebase backend** with Firestore for structured data storage (restaurants, users, reviews), scalable to 10,000+ concurrent users.  
 **Google Places API** integration with token optimization for cost efficiency.  
 **Advanced NLP pipeline** using **Gemma-2-2b-it** for dish extraction and sentiment analysis from unstructured reviews.  
 **Automated scraping pipeline** capable of collecting 1,000+ reviews/hour with metadata for ML pipelines.  
 **Interactive map-based discovery** with real-time filtering and Google Maps integration.  
 **Real-time recommendation updates** based on user feedback.  
 **Secure authentication, Firestore security rules, and CORS handling**.  
 **GPU-optimized processing** using Google Colab for cost-efficient large-scale NLP.

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart) with MVC architecture
- **Backend:** Firebase Authentication, Firestore, Cloud Storage
- **APIs:** Google Places API, Google Maps API, Unsplash API (fallback)
- **NLP:** Gemma-2-2b-it via HuggingFace & Google Colab pipelines
- **Cloud Processing:** Google Colab for GPU-based review summarization

---

## 📈 Outcomes

 Reduced user search time from ~20 minutes to under 2 minutes per session.  
 Enhanced discoverability of small restaurants lacking online menus.  
 Personalization across 15+ criteria (diet, allergens, budget, ambiance).  
 Free/open-source architecture demonstrating high-performance systems with minimal infrastructure costs.

---

## 🚧 Installation & Deployment

1️⃣ **Clone the repository:**
```bash
git clone https://github.com/yourusername/personalized-restaurant-app.git
cd personalized-restaurant-app
```

2️⃣ **Install Flutter dependencies:**
```bash
flutter pub get
```

3️⃣ **Configure Firebase:**
- Create a Firebase project.
- Enable Authentication (Google Sign-In).
- Configure Firestore.
- Download `google-services.json` and `GoogleService-Info.plist` and place them in the appropriate directories.

4️⃣ **Run the app locally:**
```bash
flutter run -d chrome
```

5️⃣ **Deploy to Firebase Hosting:**
```bash
firebase deploy
```

---

## 📝 Future Work

- Integration of **RAG pipelines** for contextual retrieval-enhanced recommendations.
- Multilingual NLP support for broader user reach.
- Advanced collaborative filtering with hybrid ML models for user clustering.
- Mobile app deployment for Android and iOS with additional offline capabilities.

---

## ✨ Acknowledgements

- [Google Firebase](https://firebase.google.com/)
- [Flutter](https://flutter.dev/)
- [Gemma Models](https://ai.google.dev/gemma)
- [Google Colab](https://colab.research.google.com/)
- [OpenStreetMap](https://www.openstreetmap.org/)

---
