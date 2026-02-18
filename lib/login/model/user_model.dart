class UserModel {
  bool? success;
  String? message;
  Data? data;

  UserModel({this.success, this.message, this.data});

  UserModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? sId;
  Defaultrole? defaultrole;
  String? code;
  String? name;
  double? distance;

  Data({this.sId, this.defaultrole, this.code, this.name, this.distance});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    defaultrole = json['defaultrole'] != null
        ? new Defaultrole.fromJson(json['defaultrole'])
        : null;
    code = json['code'];
    name = json['name'];
    distance = (json['distance'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.defaultrole != null) {
      data['defaultrole'] = this.defaultrole!.toJson();
    }
    data['code'] = this.code;
    data['name'] = this.name;
    data['distance'] = this.distance;
    return data;
  }
}

class Defaultrole {
  String? name;

  Defaultrole({this.name});

  Defaultrole.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
