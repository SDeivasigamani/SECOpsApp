class TripResultsModel {
  List<Matches>? matches;
  int? total;

  TripResultsModel({this.matches, this.total});

  TripResultsModel.fromJson(Map<String, dynamic> json) {
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
  // Null? parcels;
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
  ShipperReceiver? shipper;
  ShipperReceiver? receiver;
  String? weight;
  String? dimensions;
  // String? account;
  // Null? services;
  String? shipDate;
  String? closedOn;

  Matches(
      {
        // this.parcels,
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
        // this.account,
        // this.services,
        this.shipDate,
        this.closedOn});

  Matches.fromJson(Map<String, dynamic> json) {
    // parcels = json['parcels'];
    id = json['id'];
    createdOn = json['createdOn'];
    estimatedDeliveryTime = json['estimatedDeliveryTime'];
    if (json['trackingNumbers'] != null) {
      trackingNumbers = json['trackingNumbers'].cast<String>();
    }
    truckId = json['truckId'];
    note = json['note'];
    entity = json['entity'];
    type = json['type'];
    sortationRuleCode = json['sortationRuleCode'];
    description = json['description'];
    shipper = json['shipper'] != null ? ShipperReceiver.fromJson(json['shipper']) : null;
    receiver = json['receiver'] != null ? ShipperReceiver.fromJson(json['receiver']) : null;
    weight = json['weight']?.toString();
    dimensions = json['dimensions']?.toString();
    // account = json['account'];
    // services = json['services'];
    shipDate = json['shipDate'];
    closedOn = json['closedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['parcels'] = this.parcels;
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
    data['shipper'] = this.shipper?.toJson();
    data['receiver'] = this.receiver?.toJson();
    data['weight'] = this.weight;
    data['dimensions'] = this.dimensions;
    // data['account'] = this.account;
    // data['services'] = this.services;
    data['shipDate'] = this.shipDate;
    data['closedOn'] = this.closedOn;
    return data;
  }
}

class ShipperReceiver {
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

  ShipperReceiver(
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

  ShipperReceiver.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['phones'] != null) {
      phones = json['phones'].cast<String>();
    }
    if (json['emails'] != null) {
      emails = json['emails'].cast<String>();
    }
    longitude = json['longitude'] != null ? (json['longitude'] as num).toDouble() : null;
    latitude = json['latitude'] != null ? (json['latitude'] as num).toDouble() : null;
    country = json['country'];
    city = json['city'];
    state = json['state'];
    if (json['street'] != null) {
      street = json['street'].cast<String>();
    }
    postCode = json['postCode']?.toString();
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
