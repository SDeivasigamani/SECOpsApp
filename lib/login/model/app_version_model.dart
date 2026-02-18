import 'dart:convert';

VersionCheckApiModel versionCheckApiModelFromJson(String str) => VersionCheckApiModel.fromJson(json.decode(str));

String versionCheckApiModelToJson(VersionCheckApiModel data) => json.encode(data.toJson());

class VersionCheckApiModel {
  bool? success;
  String? status;
  String? message;
  VersionCheckApiModelData? data;

  VersionCheckApiModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  factory VersionCheckApiModel.fromJson(Map<String, dynamic> json) => VersionCheckApiModel(
    success: json["success"],
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : VersionCheckApiModelData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class VersionCheckApiModelData {
  AppDataa? appData;

  VersionCheckApiModelData({
    this.appData,
  });

  factory VersionCheckApiModelData.fromJson(Map<String, dynamic> json) => VersionCheckApiModelData(
    appData: json["appData"] == null ? null : AppDataa.fromJson(json["appData"]),
  );

  Map<String, dynamic> toJson() => {
    "appData": appData?.toJson(),
  };
}

class AppDataa {
  AppDataData? data;
  String? status;
  String? message;

  AppDataa({
    this.data,
    this.status,
    this.message,
  });

  factory AppDataa.fromJson(Map<String, dynamic> json) => AppDataa(
    data: json["data"] == null ? null : AppDataData.fromJson(json["data"]),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "status": status,
    "message": message,
  };
}

class AppDataData {
  String? androidVersion;
  String? iosVersion;
  String? deleteAccount;
  String? rateUs;
  String? iosAppLink;
  String? androidAppLink;

  AppDataData({
    this.androidVersion,
    this.iosVersion,
    this.deleteAccount,
    this.rateUs,
    this.iosAppLink,
    this.androidAppLink,
  });

  factory AppDataData.fromJson(Map<String, dynamic> json) => AppDataData(
    androidVersion: json["android_version"],
    iosVersion: json["ios_version"],
    deleteAccount: json["delete_account"],
    rateUs: json["rate_us"],
    iosAppLink: json["ios_app_link"],
    androidAppLink: json["android_app_link"],
  );

  Map<String, dynamic> toJson() => {
    "android_version": androidVersion,
    "ios_version": iosVersion,
    "delete_account": deleteAccount,
    "rate_us": rateUs,
    "ios_app_link": iosAppLink,
    "android_app_link": androidAppLink,
  };
}
