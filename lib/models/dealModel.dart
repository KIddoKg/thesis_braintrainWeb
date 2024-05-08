class Deal {
  Deal(this.id, this.name, this.employer, this.time,this.days, this.status, this.price, this.customer);

  final String id;

  final String name;

  final String employer;

  final String time;
  final String days;
  final String status;
  final String price;
  final String customer;

  @override
  String toString() {
    return 'Deal: {\n'
        '  id: $id,\n'
        '  name: $name,\n'
        '  brtimeanch: $time,\n'
        '  employer: $employer\n'
        '}';
  }
}
