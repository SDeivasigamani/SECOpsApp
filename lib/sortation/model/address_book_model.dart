class AddressBookModel {
  List<Matches>? matches;
  int? total;

  AddressBookModel({this.matches, this.total});

  AddressBookModel.fromJson(Map<String, dynamic> json) {
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
  List<String>? scopes;
  String? nickName;
  Details? details;

  Matches({this.scopes, this.nickName, this.details});

  Matches.fromJson(Map<String, dynamic> json) {
    scopes = json['scopes'].cast<String>();
    nickName = json['nickName'];
    details =
    json['details'] != null ? new Details.fromJson(json['details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['scopes'] = this.scopes;
    data['nickName'] = this.nickName;
    if (this.details != null) {
      data['details'] = this.details!.toJson();
    }
    return data;
  }
}

class Details {
  String? name;
  List<String>? phones;
  List<String>? emails;
  Address? address;
  Location? location;

  Details({this.name, this.phones, this.emails, this.address, this.location});

  Details.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phones = json['phones'].cast<String>();
    emails = json['emails'].cast<String>();
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
    street = json['street'].cast<String>();
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
  int? longitude;
  int? latitude;

  Location({this.longitude, this.latitude});

  Location.fromJson(Map<String, dynamic> json) {
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    return data;
  }
}
