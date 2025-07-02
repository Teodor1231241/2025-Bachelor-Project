#🍽️ Personalized Restaurant Recommendation Web App
This project implements a cross-platform web application for personalized restaurant recommendations using Flutter, Firebase, Google Places API, and advanced NLP models (Gemma-2-2b-it). The system automatically collects, processes, and analyzes restaurant reviews to extract structured data on dishes, sentiment, and context, providing users with relevant, filterable recommendations based on dietary preferences, allergens, budget, and occasion.

#Key features:

Flutter frontend (web/mobile-ready) with responsive, modern UI and Google Sign-In authentication.

Firebase backend with Firestore for structured storage of restaurants, user profiles, and reviews, supporting scalability to 10,000+ concurrent users.

Google Places API integration for location, reviews, and metadata retrieval, with token usage optimization to reduce API costs.

Advanced NLP pipeline using Gemma-2-2b-it for automatic extraction of dishes from reviews and sentiment analysis, clustering dishes for menu synthesis even in the absence of online menus.

Automated review scraping pipeline capable of collecting over 1,000 reviews/hour, structured for further ML processing.

Interactive map-based discovery using Google Maps with real-time filtering.

Real-time recommendation updates based on user feedback and preferences.

Secure authentication and error handling, including CORS mitigation and secure credential storage.

Optimized for GPU-based processing using Google Colab for review summarization and sentiment analysis at minimal infrastructure cost.

The project demonstrates that a performant, scalable personalized recommendation system can be built using free/open-source technologies while reducing user search time from 20+ minutes to under 2 minutes per session.

