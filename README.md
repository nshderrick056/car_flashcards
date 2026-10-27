# Guess the Car

Flip-card flashcards: see a car photo, guess it, tap to flip and check.

## Setup
1. `flutter create .` (generates the android/ios/web folders)
2. Add car photos to `assets/cars/` with these names:
   porsche_911.jpg, ford_mustang.jpg, vw_beetle.jpg,
   lamborghini_countach.jpg, toyota_supra.jpg, tesla_model_s.jpg
   (any card without a photo shows a car icon instead)
3. `flutter run`

To add cars, put a new image in `assets/cars/` and add a line to the `cars` list in `lib/main.dart`.
