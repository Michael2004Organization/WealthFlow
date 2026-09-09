# Fehlerprüfung vom 09.09.2026

## Ursache und Korrektur

Die gemeldeten Fehler wurden mit einem Widget-Test reproduziert. Ein
`SearchableDropdownButtonFormField` in einem `AlertDialog` ohne fest vorgegebene
Inhaltsbreite verursachte diese Fehlerkette:

1. `LayoutBuilder does not support returning intrinsic dimensions.`
2. `Cannot hit test a render box with no size.`
3. `mouse_tracker.dart:199:12: !_debugDuringDeviceUpdate`.

Der Dialog fragt vor dem Layout die intrinsische Breite seines Inhalts ab.
Der zusätzliche `LayoutBuilder` im gemeinsamen Dropdown unterstützt diese
Abfrage nicht. Dadurch blieb der Dialog ohne berechnete Größe; bei aktiver
Maus folgten die beiden gemeldeten Assertions.

Der zusätzliche `LayoutBuilder` wurde entfernt. `DropdownMenu.expandedInsets`
übernimmt weiterhin die Anpassung an die verfügbare Breite. Filterung,
Auswahl und Formularanbindung bleiben erhalten. Fehler werden weiterhin
protokolliert; es werden keine Assertions oder Fehlermeldungen unterdrückt.

Das entspricht den dokumentierten Anforderungen an den Inhalt von
[Flutter AlertDialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html).

Zusätzlich wurden alle 36 Hinweise der statischen Analyse durch
String-Interpolation und explizite Blöcke bei Bedingungen bereinigt.

## Validierung

Umgebung: Windows, Flutter 3.44.4 (stable), Dart 3.12.2.

| Prüfung | Ergebnis |
| --- | --- |
| Regressionstest vor der Korrektur | Beide Dropdown-Varianten reproduzieren die Fehlerkette |
| `flutter analyze` | Keine Befunde |
| `flutter test --reporter expanded` | Alle 57 Tests bestanden |
| `flutter build web --release` | Web-Release unter `build/web` erstellt |
| `git diff --check` | Keine Whitespace-Fehler |

Die vier ergänzten Regressionstests prüfen:

- Dialoge mit automatisch ermittelter Breite, jeweils mit und ohne
  `isExpanded`: Öffnen, Mausbewegung, Suchtexteingabe, Auswahl und Schließen.
- Den tatsächlichen Steuerland-Dialog der Administration bei 360 × 800 und
  1920 × 1080 Pixeln, einschließlich Währungssuche, Auswahl und Abbrechen.

Die bestehende Suite prüft außerdem Datenbankmigration, Benutzertrennung,
Konten- und Portfoliobuchungen, Dividenden- und Steuerberechnungen,
Stammdaten, Passwort-Hashing, Marktdatenlogik sowie responsive Dialoge,
Anmeldung und Rechneransichten. Datenbanktests nutzen Testdatenbanken.

Lokale Laufprotokolle liegen unter `build/test-results.log`,
`build/analysis-results.log` und `build/web-build-results.log`.
Das ursprüngliche Fehlerbild ist in `build/dropdown-before.log` dokumentiert.
Der Build meldet auch einen erfolgreichen Wasm-Probelauf; erstellt wurde
der reguläre Web-Release.

## Umfang

Die Oberfläche wurde mit Flutter-Widget-Tests geprüft. Ein interaktiver
Browserlauf, native Geräte-/Emulatortests und native Release-Builds waren
nicht Teil dieses Prüflaufs. Die erfolgreichen Tests sichern die geprüften
Abläufe ab und sind keine Garantie für Fehlerfreiheit aller Funktionen.
