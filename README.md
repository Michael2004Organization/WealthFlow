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

## Release-Builds

Vor dem ersten Build beziehungsweise nach Änderungen an Abhängigkeiten:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Android

Eine universelle APK:

```bash
flutter build apk --release
```

Kleinere, getrennte APKs je Prozessorarchitektur:

```bash
flutter build apk --split-per-abi
```

Die Ergebnisse liegen anschließend unter `build/app/outputs/flutter-apk/`.

### Windows

Falls die Windows-Plattformdateien in einer Kopie des Projekts fehlen:

```bash
flutter create --platforms=windows .
```

Release erstellen:

```bash
flutter build windows --release
```

Das Programm liegt anschließend unter `build/windows/x64/runner/Release/`.

### Web

Falls die Web-Plattformdateien in einer Kopie des Projekts fehlen:

```bash
flutter create --platforms=web .
```

Release erstellen:

```bash
flutter build web --release
```

Die auszuliefernden Dateien liegen anschließend unter `build/web/`. Für die
Web-Version ist ein HTTPS-Webserver erforderlich; öffne `index.html` nicht
direkt als lokale Datei.

## Datenschutz und Datendatei

Die Arbeitsdaten bleiben lokal. In den Einstellungen kann ein Ordner gewählt
werden, in dem WealthFlow automatisch `wealthflow-data.wflow` pflegt. Diese
Datei ist mit AES-256-GCM verschlüsselt; der Schlüssel wird im
Plattform-Schlüsselspeicher abgelegt und nicht in unverschlüsselten
Einstellungen gespeichert. Nach der Anmeldung können die eigenen Daten
weiterhin vollständig lesbar angezeigt oder bewusst als JSON exportiert werden.

Die technischen Konzepte und Diagramme stehen in [`docs/architecture.md`](docs/architecture.md).
