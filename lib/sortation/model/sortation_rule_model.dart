class SortationRuleModel {
  List<Matches>? matches;
  int? total;

  SortationRuleModel({this.matches, this.total});

  SortationRuleModel.fromJson(Map<String, dynamic> json) {
    if (json['matches'] != null) {
      matches = <Matches>[];
      json['matches'].forEach((v) {
        matches!.add(new Matches.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.matches != null) {
      data['matches'] = this.matches!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    return data;
  }
}

class Matches {
  String? code;
  String? name;
  String? entity;
  Data? data;

  Matches({this.code, this.name, this.entity, this.data});

  Matches.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    entity = json['entity'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['entity'] = this.entity;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Rules>? rules;

  Data({this.rules});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['rules'] != null) {
      rules = <Rules>[];
      json['rules'].forEach((v) {
        rules!.add(new Rules.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rules != null) {
      data['rules'] = this.rules!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Rules {
  String? propertyName;
  String? operator;
  String? value;

  Rules({this.propertyName, this.operator, this.value});

  Rules.fromJson(Map<String, dynamic> json) {
    propertyName = json['propertyName'];
    operator = json['operator'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['propertyName'] = this.propertyName;
    data['operator'] = this.operator;
    data['value'] = this.value;
    return data;
  }
}
