class Company {
  String? companyId;
  String name;
  String address;
  String postCode;
  String city;

  Company({
    required this.companyId,
    required this.name,
    required this.address,
    required this.postCode,
    required this.city,
  });

  Company.dto({
    required this.companyId,
    required this.name,
    this.address = '',
    this.postCode = '',
    this.city = '',
  });
}
