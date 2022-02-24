class AppUser {
  String userId;
  String email;
  String userName;
  String userImage;
  String? company;
  String? companyId;
  bool approved;

  AppUser({
    required this.userId,
    required this.email,
    required this.userName,
    required this.userImage,
    required this.approved,
  });

  AppUser.company({
    required this.userId,
    required this.email,
    required this.userName,
    required this.userImage,
    required this.company,
    required this.companyId,
    required this.approved,
  });
}
