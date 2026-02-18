class DestinationHandlingResultModel {
  List<Items>? items;
  String? type;

  DestinationHandlingResultModel({this.items, this.type});

  DestinationHandlingResultModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['type'] = this.type;
    return data;
  }
}

class Items {
  String? trackingNumber;
  String? scheme;
  String? status;
  String? containerTrackingNumber;
  Receiver? receiver;
  int? type;
  Weight? weight;
  Weight? chargeWeight;
  Dimensions? dimensions;
  CustomsDeclared? customsDeclared;
  List<References>? references;
  bool? isShippable;
  bool? holdStatus;
  Audit? audit;
  // List<Null>? services;
  List<Traces>? traces;

  Items(
      {this.trackingNumber,
        this.scheme,
        this.status,
        this.containerTrackingNumber,
        this.receiver,
        this.type,
        this.weight,
        this.chargeWeight,
        this.dimensions,
        this.customsDeclared,
        this.references,
        this.isShippable,
        this.holdStatus,
        this.audit,
        // this.services,
        this.traces});

  Items.fromJson(Map<String, dynamic> json) {
    trackingNumber = json['trackingNumber'];
    scheme = json['scheme'];
    status = json['status'];
    containerTrackingNumber = json['containerTrackingNumber'];
    receiver = json['receiver'] != null
        ? new Receiver.fromJson(json['receiver'])
        : null;
    type = json['type'];
    weight =
    json['weight'] != null ? new Weight.fromJson(json['weight']) : null;
    chargeWeight = json['chargeWeight'] != null
        ? new Weight.fromJson(json['chargeWeight'])
        : null;
    dimensions = json['dimensions'] != null
        ? new Dimensions.fromJson(json['dimensions'])
        : null;
    customsDeclared = json['customsDeclared'] != null
        ? new CustomsDeclared.fromJson(json['customsDeclared'])
        : null;
    if (json['references'] != null) {
      references = <References>[];
      json['references'].forEach((v) {
        references!.add(new References.fromJson(v));
      });
    }
    isShippable = json['isShippable'];
    holdStatus = json['holdStatus'];
    audit = json['audit'] != null ? new Audit.fromJson(json['audit']) : null;
    // if (json['services'] != null) {
    //   services = <Null>[];
    //   json['services'].forEach((v) {
    //     services!.add(new Null.fromJson(v));
    //   });
    // }
    if (json['traces'] != null) {
      traces = <Traces>[];
      json['traces'].forEach((v) {
        traces!.add(new Traces.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trackingNumber'] = this.trackingNumber;
    data['scheme'] = this.scheme;
    data['status'] = this.status;
    data['containerTrackingNumber'] = this.containerTrackingNumber;
    if (this.receiver != null) {
      data['receiver'] = this.receiver!.toJson();
    }
    data['type'] = this.type;
    if (this.weight != null) {
      data['weight'] = this.weight!.toJson();
    }
    if (this.chargeWeight != null) {
      data['chargeWeight'] = this.chargeWeight!.toJson();
    }
    if (this.dimensions != null) {
      data['dimensions'] = this.dimensions!.toJson();
    }
    if (this.customsDeclared != null) {
      data['customsDeclared'] = this.customsDeclared!.toJson();
    }
    if (this.references != null) {
      data['references'] = this.references!.map((v) => v.toJson()).toList();
    }
    data['isShippable'] = this.isShippable;
    data['holdStatus'] = this.holdStatus;
    if (this.audit != null) {
      data['audit'] = this.audit!.toJson();
    }
    // if (this.services != null) {
    //   data['services'] = this.services!.map((v) => v.toJson()).toList();
    // }
    if (this.traces != null) {
      data['traces'] = this.traces!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Receiver {
  String? name;
  List<String>? phones;
  List<String>? emails;
  dynamic? longitude;
  dynamic? latitude;
  String? country;
  String? city;
  String? state;
  List<String>? street;
  dynamic? postCode;

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
    phones = json['phones'] != null ? List<String>.from(json['phones']) : null;
    emails = json['emails'] != null ? List<String>.from(json['emails']) : null;
    longitude = json['longitude'];
    latitude = json['latitude'];
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
  double? value;
  String? unit;

  Weight({this.value, this.unit});

  Weight.fromJson(Map<String, dynamic> json) {
    value = (json['value'] as num?)?.toDouble();
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
  int? length;
  int? width;
  int? height;
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

class CustomsDeclared {
  int? amount;
  String? currency;

  CustomsDeclared({this.amount, this.currency});

  CustomsDeclared.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    return data;
  }
}

class References {
  String? type;
  String? value;

  References({this.type, this.value});

  References.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    return data;
  }
}

class Audit {
  String? createdOn;
  dynamic? modifiedOn;

  Audit({this.createdOn, this.modifiedOn});

  Audit.fromJson(Map<String, dynamic> json) {
    createdOn = json['createdOn'];
    modifiedOn = json['modifiedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdOn'] = this.createdOn;
    data['modifiedOn'] = this.modifiedOn;
    return data;
  }
}

class Traces {
  String? user;
  String? code;
  String? on;
  dynamic? onLocal;
  String? entity;
  dynamic? branch;
  List<Data>? data;

  Traces(
      {this.user,
        this.code,
        this.on,
        this.onLocal,
        this.entity,
        this.branch,
        this.data});

  Traces.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    code = json['code'];
    on = json['on'];
    onLocal = json['onLocal'];
    entity = json['entity'];
    branch = json['branch'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user'] = this.user;
    data['code'] = this.code;
    data['on'] = this.on;
    data['onLocal'] = this.onLocal;
    data['entity'] = this.entity;
    data['branch'] = this.branch;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? key;
  String? value;

  Data({this.key, this.value});

  Data.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}
