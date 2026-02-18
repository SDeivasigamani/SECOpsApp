import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';

class HybridEncryptor {
  /// Generates a 128-bit AES key
  static Uint8List generateAesKey() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
  }

  /// Generates a 128-bit IV
  static Uint8List generateIv() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
  }

  /// AES Encrypt using CBC mode
  static Uint8List aesEncrypt(Uint8List plainText, Uint8List key, Uint8List iv) {
    final aesKey = encrypt.Key(key);
    final ivSpec = encrypt.IV(iv);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(aesKey, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );
    return Uint8List.fromList(
      encrypter.encryptBytes(plainText, iv: ivSpec).bytes,
    );
  }

  /// RSA Encrypt AES key using public key
  static Uint8List rsaEncrypt(Uint8List aesKeyBytes, RSAPublicKey publicKey) {
    final encryptor = RSAEngine()
      ..init(true, pc.PublicKeyParameter<RSAPublicKey>(publicKey));
    return encryptor.process(aesKeyBytes);
  }

  /// Encoder function (Base64)
  static String encoderFun(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Main function: Hybrid AES + RSA encryption
  static String? encryptHybrid({
    required String plainText,
    required RSAPublicKey rsaPublicKey,
  }) {
    try {
      // Step 1: Generate AES key and IV
      final aesKey = generateAesKey(); // 128-bit
      final iv = generateIv();

      // Step 2: Log secret AES key in base64
      final strSecretKey = encoderFun(aesKey);
      print("ENCRYPT ➜ strSecretKey --> $strSecretKey");

      // Step 3: AES encrypt the plainText
      final plainBytes = utf8.encode(plainText);
      final encryptedContent = aesEncrypt(Uint8List.fromList(plainBytes), aesKey, iv);

      // Step 4: RSA encrypt the AES key
      final encryptedAesKeyBytes = rsaEncrypt(aesKey, rsaPublicKey);
      print("LOGIN ➜ encryptedText --> ${base64Encode(encryptedAesKeyBytes)}");

      // Step 5: Concatenate [RSA_AES_KEY | IV | AES_CIPHERTEXT]
      final resultLength = encryptedAesKeyBytes.length + iv.length + encryptedContent.length;
      final result = Uint8List(resultLength);

      int offset = 0;
      result.setRange(offset, offset + encryptedAesKeyBytes.length, encryptedAesKeyBytes);
      offset += encryptedAesKeyBytes.length;

      result.setRange(offset, offset + iv.length, iv);
      offset += iv.length;

      result.setRange(offset, offset + encryptedContent.length, encryptedContent);

      // Step 6: Base64 encode final result
      final finalData = base64Encode(result);
      print("LOGIN ➜ finalData --> $finalData");

      return finalData;
    } catch (e) {
      print("Encryption error: $e");
      return null;
    }
  }
}
