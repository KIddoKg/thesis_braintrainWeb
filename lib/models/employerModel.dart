class ListItem {
  final int id;
  final String name;
  final String branch;
  final String loginTime;
  bool isSelected;

  ListItem({
    required this.id,
    required this.name,
    required this.branch,
    required this.loginTime,
    this.isSelected = false,
  });
}

class Employee {
  String id;

  String? fullName;

  String? phone;

  List<dynamic>? dob;

  int? age;

  String? loginCode;

  String? gender;

  String? profileUrl;

  bool? monitored;

  Employee(
      {required this.id,
      required this.fullName,
      this.phone,
      this.dob,
      this.age,
      this.loginCode,
      this.gender,
      this.profileUrl,
      this.monitored,});

  Employee.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        fullName = json['fullName']??"",
        phone = json['phone'] ?? "",
        dob = json['dob'] ?? [],
        age = json['age']??0,
        loginCode = json['loginCode']??null,
        gender = json['gender'] ?? "",
        profileUrl = json['profileUrl']??"",
        monitored = json['monitored']??false;

  @override
  String toString() {
    return 'Employee(id: $id, name: $fullName, siteName: $fullName, active: $fullName)';
  }
}
