class ContainerDetailModel {
  List<dynamic>? parcels;
  String? id;
  String? createdOn;
  String? estimatedDeliveryTime;
  List<String>? trackingNumbers;
  String? truckId;
  String? note;
  String? entity;
  String? type;
  String? sortationRuleCode;
  String? description;
  Shipper? shipper;
  Receiver? receiver;
  Weight? weight;
  Dimensions? dimensions;
  Account? account;
  List<dynamic>? services;
  String? shipDate;
  String? closedOn;

  ContainerDetailModel(
      {this.parcels,
        this.id,
        this.createdOn,
        this.estimatedDeliveryTime,
        this.trackingNumbers,
        this.truckId,
        this.note,
        this.entity,
        this.type,
        this.sortationRuleCode,
        this.description,
        this.shipper,
        this.receiver,
        this.weight,
        this.dimensions,
        this.account,
        this.services,
        this.shipDate,
        this.closedOn});

  ContainerDetailModel.fromJson(Map<String, dynamic> json) {
    parcels = json['parcels'] != null ? List<dynamic>.from(json['parcels']) : null;
    id = json['id'];
    createdOn = json['createdOn'];
    estimatedDeliveryTime = json['estimatedDeliveryTime'];
    trackingNumbers = json['trackingNumbers'] != null ? List<String>.from(json['trackingNumbers']) : null;
    truckId = json['truckId'];
    note = json['note'];
    entity = json['entity'];
    type = json['type'];
    sortationRuleCode = json['sortationRuleCode'];
    description = json['description'];
    shipper =
    json['shipper'] != null ? new Shipper.fromJson(json['shipper']) : null;
    receiver = json['receiver'] != null
        ? new Receiver.fromJson(json['receiver'])
        : null;
    weight =
    json['weight'] != null ? new Weight.fromJson(json['weight']) : null;
    dimensions = json['dimensions'] != null
        ? new Dimensions.fromJson(json['dimensions'])
        : null;
    account =
    json['account'] != null ? new Account.fromJson(json['account']) : null;
    services = json['services'] != null ? List<dynamic>.from(json['services']) : null;
    shipDate = json['shipDate'];
    closedOn = json['closedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['parcels'] = this.parcels;
    data['id'] = this.id;
    data['createdOn'] = this.createdOn;
    data['estimatedDeliveryTime'] = this.estimatedDeliveryTime;
    data['trackingNumbers'] = this.trackingNumbers;
    data['truckId'] = this.truckId;
    data['note'] = this.note;
    data['entity'] = this.entity;
    data['type'] = this.type;
    data['sortationRuleCode'] = this.sortationRuleCode;
    data['description'] = this.description;
    if (this.shipper != null) {
      data['shipper'] = this.shipper!.toJson();
    }
    if (this.receiver != null) {
      data['receiver'] = this.receiver!.toJson();
    }
    if (this.weight != null) {
      data['weight'] = this.weight!.toJson();
    }
    if (this.dimensions != null) {
      data['dimensions'] = this.dimensions!.toJson();
    }
    if (this.account != null) {
      data['account'] = this.account!.toJson();
    }
    data['services'] = this.services;
    data['shipDate'] = this.shipDate;
    data['closedOn'] = this.closedOn;
    return data;
  }
}

class Shipper {
  String? name;
  List<String>? phones;
  List<String>? emails;
  double? longitude;
  double? latitude;
  String? country;
  String? city;
  String? state;
  List<String>? street;
  String? postCode;

  Shipper(
      {this.name,
        this.phones,
        this.emails,
        this.longitude,
        this.latitude,
        this.country,
        this.city,
        this.state,
        this.street,
        this.postCode});

  Shipper.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phones = json['phones'].cast<String>();
    emails = json['emails'] != null ? List<String>.from(json['emails']) : null;
    longitude = (json['longitude'] as num?)?.toDouble();
    latitude = (json['latitude'] as num?)?.toDouble();
    country = json['country'];
    city = json['city'];
    state = json['state'];
    street = json['street'] != null ? List<String>.from(json['street']) : null;
    postCode = json['postCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phones'] = this.phones;
    data['emails'] = this.emails;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['country'] = this.country;
    data['city'] = this.city;
    data['state'] = this.state;
    data['street'] = this.street;
    data['postCode'] = this.postCode;
    return data;
  }
}

class Receiver {
  String? name;
  List<String>? phones;
  List<String>? emails;
  double? longitude;
  double? latitude;
  String? country;
  String? city;
  String? state;
  List<String>? street;
  String? postCode;

  Receiver(
      {this.name,
        this.phones,
        this.emails,
        this.longitude,
        this.latitude,
        this.country,
        this.city,
        this.state,
        this.street,
        this.postCode});

  Receiver.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phones = json['phones'].cast<String>();
    emails = json['emails'] != null ? List<String>.from(json['emails']) : null;
    longitude = (json['longitude'] as num?)?.toDouble();
    latitude = (json['latitude'] as num?)?.toDouble();
    country = json['country'];
    city = json['city'];
    state = json['state'];
    street = json['street'] != null ? List<String>.from(json['street']) : null;
    postCode = json['postCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phones'] = this.phones;
    data['emails'] = this.emails;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['country'] = this.country;
    data['city'] = this.city;
    data['state'] = this.state;
    data['street'] = this.street;
    data['postCode'] = this.postCode;
    return data;
  }
}

class Weight {
  num? value;
  String? unit;

  Weight({this.value, this.unit});

  Weight.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['unit'] = this.unit;
    return data;
  }
}

class Dimensions {
  num? length;
  num? width;
  num? height;
  String? unit;

  Dimensions({this.length, this.width, this.height, this.unit});

  Dimensions.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    width = json['width'];
    height = json['height'];
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

class Account {
  String? number;
  String? entity;
  String? name;

  Account({this.number, this.entity, this.name});

  Account.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    entity = json['entity'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['number'] = this.number;
    data['entity'] = this.entity;
    data['name'] = this.name;
    return data;
  }
}
