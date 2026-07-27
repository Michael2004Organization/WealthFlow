# WealthFlow

WealthFlow ist eine lokale, plattformübergreifende Finanzverwaltung für Android, iOS, Windows, Linux, macOS und Web. Die Anwendung basiert auf Flutter, Material 3, Riverpod und Drift/SQLite.

## Enthaltene Funktionen

- Registrierung, Anmeldung, Abmeldung und Passwortänderung
- PBKDF2-SHA-256-Passwort-Hashes mit individuellem Salt
- sichere Sitzungsablage über den jeweiligen Plattform-Schlüsselspeicher
- strikt benutzerbezogene Datenabfragen
- responsive Navigation mit NavigationRail und NavigationBar
- Dashboard, Konten, Portfolio, Haushaltsbuch, Fahrzeuge, Rechner, Statistiken, globale Suche und Einstellungen
- lokale SQLite-Datenbank mit reaktiven Abfragen
- Light-, Dark- und System-Theme sowie konfigurierbarer Servermodus

## Start

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Für Web werden `web/sqlite3.wasm` und `web/drift_worker.js` mitgeliefert. Eine Web-Auslieferung muss HTTPS und geeignete Security-Header verwenden.

## Qualität

```bash
flutter analyze
flutter test
flutter build web
```

Die technischen Konzepte und Diagramme stehen in [`docs/architecture.md`](docs/architecture.md).
