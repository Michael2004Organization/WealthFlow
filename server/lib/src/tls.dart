import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';

/// The server's own TLS certificate, created on the first start.
final class ServerCertificate {
  ServerCertificate._(this.certificatePem, this.privateKeyPem);

  /// Certificate in PEM format, also what browsers import.
  final String certificatePem;
  final String privateKeyPem;

  /// SHA-256 fingerprint of the certificate (DER), as the app pins it:
  /// 64 hex digits, upper case.
  String get fingerprint => certificateFingerprint(certificatePem);

  /// Same fingerprint grouped in blocks of four for reading aloud.
  String get readableFingerprint {
    final hex = fingerprint;
    return [
      for (var i = 0; i < hex.length; i += 4) hex.substring(i, i + 4),
    ].join(' ');
  }

  SecurityContext securityContext() => SecurityContext()
    ..useCertificateChainBytes(utf8.encode(certificatePem))
    ..usePrivateKeyBytes(utf8.encode(privateKeyPem));

  static const certificateFileName = 'wealthflow.crt';
  static const privateKeyFileName = 'wealthflow.key';

  /// Loads the certificate from [directory] or creates a new one valid for
  /// [hostNames] (ten years).
  static Future<ServerCertificate> loadOrCreate(
    Directory directory, {
    required List<String> hostNames,
  }) async {
    final certificateFile = File(
      '${directory.path}${Platform.pathSeparator}$certificateFileName',
    );
    final keyFile = File(
      '${directory.path}${Platform.pathSeparator}$privateKeyFileName',
    );
    if (await certificateFile.exists() && await keyFile.exists()) {
      return ServerCertificate._(
        await certificateFile.readAsString(),
        await keyFile.readAsString(),
      );
    }
    final created = create(hostNames: hostNames);
    await directory.create(recursive: true);
    await keyFile.writeAsString(created.privateKeyPem, flush: true);
    await certificateFile.writeAsString(created.certificatePem, flush: true);
    return created;
  }

  /// Creates a self-signed ECDSA P-256 certificate.
  static ServerCertificate create({required List<String> hostNames}) {
    final pair = CryptoUtils.generateEcKeyPair();
    final privateKey = pair.privateKey as ECPrivateKey;
    final publicKey = pair.publicKey as ECPublicKey;
    final names = {
      for (final name in hostNames)
        if (name.trim().isNotEmpty) name.trim().toLowerCase(),
    }.toList();
    final csr = X509Utils.generateEccCsrPem(
      {'CN': names.first, 'O': 'WealthFlow Heimnetz'},
      privateKey,
      publicKey,
      san: names,
    );
    // Random positive serial number, so a recreated certificate never
    // collides with an old one a browser may still remember.
    final random = Random.secure();
    final serial = BigInt.parse(
      List.generate(
        15,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join(),
      radix: 16,
    ).toString();
    final certificate = X509Utils.generateSelfSignedCertificate(
      privateKey,
      csr,
      3650,
      sans: names,
      serialNumber: serial,
      extKeyUsage: [ExtendedKeyUsage.SERVER_AUTH],
      notBefore: DateTime.now().toUtc().subtract(const Duration(days: 1)),
    );
    return ServerCertificate._(
      certificate,
      CryptoUtils.encodeEcPrivateKeyToPem(privateKey),
    );
  }
}

/// SHA-256 fingerprint of a PEM certificate, 64 upper-case hex digits.
String certificateFingerprint(String certificatePem) =>
    derFingerprint(CryptoUtils.getBytesFromPEMString(certificatePem));

/// SHA-256 fingerprint of a DER certificate as delivered by a TLS handshake.
String derFingerprint(List<int> der) => CryptoUtils.getHash(
  Uint8List.fromList(der),
  algorithmName: 'SHA-256',
).toUpperCase();
