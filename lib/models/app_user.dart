class AppUser {
  String userId;
  String email;
  String userName;
  String userImage;
  String? company;
  String? companyId;

  AppUser({
    required this.userId,
    required this.email,
    required this.userName,
    required this.userImage,
  });

  AppUser.company({
    required this.userId,
    required this.email,
    required this.userName,
    required this.userImage,
    required this.company,
    required this.companyId,
  });
}
