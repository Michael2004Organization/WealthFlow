import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wealthflow_core/database/app_database.dart';
import 'package:wealthflow_core/finance/bank_csv.dart';
import 'package:wealthflow_core/finance/bank_import.dart';

const _sparkasse =
    '"Auftragskonto";"Buchungstag";"Valutadatum";"Buchungstext";'
    '"Verwendungszweck";"Glaeubiger ID";"Mandatsreferenz";'
    '"Kundenreferenz (End-to-End)";"Sammlerreferenz";'
    '"Lastschrift Ursprungsbetrag";"Auslagenersatz Ruecklastschrift";'
    '"Beguenstigter/Zahlungspflichtiger";"Kontonummer/IBAN";'
    '"BIC (SWIFT-Code)";"Betrag";"Waehrung";"Info"\n'
    '"DE01";"03.11.26";"03.11.26";"KARTENZAHLUNG";"REWE SAGT DANKE";"";"";"";"";"";"";'
    '"REWE Markt GmbH";"DE02";"BIC";"-42,17";"EUR";"Umsatz gebucht"\n'
    '"DE01";"01.11.26";"01.11.26";"GUTSCHRIFT";"Lohn 10/2026";"";"";"";"";"";"";'
    '"Arbeitgeber AG";"DE03";"BIC";"2.512,40";"EUR";"Umsatz gebucht"\n';

const _ing =
    'Umsatzanzeige;Datei erstellt am: 05.11.2026 10:00\n'
    '\n'
    'IBAN;DE12 3456\n'
    'Kontoname;Girokonto\n'
    'Bank;ING\n'
    'Kunde;Max Mustermann\n'
    'Zeitraum;01.10.2026 - 05.11.2026\n'
    'Saldo;1.234,56;EUR\n'
    '\n'
    'Sortierung;Datum absteigend\n'
    '\n'
    'Buchung;Wertstellungsdatum;Auftraggeber/Empfänger;Buchungstext;'
    'Verwendungszweck;Saldo;Währung;Betrag;Währung\n'
    '04.11.2026;04.11.2026;Stadtwerke;Lastschrift;Strom Abschlag;1.234,56;EUR;-85,00;EUR\n';

const _dkb =
    '"Girokonto";"DE12345"\n'
    '""\n'
    '"Zeitraum:";"01.10.2026 - 31.10.2026"\n'
    '"Kontostand vom 31.10.2026:";"1.000,00 €"\n'
    '""\n'
    '"Buchungsdatum";"Wertstellung";"Status";"Zahlungspflichtige*r";'
    '"Zahlungsempfänger*in";"Verwendungszweck";"Umsatztyp";"IBAN";'
    '"Betrag (€)";"Gläubiger-ID";"Mandatsreferenz";"Kundenreferenz"\n'
    '"30.10.26";"30.10.26";"Gebucht";"Max";"Netflix";"Abo";"Ausgang";"DE9";"-13,99 €";"";"";""\n'
    '"29.10.26";"29.10.26";"Gebucht";"Oma Erna";"Max";"Geschenk";"Eingang";"DE8";"50,00 €";"";"";""\n'
    '"31.10.26";"31.10.26";"Vorgemerkt";"Max";"Tankstelle";"";"Ausgang";"";"-60,00 €";"";"";""\n';

const _comdirect =
    ';\n'
    '"Umsätze Girokonto";"Zeitraum: 30 Tage";\n'
    '"Neuer Kontostand";"1.234,56 EUR";\n'
    '\n'
    '"Buchungstag";"Wertstellung (Valuta)";"Vorgang";"Buchungstext";"Umsatz in EUR";\n'
    '"02.11.2026";"02.11.2026";"Lastschrift / Belastung";'
    '"Auftraggeber: Telekom Deutschland GmbH Buchungstext: Mobilfunk 11/2026";"-29,95";\n';

const _volksbank =
    'Bezeichnung Auftragskonto;IBAN Auftragskonto;BIC Auftragskonto;'
    'Bankname Auftragskonto;Buchungstag;Valutadatum;Name Zahlungsbeteiligter;'
    'IBAN Zahlungsbeteiligter;BIC (SWIFT-Code) Zahlungsbeteiligter;'
    'Buchungstext;Verwendungszweck;Betrag;Waehrung;Saldo nach Buchung;'
    'Bemerkung;Kategorie;Steuerrelevant;Glaeubiger ID;Mandatsreferenz\n'
    'Giro;DE1;BIC;VR Bank;15.10.2026;15.10.2026;Vermieter Müller;DE2;BIC;'
    'Dauerauftrag;Miete Oktober;-950,00;EUR;2.000,00;;;;;\n';

List<BankCsvRow> _read(String csv, {bool latin = false}) {
  final table = parseBankCsv(latin ? latin1.encode(csv) : utf8.encode(csv));
  return table.read();
}

void main() {
  test('Sparkasse (CSV-CAMT, Windows-Zeichensatz)', () {
    final table = parseBankCsv(latin1.encode(_sparkasse));
    expect(table.bank, 'Sparkasse');
    final rows = table.read();
    expect(rows, hasLength(2));
    expect(rows.first.date, DateTime(2026, 11, 3));
    expect(rows.first.amount, -42.17);
    expect(rows.first.counterparty, 'REWE Markt GmbH');
    expect(rows.first.purpose, 'REWE SAGT DANKE');
    expect(rows.last.amount, 2512.40);
  });

  test('ING mit Kopfzeilen über der Tabelle', () {
    final table = parseBankCsv(utf8.encode('﻿$_ing'));
    expect(table.bank, 'ING');
    final row = table.read().single;
    expect(row.date, DateTime(2026, 11, 4));
    expect(row.amount, -85);
    expect(row.counterparty, 'Stadtwerke');
    expect(row.purpose, 'Strom Abschlag');
  });

  test('DKB: Zahler bei Eingängen, vorgemerkte Umsätze fehlen', () {
    final rows = _read(_dkb);
    expect(rows.map((row) => (row.counterparty, row.amount)), [
      ('Netflix', -13.99),
      ('Oma Erna', 50.0),
    ]);
  });

  test('comdirect: Name steht im Buchungstext', () {
    final row = _read(_comdirect, latin: true).single;
    expect(row.counterparty, 'Telekom Deutschland GmbH');
    expect(row.purpose, 'Mobilfunk 11/2026');
    expect(row.amount, -29.95);
  });

  test('Volksbank', () {
    final table = parseBankCsv(latin1.encode(_volksbank));
    expect(table.bank, 'Volksbank');
    final row = table.read().single;
    expect(row.counterparty, 'Vermieter Müller');
    expect(row.amount, -950);
  });

  test('unbekanntes Format braucht eine Zuordnung', () {
    final table = parseBankCsv(
      utf8.encode('Tag,Wert,Wer\n2026-10-01,"1,234.50",Firma\n'),
    );
    expect(table.mapping, isNull);
    expect(table.header, ['Tag', 'Wert', 'Wer']);
    final row = table
        .read(const BankCsvMapping(date: 0, amount: 1, counterparty: 2))
        .single;
    expect(row.date, DateTime(2026, 10, 1));
    expect(row.amount, 1234.5);
    expect(row.counterparty, 'Firma');
  });

  test('Beträge und Daten', () {
    expect(parseBankAmount('-1.234,56 €'), -1234.56);
    expect(parseBankAmount('+3,00'), 3);
    expect(parseBankAmount('12.50'), 12.5);
    expect(parseBankAmount(''), isNull);
    expect(parseBankDate('31.02.2026'), isNull);
    expect(parseBankDate('01.03.26'), DateTime(2026, 3, 1));
  });

  group('Vorschau', () {
    final now = DateTime(2026, 11, 5);
    LedgerEntry entry(
      String id,
      DateTime date,
      double amount, {
      String merchant = '',
      String category = '',
      String account = 'giro',
    }) => LedgerEntry(
      id: id,
      userId: 'user',
      bookingDate: date,
      amount: amount.abs(),
      isIncome: amount > 0,
      category: category,
      merchant: merchant,
      description: '',
      paymentMethod: '',
      recurrenceId: '',
      sourceType: 'manual',
      sourceId: '',
      vehicleId: '',
      accountId: account,
      accountApplied: true,
      createdAt: now,
      updatedAt: now,
    );
    BankCsvRow row(DateTime date, double amount, [String who = 'REWE']) =>
        BankCsvRow(date: date, amount: amount, counterparty: who, purpose: '');

    test('erkennt Dubletten und schlägt Kategorien vor', () {
      final rows = [
        row(DateTime(2026, 11, 3), -42.17),
        row(DateTime(2026, 11, 3), -42.17),
        row(DateTime(2026, 11, 4), -9.99, 'Kino'),
      ];
      final candidates = prepareBankImport(
        rows: rows,
        accountId: 'giro',
        existing: [
          // Entered by hand a day earlier than the bank booked it.
          entry('hand', DateTime(2026, 11, 2), -42.17, merchant: 'Rewe'),
          entry(
            'old',
            DateTime(2026, 9, 1),
            -30,
            merchant: 'rewe',
            category: 'Lebensmittel',
          ),
          entry('other', DateTime(2026, 11, 4), -9.99, account: 'spar'),
        ],
      );

      // Only one of the two equal payments matches the hand-made entry.
      expect(candidates.map((item) => item.duplicate), [true, false, false]);
      expect(candidates[0].id, isNot(candidates[1].id));
      expect(candidates[0].category, 'Lebensmittel');
      expect(candidates[2].category, 'Sonstiges');
    });

    test('dieselbe Datei zweimal ergibt dieselben Ids', () {
      final rows = [row(DateTime(2026, 11, 3), -42.17)];
      final first = prepareBankImport(
        rows: rows,
        accountId: 'giro',
        existing: const [],
      ).single;
      final again = prepareBankImport(
        rows: rows,
        accountId: 'giro',
        existing: [entry(first.id, DateTime(2026, 1, 1), -1)],
      ).single;
      expect(again.id, first.id);
      expect(again.duplicate, isTrue);
    });
  });
}
