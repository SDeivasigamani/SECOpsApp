class ContainerModel {
  List<Matches>? matches;
  int? total;

  ContainerModel({this.matches, this.total});

  ContainerModel.fromJson(Map<String, dynamic> json) {
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
  String? number;
  String? entity;
  String? accountNumber;
  Dimensions? dimensions;
  Shipper? shipper;
  Shipper? consignee;
  String? type;
  String? sortationRuleCode;
  String? status;
  Weight? weight;
  List<String>? services;

  Matches(
      {this.number,
        this.entity,
        this.accountNumber,
        this.dimensions,
        this.shipper,
        this.consignee,
        this.type,
        this.sortationRuleCode,
        this.status,
        this.weight,
        this.services});

  Matches.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    entity = json['entity'];
    accountNumber = json['accountNumber'];
    dimensions = json['dimensions'] != null
        ? new Dimensions.fromJson(json['dimensions'])
        : null;
    shipper =
    json['shipper'] != null ? new Shipper.fromJson(json['shipper']) : null;
    consignee = json['consignee'] != null
        ? new Shipper.fromJson(json['consignee'])
        : null;
    type = json['type'];
    sortationRuleCode = json['sortationRuleCode'];
    status = json['status'];
    weight =
    json['weight'] != null ? new Weight.fromJson(json['weight']) : null;
    services = json['services'] != null ? json['services'].cast<String>() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['number'] = this.number;
    data['entity'] = this.entity;
    data['accountNumber'] = this.accountNumber;
    if (this.dimensions != null) {
      data['dimensions'] = this.dimensions!.toJson();
    }
    if (this.shipper != null) {
      data['shipper'] = this.shipper!.toJson();
    }
    if (this.consignee != null) {
      data['consignee'] = this.consignee!.toJson();
    }
    data['type'] = this.type;
    data['sortationRuleCode'] = this.sortationRuleCode;
    data['status'] = this.status;
    if (this.weight != null) {
      data['weight'] = this.weight!.toJson();
    }
    data['services'] = this.services;
    return data;
  }
}

class Dimensions {
  double? length;
  double? width;
  double? height; // Changed from int? to double?
  String? unit;

  Dimensions({this.length, this.width, this.height, this.unit});

  Dimensions.fromJson(Map<String, dynamic> json) {
    length = json['length'] != null ? (json['length'] as num).toDouble() : null;
    width = json['width'] != null ? (json['width'] as num).toDouble() : null;
    height = json['height'] != null ? (json['height'] as num).toDouble() : null; // Parsing using num
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['length'] = this.length;
    data['width'] = this.width;
    data['height'] = this.height;
    data['unit'] = this.unit;
    return data;
  }
}

class Shipper {
  String? name;
  List<String>? phones;
  List<String>? emails;
  Address? address;
  Location? location;

  Shipper({this.name, this.phones, this.emails, this.address, this.location});

  Shipper.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phones = json['phones'] != null ? json['phones'].cast<String>() : null;
    emails = json['emails'] != null ? json['emails'].cast<String>() : null;
    address =
    json['address'] != null ? new Address.fromJson(json['address']) : null;
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phones'] = this.phones;
    data['emails'] = this.emails;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    return data;
  }
}

class Address {
  String? country;
  String? city;
  String? state;
  List<String>? street;
  String? postCode;

  Address({this.country, this.city, this.state, this.street, this.postCode});

  Address.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    city = json['city'];
    state = json['state'];
    street = json['street'] != null ? json['street'].cast<String>() : null;
    postCode = json['postCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['country'] = this.country;
    data['city'] = this.city;
    data['state'] = this.state;
    data['street'] = this.street;
    data['postCode'] = this.postCode;
    return data;
  }
}

class Location {
  double? longitude;
  double? latitude;

  Location({this.longitude, this.latitude});

  Location.fromJson(Map<String, dynamic> json) {
    longitude = json['longitude'] != null ? (json['longitude'] as num).toDouble() : null;
    latitude = json['latitude'] != null ? (json['latitude'] as num).toDouble() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    return data;
  }
}

class Weight {
  double? value;
  String? unit;

  Weight({this.value, this.unit});

  Weight.fromJson(Map<String, dynamic> json) {
    value = json['value'] != null ? (json['value'] as num).toDouble() : null;
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['unit'] = this.unit;
    return data;
  }
}
