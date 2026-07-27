# WealthFlow

WealthFlow wird eine plattformübergreifende Finanzverwaltungsanwendung für Android, iOS, Windows, Linux, macOS und Web. Das Projekt wird iterativ geplant und implementiert, damit Architektur-, Sicherheits- und Qualitätsentscheidungen vor der eigentlichen Produktentwicklung überprüfbar bleiben.

## Aktueller Stand

Die Produktplanung und das konsolidierte Systemdesign sind abgeschlossen. Eine ausführbare Flutter-Anwendung mit adaptiver Navigation, lokal persistierten Finanzdaten, Dashboard, Konten, Portfolio, Haushaltsbuch, Statistiken, Fahrzeugen, Rechnern, Import/Export und Einstellungen ist implementiert.

## Dokumentation

1. [Vollständige Projektplanung](docs/01-projektplanung.md)
2. [Systemdesign: Architektur, Datenbank, Klassen, UI, API, Sync und Sicherheit](docs/02-systemdesign.md)
3. Datenbankmodell und ER-Diagramm *(im Systemdesign)*
4. Ordnerstruktur
5. Klassenmodell
6. UI-Konzept
7. Navigationskonzept
8. Datenmodelle
9. API-Konzept
10. Lokale Datenbank
11. Synchronisationskonzept
12. Sicherheitskonzept
13. Flutter-Implementierung *(aktive Ausbaustufe)*

## Starten

```bash
flutter pub get
flutter run
```

Tests und statische Analyse:

```bash
flutter analyze
flutter test
```

## Leitprinzipien

- Datenschutz und Mandantentrennung sind Bestandteil jeder fachlichen Funktion.
- Offline-First bleibt unabhängig von einer Serververbindung vollständig nutzbar.
- Features werden vertikal, testbar und ohne plattformspezifische Sackgassen entwickelt.
- Entscheidungen werden vor der Implementierung dokumentiert und durch automatisierte Qualitätsprüfungen abgesichert.
