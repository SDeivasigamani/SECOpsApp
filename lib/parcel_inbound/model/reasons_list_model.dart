class ReasonsListModel {
  String? id;
  String? title;
  String? code;
  List<String>? scopes;

  ReasonsListModel({this.id, this.title, this.code, this.scopes});

  ReasonsListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    code = json['code'];
    scopes = json['scopes'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['code'] = this.code;
    data['scopes'] = this.scopes;
    return data;
  }
}
