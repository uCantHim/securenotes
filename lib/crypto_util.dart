import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class DecryptionException implements Exception {
  const DecryptionException(this.reason);
  final String reason;
}

/// Create a hash digest of a string.
Uint8List hashString(String str, { Hash hash=sha256 }) {
  final digest = hash.convert(utf8.encode(str));
  return Uint8List.fromList(digest.bytes);
}

/// Create a cryptographic key from a password string.
Uint8List hashPassword(String password) {
  return hashString(password);
}

/// Encrypt a string.
Uint8List encryptData(String data, String password) {
  // Set up encryption resources
  final key = Key(hashPassword(password));
  final iv = IV.fromLength(16);
  final aes = Encrypter(AES(key, mode: AESMode.sic, padding: null));

  // Encrypt JSON data
  final checksum = hashString(data, hash: sha512);
  final encryptedData = aes.encrypt(data, iv: iv).bytes;

  // Prepend auxiliary data to the JSON payload
  return Uint8List.fromList(checksum + iv.bytes + encryptedData);
}

/// Decrypt byte data to a string.
///
/// Throws [DecryptionException] if the password is incorrect.
String decryptData(Uint8List bytes, String password) {
  const int checksumSize = 64;
  const int ivSize = 16;

  assert(bytes.length >= (checksumSize + ivSize));

  // Unpack the binary data format
  final checksum = bytes.sublist(0, checksumSize);
  final ivBytes = bytes.sublist(checksumSize, checksumSize + ivSize);
  final dataBytes = bytes.sublist(checksumSize + ivSize);

  // Set up decryption resources
  final key = Key(hashPassword(password));
  final iv = IV(ivBytes);
  final aes = Encrypter(AES(key, mode: AESMode.sic, padding: null));

  // Decrypt the JSON data
  final decrypted = aes.decrypt(Encrypted(dataBytes), iv: iv);

  // Check decrypted data against a checksum to test whether the key was
  // correct
  final eq = const ListEquality().equals;
  if (!eq(checksum, hashString(decrypted, hash: sha512))) {
    throw const DecryptionException('Incorrect password!');
  }

  return decrypted;
}

/// Serialize and encrypt a JSON object.
Uint8List encryptJson(dynamic jsonObj, String password) {
  return encryptData(json.encode(jsonObj), password);
}

/// Decrypt and parse data into a JSON object.
///
/// Throws [DecryptionException] if the password is incorrect.
dynamic decryptJson(Uint8List bytes, String password) {
  return json.decode(decryptData(bytes, password));
}
