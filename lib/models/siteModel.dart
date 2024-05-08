class SiteModel {
  String id;
  String name;
  String code;

  SiteModel.fromJson(Map<String, dynamic> json) 
    : id = json['id'],
      name = json['name'],
      code = json['code']; 
}