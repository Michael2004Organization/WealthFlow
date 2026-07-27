# WealthFlow – vollständige Projektplanung

**Dokumentstatus:** freigegebene Planungsgrundlage
**Version:** 1.0
**Stand:** 27. Juli 2026

## 1. Zielbild

WealthFlow ist eine hochwertige, offline-fähige Finanzzentrale für Privatpersonen. Die Anwendung bündelt Bankkonten, Investments, Dividenden, Haushaltsbuch, Fahrzeuge, Finanzrechner und Statistiken in einer konsistenten Oberfläche. Sie läuft aus einer gemeinsamen Flutter-Codebasis auf Android, iOS, Windows, Linux, macOS und im Web.

Die Anwendung verfolgt drei gleichrangige Ziele:

1. **Vertrauen:** Daten sind standardmäßig lokal, verschlüsselt und strikt einem Benutzer zugeordnet.
2. **Nutzwert:** Kennzahlen, Historien, Rechner und interaktive Auswertungen führen von Rohdaten zu nachvollziehbaren Entscheidungen.
3. **Erweiterbarkeit:** Fachmodule bleiben unabhängig, besitzen klare Verträge und können ohne Umbau des Gesamtsystems ergänzt werden.

### 1.1 Nicht-Ziele der ersten Produktionsversion

- Keine Bank- oder Broker-Anbindung über Screen-Scraping.
- Kein automatisierter Wertpapierhandel und keine Anlageberatung.
- Keine gemeinschaftlichen Haushalte oder Mehrbenutzerfreigaben; diese werden erst nach belastbarer Einzelbenutzer-Mandantentrennung geplant.
- Keine selbst entwickelte Kryptografie.
- Kein vollständiger Server in Dart innerhalb des Flutter-Clients. Der Client spricht eine versionierte, technologieunabhängige HTTPS-API an; die konkrete Serverimplementierung wird separat spezifiziert.

## 2. Produktumfang

### 2.1 Identität und Benutzerkonto

- Registrierung, Anmeldung, Abmeldung, Profil, Profilbild und Einstellungen.
- Passwortänderung und zeitlich begrenzter Passwort-Reset im Servermodus.
- Lokale Identität ohne Netzwerkzwang sowie Remote-Identität mit Token- und Session-Verwaltung.
- Jede fachliche Entität trägt eine unveränderliche Benutzerzuordnung; sämtliche Abfragen sind darauf eingeschränkt.
- Rollenmodell für Benutzer und Administratoren auf Serverseite, ohne administrative Sonderwege im Client.

### 2.2 Dashboard und globale Navigation

- Personalisierbares Dashboard mit responsivem Ein- oder Zwei-Spalten-Raster.
- Kennzahlenkarten für Vermögen, Kontostände, Depot, Dividenden, Einnahmen, Ausgaben, Sparquote, Fahrzeuge und Performance.
- Karten führen per Deep Link in die jeweilige Detailansicht.
- Dauerhafte Navigation: Bottom Navigation auf kompakten, NavigationRail auf mittleren und erweiterten Ansichten.
- Globale Suche über alle aktivierten Module mit Entitätstyp-, Zeitraum- und Betragsfiltern.

### 2.3 Konten

- Mehrere Bankkonten mit Bank, Bezeichnung, Inhaber, IBAN, BIC, Kontonummer, Währung, Saldo, verfügbarer Summe und Notizen.
- Saldenhistorie und konsolidiertes Vermögen mit transparenter Währungsumrechnung.
- Sensible Kontodaten werden maskiert dargestellt und verschlüsselt gespeichert.

### 2.4 Investments und Dividenden

- Positionen für Aktien, ETFs, Kryptowährungen, Anleihen, Hebelprodukte, Knock-Outs, Fonds und Edelmetalle.
- Stammdaten, Broker, Transaktionen, Gebühren, Kurse, Werte, realisierte und unrealisierte Ergebnisse.
- Kombinierbare Filter sowie stabile Sortierung und Suche.
- Dividendenereignisse mit Frequenz, Sonderausschüttungen, Depot- und Unternehmensaggregation sowie Kalender.
- Kursdaten sind zunächst manuell beziehungsweise per Import pflegbar; Provider werden später über Adapter ergänzt.

### 2.5 Rechner

- Zinseszinsrechner mit Startkapital, Sparrate, Zinssatz, Laufzeit und Periodisierung.
- Entnahmerechner mit Rendite, Entnahmeintervall, Laufzeit und Kapitalverlauf.
- Persönliche Variante mit vorbelegtem Depotwert, ohne die Eingaben zu sperren.
- Ergebnisse zeigen Endkapital, Einzahlungen, Gewinn und eine nachvollziehbare Periodentabelle samt Chart.

### 2.6 Fahrzeuge und Fahrtkosten

- Beliebig viele Autos und Motorräder mit eigenen Stammdaten und Historien.
- Kostenereignisse für Tanken, Reparatur, Wartung, Hauptuntersuchung, Versicherung, Steuer, Reifen, Ölwechsel und Sonstiges.
- Fahrtkosten für Arbeitsweg, Urlaub und freie Strecken; Ausgabe pro Fahrt, Woche, Monat und Jahr.

### 2.7 Haushaltsbuch

- Einnahmen und Ausgaben mit Datum, Betrag, Kategorie, Händler, Beschreibung und Zahlungsmethode.
- Eigene Kategorien mit Farbe und Icon sowie archivierte Kategorien zur Erhaltung historischer Daten.
- Filter und Aggregationen für Monat, Jahr, Durchschnitt, Kategorie, Händler und Höchstwerte.

### 2.8 Statistik

- Übersichtsseite mit Vermögen, Depot, Konten, Dividenden, Haushalt, Fahrzeugen, Sparquote, Einnahmen und Ausgaben.
- Linien-, Balken-, Säulen-, Flächen- und Kreisdiagramme mit Titel, Erklärung, Legende, Tooltip und barrierearmer Alternativdarstellung.
- Detailansichten mit Zeitraum-, Konto-, Depot-, Fahrzeug-, Kategorie-, Wertpapier- und Brokerfiltern.
- Berechnete Kennzahlen nennen Datenstand, Währung und Filterkontext.

### 2.9 Datenaustausch und Einstellungen

- Export in CSV, XLSX, PDF und JSON; sensible Felder sind standardmäßig ausgeschlossen und müssen bewusst aktiviert werden.
- Validierter, als Vorschau dargestellter CSV- und JSON-Import mit Fehlerprotokoll und atomarer Übernahme.
- Backup und Wiederherstellung inklusive Formatversion und Integritätsprüfung.
- Theme, Sprache, Basiswährung und Datumsformat.
- Umschaltung zwischen lokalem und Servermodus über einen geführten Migrationsdialog.

## 3. Zielgruppen und zentrale Abläufe

### 3.1 Primäre Zielgruppen

- **Privatanleger:** benötigen Portfolio-, Performance- und Dividendenübersichten.
- **Budgetorientierte Haushalte:** erfassen Einnahmen und Ausgaben und verfolgen Sparziele.
- **Fahrzeughalter:** konsolidieren laufende und außerordentliche Mobilitätskosten.
- **Datenschutzbewusste Nutzer:** wünschen vollständige Offline-Nutzung und kontrollierten Export.

### 3.2 Kritische User Journeys

1. Lokales Profil anlegen, Basiswährung wählen und verschlüsselten Datenspeicher initialisieren.
2. Konto erfassen und dessen Saldo sofort im Dashboard und Gesamtvermögen sehen.
3. Investment samt Kauf erfassen und Performance sowie erwartete Dividenden nachvollziehen.
4. Ausgabe in wenigen Schritten buchen und in Monatsstatistik und Kategorieauswertung wiederfinden.
5. Fahrzeugkosten erfassen und Jahreskosten sowie Kosten je Kilometer auswerten.
6. Servermodus konfigurieren, Verbindung prüfen, Datenumfang bestätigen und inkrementell synchronisieren.
7. Backup exportieren, Integrität prüfen und in einem leeren Profil wiederherstellen.

## 4. Fachliche Regeln

- Geldbeträge werden niemals mit binären Gleitkommazahlen gespeichert, sondern als ganzzahlige Minor Units zusammen mit ISO-4217-Währung.
- Mengen und Kurse verwenden Dezimalzahlen mit expliziter Skalierung.
- Zeitpunkte werden intern in UTC gespeichert; reine Kalendertage behalten zusätzlich ihre fachliche Zeitzone beziehungsweise Local-Date-Semantik.
- Summen über mehrere Währungen erfordern einen gespeicherten Wechselkurs inklusive Kursdatum; fehlende Kurse werden sichtbar gemeldet, nicht stillschweigend angenommen.
- Gelöschte synchronisierbare Datensätze werden zunächst als Tombstone geführt.
- Historische Buchungen bleiben reproduzierbar. Änderungen an Kategorien, Namen oder Stammdaten verfälschen keine abgeschlossenen Berechnungen.
- Importe, Wiederherstellungen und Moduswechsel sind atomar oder vollständig rückrollbar.
- Finanzkennzahlen werden mit Formel, Rundungsregel und Testfällen dokumentiert.

## 5. Qualitätsziele

| Bereich | Messbares Ziel |
|---|---|
| Start | Warmer Start typischer Mobilgeräte unter 1 s; kalter Start unter 2,5 s |
| Interaktion | 60 fps im Normalbetrieb, keine lang laufenden Berechnungen im UI-Isolate |
| Listen | Flüssiges Scrollen mit mindestens 10.000 lokalen Buchungen durch Pagination |
| Suche | Lokale Standardsuche über 10.000 Datensätze unter 300 ms |
| Stabilität | Mindestens 99,5 % absturzfreie Sitzungen nach Produktionsfreigabe |
| Tests | Domain/Data mindestens 80 % Line Coverage; kritische Finanz- und Sync-Regeln 100 % Branch Coverage |
| Barrierefreiheit | WCAG 2.2 AA im Web; skalierbare Schrift bis 200 %, Tastatur- und Screenreader-Nutzung |
| Responsive UI | Funktionsfähig ab 320 CSS-Pixel Breite bis zu großen Desktopfenstern |
| Offline | Alle lokalen Kernfunktionen ohne Netzwerk; Sync wird zuverlässig nachgeholt |
| Datenverlust | Keine bestätigte Mutation ohne persistentes Journal beziehungsweise atomare Transaktion |

Die Zeiten sind Produktbudgets und werden nach Aufbau repräsentativer Benchmarks auf realer Hardware kalibriert.

## 6. Technische Leitentscheidungen

Diese Planung fixiert Grenzen, nicht das in Phase 2 zu erstellende Architekturdiagramm.

- Flutter stable und eine kompatible Dart-Version werden im Repository gepinnt.
- Feature-First Clean Architecture mit Presentation-, Domain- und Data-Grenzen.
- Riverpod für State Management und Dependency Injection; fachliche Logik bleibt frameworkunabhängig.
- Deklaratives Routing mit typisierten Routen, Deep Links und geschütztem App-Bereich.
- Material Design 3 mit zentralen Design Tokens, Light/Dark/System-Theme und responsiven Breakpoints.
- SQLite als plattformübergreifende lokale Persistenz, sofern der technische Spike Web, Verschlüsselung und Migration bestätigt. Eine isolierte Repository-Schnittstelle verhindert Anbieterbindung.
- Unveränderliche Modelle und explizite Serialisierung; Codegenerierung nur reproduzierbar und CI-geprüft.
- API-Kommunikation über HTTPS, versionierte DTOs, kurze Access Tokens, rotierende Refresh Tokens und sichere Plattform-Speicher.
- Hintergrundarbeit ist plattformgerecht: mobile/desktopfähige Scheduler, im Web ereignisgesteuerte Synchronisation ohne unrealistische Dauerprozesse.

Endgültige Bibliotheken werden in den folgenden Konzeptphasen mit Lizenz-, Wartungs-, Plattform- und Sicherheitsprüfung festgelegt.

## 7. Arbeitspakete und Lieferreihenfolge

### Phase 1 – Projektplanung (dieses Dokument)

**Ergebnis:** abgestimmter Umfang, Qualitätsziele, Risiken, Roadmap und Abnahmekriterien.
**Exit-Kriterium:** alle geforderten Module sind zugeordnet; offene Architekturfragen sind als Entscheidungen oder Spikes erfasst.

### Phase 2 – Architekturdiagramm

- Systemkontext, Container, Komponenten, Datenflüsse und Vertrauensgrenzen.
- Abhängigkeitsregel zwischen Presentation, Domain und Data.
- Plattformadapter für Secure Storage, Datenbank, Dateioperationen und Hintergrundaufgaben.

### Phase 3 – Datenbankmodell und ER-Diagramm

- Entitäten, Beziehungen, Schlüssel, Indizes, Lösch- und Historisierungsregeln.
- Mandantenschlüssel, Sync-Metadaten und Migrationsstrategie.
- Prüfung typischer Abfragen mit realistischen Datenvolumen.

### Phase 4 – Ordnerstruktur

- Feature-Grenzen, Core-Pakete, Teststruktur und Regeln für öffentliche APIs.
- Linter-Regeln zur Durchsetzung unerlaubter Abhängigkeiten.

### Phase 5 – Klassenmodell

- Aggregate, Value Objects, Use Cases, Repository-Verträge, Fehler- und Ergebnisobjekte.
- Verantwortlichkeiten und Lebenszyklen ohne UI- oder Persistenzdetails in der Domain.

### Phase 6 – UI-Konzept

- Designsystem, Tokens, Komponenten, Zustände, Animationen, Responsive-Verhalten und Accessibility.
- Wireflows für zentrale Journeys und Zustände für leer, lädt, Fehler, offline und konfliktbehaftet.

### Phase 7 – Navigationskonzept

- Informationsarchitektur, adaptive Shell, Unterrouten, Deep Links, Browserhistorie und Route Guards.

### Phase 8 – Datenmodelle

- Vollständige Domain-Modelle, Validierung, Serialisierung und Mapping-Verträge.
- Testvektoren für Geld, Zeit, Performance und Rundung.

### Phase 9 – API-Konzept

- Versionierte REST-Ressourcen, Authentifizierung, Pagination, Filter, Idempotenz und Fehlerformat.
- OpenAPI-Vertrag, Rate Limits, Auditierbarkeit und Kompatibilitätsregeln.

### Phase 10 – lokale Datenbank

- Schema, Verschlüsselung, Migrationen, Indizes, Transaktionen, Volltextsuche und Repository-Implementierungen.
- Performance- und Wiederherstellungstests.

### Phase 11 – Synchronisationskonzept

- Änderungsjournal, Cursor, Delta-Übertragung, Tombstones, Retry/Backoff und Konfliktstrategie.
- Zustandsautomat für Moduswechsel und beobachtbarer Sync-Status.

### Phase 12 – Sicherheitskonzept

- Bedrohungsmodell, Schlüsselverwaltung, Auth-Flows, Datenschutz, Logging, Export und Incident-Vorgehen.
- Security-Testplan und Freigabekriterien.

### Phase 13 – Flutter-Implementierung

Die Implementierung erfolgt in vertikalen, jeweils lauffähigen Inkrementen:

1. Toolchain, CI, App-Shell, Designsystem, Routing, Lokalisierung und Fehlerbehandlung.
2. Lokale Identität, Entsperrung, Profil und Einstellungen.
3. Konten und Dashboard-Kennzahlen.
4. Haushaltsbuch und Kategorien.
5. Investments, Transaktionen und Dividenden.
6. Fahrzeuge und Fahrtkosten.
7. Rechner.
8. Statistik und globale Suche.
9. Import, Export, Backup und Wiederherstellung.
10. Remote-Authentifizierung, Serverkonfiguration und Synchronisation.
11. Hardening, Accessibility, Performance, Plattformintegration und Release-Pipelines.

Jedes Inkrement enthält produktiven Code, Migrationen, automatisierte Tests, Dokumentation und eine auf allen betroffenen Plattformen geprüfte UI. Es werden keine Platzhalter in den Hauptbranch übernommen.

## 8. Test- und Qualitätssicherung

### 8.1 Testpyramide

- **Unit-Tests:** Value Objects, Berechnungen, Filter, Mapper und Use Cases.
- **Property-Tests:** Geldarithmetik, Rundung, Zeiträume, Import und Sync-Invarianten.
- **Repository-Tests:** echte lokale Datenbank mit Migrationen, Transaktionen und Benutzerisolation.
- **Widget-Tests:** Komponenten, Semantik, Themes, Breakpoints, Tastaturbedienung und Fehlerzustände.
- **Golden-Tests:** zentrale Ansichten in Light/Dark und kompakten/erweiterten Größen.
- **Integrationstests:** kritische Journeys, Offline/Online-Wechsel, Import/Export und Wiederherstellung.
- **Contract-Tests:** Client gegen OpenAPI und simulierte alte/neue Serverversionen.
- **Security-Tests:** Auth-, Zugriffskontroll-, Eingabe-, Dateipfad- und Exportprüfungen.
- **Performance-Tests:** große Datenbestände, Diagrammaggregation, Suche, Migration und Sync.

### 8.2 Continuous Integration

Für jeden Merge werden Formatierung, statische Analyse, verbotene Abhängigkeiten, Tests, Coverage-Gates, Codegenerierungs-Diff, Lizenzprüfung, Secret Scan und Builds ausgeführt. Plattformbuilds werden in einer Matrix auf den jeweils erforderlichen Hostsystemen erstellt; signierte Releases laufen nur aus geschützten Tags.

### 8.3 Definition of Done

Ein Arbeitspaket ist abgeschlossen, wenn:

- Akzeptanzkriterien und relevante Randfälle automatisiert getestet sind,
- Loading-, Empty-, Error-, Offline- und Berechtigungszustände gestaltet sind,
- Semantik, Tastaturbedienung, Kontrast und Textskalierung geprüft sind,
- Telemetrie keine Finanzwerte, Zugangsdaten oder personenbezogenen Inhalte enthält,
- Migration und Rückwärtskompatibilität dokumentiert sind,
- mindestens ein zweites Review Architektur und Sicherheit berücksichtigt,
- Dokumentation und Änderungsprotokoll aktualisiert sind.

## 9. Datenschutz und Sicherheit als Planungsanforderung

- Bedrohungsmodell nach STRIDE und mobile/web-spezifischer OWASP-Empfehlung vor Serverfreigabe.
- Passwörter werden ausschließlich serverseitig mit einem modernen, speicherharten Verfahren und individuellem Salt gehasht; der Client speichert kein Passwort.
- Tokens und lokale Schlüssel liegen in Keychain/Keystore beziehungsweise geeigneten OS-gesicherten Speichern. Web-Sessions bevorzugen sichere, `HttpOnly`, `Secure` und passende `SameSite`-Cookies; Details folgen dem Sicherheits- und API-Konzept.
- Datenbank- und Backupdateien werden mit authentifizierter Verschlüsselung geschützt. Schlüssel werden nicht zusammen mit verschlüsselten Exporten abgelegt.
- Serverseitige Autorisierung prüft jede Objektoperation unabhängig vom Client. Parametrisierte Abfragen, Schema-Validierung, Ausgabe-Encoding, CSP und CSRF-Schutz gehören zu den Abnahmekriterien.
- Protokolle sind strukturiert, minimiert und redigiert. IBAN, Tokens, API-Keys, Notizen und Finanzbeträge dürfen nicht in Diagnoseereignissen erscheinen.
- Konto- und Profillöschung umfasst lokale Daten, Serverdaten, Sessions, Sync-Metadaten und definierte Backup-Aufbewahrung.

## 10. Performance- und Datenstrategie

- Listen verwenden Cursor-Pagination und stabile Schlüssel statt großer Offsets.
- Aggregationen werden bei Bedarf inkrementell materialisiert und anhand des Änderungsjournals invalidiert.
- Diagramme erhalten bereits verdichtete, auf die Pixelbreite passende Datenpunkte; Rohdatenberechnung blockiert nicht das UI-Isolate.
- Repository-Abfragen projizieren nur benötigte Spalten, nutzen zusammengesetzte Indizes und werden mit Query-Plänen geprüft.
- Suchindizes und Vorschaubilder besitzen begrenzte, messbare Caches mit Invalidierung.
- Synchronisation überträgt Deltas, unterstützt Kompression und verhindert doppelte Mutationen durch Idempotenzschlüssel.
- Große Importe werden gestreamt, vorvalidiert und in begrenzten Batches innerhalb einer kontrollierten Transaktion verarbeitet.

## 11. Internationalisierung und Barrierefreiheit

- Erste Sprachen: Deutsch und Englisch; Texte liegen ausschließlich in ARB-Ressourcen.
- Zahlen, Währungen und Daten folgen der gewählten Locale, während Speicherung locale-unabhängig bleibt.
- Layouts unterstützen lange Übersetzungen, Textskalierung, Rechts-nach-links als spätere Erweiterung und unterschiedliche Desktop-Eingabegeräte.
- Charts besitzen tabellarische Alternativen, ausreichende Kontraste und nicht ausschließlich farbliche Kodierung.
- Fokusreihenfolge, Shortcuts, Hover, Screenreader-Labels und Touchziele werden pro Feature abgenommen.

## 12. Release- und Betriebsplanung

- Umgebungen: Development, Test, Staging und Production mit strikt getrennter Konfiguration.
- Semantische Versionierung für App, lokale Schemas, Backupformat und API.
- Gestaffelte Releases mit Crash- und Performancebeobachtung; keine personenbezogene Telemetrie ohne Einwilligung.
- Desktop-Pakete, Mobile-Stores und Web-Deployment erhalten reproduzierbare Buildanweisungen, Signierung und Prüfsummen.
- Datenmigrationen werden vor einem Release mit anonymisierten synthetischen Daten und einer Kopie aller unterstützten Vorgängerschemas getestet.
- Rollback berücksichtigt, dass lokale Schemamigrationen nicht immer rückwärtskompatibel sind; vor irreversiblen Schritten wird ein verifiziertes Backup angeboten.

## 13. Risiken und Gegenmaßnahmen

| Risiko | Auswirkung | Gegenmaßnahme |
|---|---|---|
| Einheitliche verschlüsselte DB auf sechs Plattformen | Blockiert Offline-First oder Web | Früher technischer Spike; Storage-Vertrag und plattformspezifische Adapter |
| Hintergrund-Sync im Web/iOS eingeschränkt | Verzögerte Aktualität | Ereignisgesteuerter Sync, Resume/Connectivity-Trigger, transparente Statusanzeige |
| Finanzarithmetik oder Währungsumrechnung fehlerhaft | Vertrauens- und Vermögensschaden | Decimal/Minor Units, versionierte Formeln, Golden- und Property-Tests |
| Konflikte bei mehreren Geräten | Überschriebene Daten | Änderungsjournal, Revisionen, deterministische Regeln und Konflikt-UI |
| Umfangreiche Charts belasten UI | Ruckeln und hoher Speicherbedarf | Voraggregation, Downsampling, Isolates und Performancebudgets |
| Serverkonfiguration leakt Geheimnisse | Kontenübernahme | Secure Storage, redigierte Logs, kurzlebige Tokens, keine Passwörter nach Login speichern |
| Funktionsumfang verzögert Release | Qualitätsverlust | Vertikale Inkremente, harte Exit-Kriterien und priorisierte Produktionsmeilensteine |
| Plugin unterstützt einzelne Plattform nicht | Fragmentierung | Plattformmatrix und Wartungsprüfung vor Aufnahme; Adapter plus Fallback |
| Importierte Dateien sind bösartig oder fehlerhaft | Datenverlust, Ressourcenangriff | Größenlimits, Streaming, Schema- und Formel-Injection-Schutz, Vorschau, Transaktion |

## 14. Meilensteine und Priorisierung

### M0 – validierte Grundlagen

Phasen 1 bis 12, technische Spikes und ausführbarer App-Shell-Prototyp. Keine Fachfunktion wird begonnen, bevor Daten- und Sicherheitsgrenzen für sie geklärt sind.

### M1 – lokales Kernprodukt

Identität, Einstellungen, Konten, Haushalt, Dashboard, Suche, Backup und grundlegende Statistiken. Ziel ist ein vollständig offline nutzbares, releasefähiges Produktinkrement.

### M2 – Vermögen und Mobilität

Investments, Transaktionen, Dividenden, Rechner, Autos, Motorräder und Fahrtkosten einschließlich erweiterter Auswertungen.

### M3 – Server und Multi-Device

Remote-Authentifizierung, Serverkonfiguration, Delta-Sync, Konfliktbehandlung und Betriebsbeobachtung.

### M4 – Produktionshärtung

Externe Sicherheitsprüfung, Last- und Langzeittests, Store-Compliance, Accessibility-Audit, Datenmigrationsprobe und gestaffelter Rollout.

Die Planung verwendet bewusst keine Kalenderzusagen ohne bekannte Teamgröße und geprüfte technische Spikes. Nach Phase 12 werden die Pakete geschätzt und kapazitätsbasiert terminiert.

## 15. Abnahme der Gesamtanwendung

Die erste Produktionsversion gilt als abgenommen, wenn:

1. alle geforderten Plattformen eine signierbare, getestete Anwendung liefern,
2. Kernfunktionen im lokalen Modus ohne Netzwerk verwendbar sind,
3. ein Benutzer niemals Daten eines anderen Benutzers lesen oder verändern kann,
4. Moduswechsel und Delta-Synchronisation bei Unterbrechung ohne Datenverlust fortsetzbar sind,
5. sämtliche geforderten Module, Filter, Rechner, Diagramme und Austauschformate implementiert sind,
6. Backups verschlüsselt, verifiziert und erfolgreich wiederherstellbar sind,
7. Sicherheits-, Accessibility- und Performance-Gates erfüllt sind,
8. Installations-, Benutzer-, Betriebs-, Datenschutz- und Entwicklerdokumentation vollständig sind.

## 16. Offene Entscheidungen für die nächsten Phasen

Die folgenden Punkte werden nicht stillschweigend in Code entschieden:

- Welche SQLite-/Web-Persistenzkombination erfüllt Verschlüsselung, Migration und Performance nachweislich auf allen Zielplattformen?
- Soll der Servermodus selbst gehostete Instanzen, einen verwalteten Dienst oder beides offiziell unterstützen?
- Welche Daten dürfen bei einem Moduswechsel zusammengeführt werden und welche benötigen eine explizite Konfliktentscheidung?
- Welche Kurs- und Wechselkursprovider sind hinsichtlich Lizenz, Kosten, Rate Limits und Offline-Cache geeignet?
- Welche regulatorischen und steuerlichen Anforderungen gelten in den zuerst unterstützten Ländern?
- Welche Exportinhalte sind standardmäßig maskiert und welche erneute Authentifizierung ist für sensible Exporte erforderlich?

Diese Fragen werden als Architecture Decision Records beantwortet. Der unmittelbar nächste Liefergegenstand ist das Architekturdiagramm mit Systemkontext, Komponenten, Datenflüssen und Vertrauensgrenzen.
