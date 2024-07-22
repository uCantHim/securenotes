import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

/// Create a cryptographic key from a password string.
Uint8List hashPassword(String password) {
  final digest = sha256.convert(utf8.encode(password));
  return Uint8List.fromList(digest.bytes);
}

/// Serialize and encrypt a JSON object.
Uint8List encryptJson(dynamic jsonObj, String password) {
  final key = Key(hashPassword(password));
  final iv = IV.fromLength(16);
  final aes = Encrypter(AES(key, mode: AESMode.sic, padding: null));

  final jsonData = json.encode(jsonObj);
  final encryptedJson = aes.encrypt(jsonData, iv: iv).bytes;

  // Prepend the IV to the data
  return Uint8List.fromList(iv.bytes + encryptedJson);
}

/// Decrypt and parse data into a JSON object.
dynamic decryptJson(Uint8List bytes, String password) {
  assert(bytes.length >= 16);

  final ivBytes = bytes.sublist(0, 16);
  final dataBytes = bytes.sublist(16);

  final key = Key(hashPassword(password));
  final iv = IV(ivBytes);
  final aes = Encrypter(AES(key, mode: AESMode.sic, padding: null));

  final decrypted = aes.decrypt(Encrypted(dataBytes), iv: iv);
  return json.decode(decrypted);
}
