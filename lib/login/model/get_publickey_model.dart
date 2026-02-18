import 'dart:convert';

GetPublicKey getPublicKeyFromJson(String str) => GetPublicKey.fromJson(json.decode(str));

String getPublicKeyToJson(GetPublicKey data) => json.encode(data.toJson());

class GetPublicKey {
  String publicKey;

  GetPublicKey({
    required this.publicKey,
  });

  factory GetPublicKey.fromJson(Map<String, dynamic> json) => GetPublicKey(
    publicKey: json["publicKey"],
  );

  Map<String, dynamic> toJson() => {
    "publicKey": publicKey,
  };
}
