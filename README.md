Predicții Tenis de Masă — Flutter (minimal, alb/negru)
====================================================

Ce conține acest pachet
- codul sursă Flutter (main.dart)
- pubspec.yaml cu dependențe (http, intl)
- instrucțiuni de construire

Important
- Sofascore folosește un API neoficial. Endpoint-urile folosite pot fi instabile sau diferite în timp.
- Dacă apelurile la API eșuează pe device, poți folosi un backend proxy (server mic pe Replit/Render) care face request-urile și le returnează aplicației.

Cum compilezi local (trebuie Flutter instalat)
1. Clone sau descarcă acest folder pe mașina ta.
2. Deschide terminal în folderul proiectului.
3. Rulează: `flutter pub get`
4. Build APK release: `flutter build apk --release`
5. Fișierul APK se va găsi în `build/app/outputs/flutter-apk/app-release.apk`

Build pe Replit sau CI
- Poți folosi GitHub Actions sau Replit + builder image pentru a crea APK în cloud.
- Dacă vrei, îți pot furniza un fișier YAML de GitHub Actions care rulează `flutter build apk` automat.

Observații finale
- Eu nu pot compila APK direct din acest mediu (limitări tehnice). Îți ofer codul complet și instrucțiuni clare — îmi spui dacă vrei și config de CI/GitHub Actions sau un script pentru Replit.