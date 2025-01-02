class Poster {
  Poster({
    required this.id,
    required this.userName,
    required this.normalizedUserName,
    required this.email,
    required this.normalizedEmail,
    required this.emailConfirmed,
    required this.passwordHash,
    required this.securityStamp,
    required this.concurrencyStamp,
    required this.phoneNumber,
    required this.phoneNumberConfirmed,
    required this.twoFactorEnabled,
    required this.lockoutEnd,
    required this.lockoutEnabled,
    required this.accessFailedCount,
    required this.initials,
    required this.totpSecretKey,
    required this.avatarUrl,
  });

  final String? id;
  final String? userName;
  final String? normalizedUserName;
  final String? email;
  final String? normalizedEmail;
  final bool? emailConfirmed;
  final String? passwordHash;
  final String? securityStamp;
  final String? concurrencyStamp;
  final String? phoneNumber;
  final bool? phoneNumberConfirmed;
  final bool? twoFactorEnabled;
  final DateTime? lockoutEnd;
  final bool? lockoutEnabled;
  final num? accessFailedCount;
  final String? initials;
  final String? totpSecretKey;
  final String? avatarUrl;

  factory Poster.fromJson(Map<String, dynamic> json){
    return Poster(
      id: json["id"],
      userName: json["userName"],
      normalizedUserName: json["normalizedUserName"],
      email: json["email"],
      normalizedEmail: json["normalizedEmail"],
      emailConfirmed: json["emailConfirmed"],
      passwordHash: json["passwordHash"],
      securityStamp: json["securityStamp"],
      concurrencyStamp: json["concurrencyStamp"],
      phoneNumber: json["phoneNumber"],
      phoneNumberConfirmed: json["phoneNumberConfirmed"],
      twoFactorEnabled: json["twoFactorEnabled"],
      lockoutEnd: DateTime.tryParse(json["lockoutEnd"] ?? ""),
      lockoutEnabled: json["lockoutEnabled"],
      accessFailedCount: json["accessFailedCount"],
      initials: json["initials"],
      totpSecretKey: json["totpSecretKey"],
      avatarUrl: json["avatarUrl"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userName": userName,
    "normalizedUserName": normalizedUserName,
    "email": email,
    "normalizedEmail": normalizedEmail,
    "emailConfirmed": emailConfirmed,
    "passwordHash": passwordHash,
    "securityStamp": securityStamp,
    "concurrencyStamp": concurrencyStamp,
    "phoneNumber": phoneNumber,
    "phoneNumberConfirmed": phoneNumberConfirmed,
    "twoFactorEnabled": twoFactorEnabled,
    "lockoutEnd": lockoutEnd?.toIso8601String(),
    "lockoutEnabled": lockoutEnabled,
    "accessFailedCount": accessFailedCount,
    "initials": initials,
    "totpSecretKey": totpSecretKey,
    "avatarUrl": avatarUrl,
  };

}