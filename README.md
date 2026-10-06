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
dart pub get --directory server
flutter run
```

`dart pub get --directory server` holt die Abhängigkeiten des Servers (eigenes Paket in `server/`). Ohne diesen Schritt meldet der Editor im Ordner `server` viele Fehler wie „Target of URI doesn't exist“. Den Drift-Code neu erzeugen ist nur nach Änderungen am Datenbank-Schema nötig: `dart run build_runner build --workspace`.

Nach einem `git pull` mit vielen Änderungen hilft bei hartnäckigen Abhängigkeitsfehlern:

```bash
flutter clean
flutter pub get
dart pub get --directory server
```

Datenbank-Schema, Datendatei-Verschlüsselung und Finanzlogik liegen im Paket `packages/wealthflow_core`, damit App und Server denselben Code nutzen. `--workspace` erzeugt den Drift-Code dort mit.

Für Web werden `web/sqlite3.wasm` und `web/drift_worker.js` mitgeliefert. Eine Web-Auslieferung muss HTTPS und geeignete Security-Header verwenden.

## Server im Heimnetz

`server/` enthält den WealthFlow-Server: ein Programm mit eigener SQLite-Datenbank, das nur über HTTPS mit eigenem Zertifikat erreichbar ist. Die fertige Windows-Version baut GitHub Actions (Workflow „Server“, Artefakt `wealthflow-server-windows`). Bedienung siehe `server/windows/LIESMICH.txt`.

```bash
cd server
dart pub get
dart test
dart run bin/wealthflow_server.dart --daten ./daten --web ../build/web
```

Die App gleicht über `/api/sync` ab (ganzer Export, Zusammenführung mit `mergeUserData` auf beiden Seiten). Die Web-Version liefert der Server aus dem Ordner `web` neben `start.cmd` aus; gebaut wird sie mit `flutter build web --no-web-resources-cdn`, damit der Browser nichts von fremden Servern lädt.

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
dart run build_runner build --workspace
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
