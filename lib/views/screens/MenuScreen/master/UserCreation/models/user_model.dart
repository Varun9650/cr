class AppUserMin {
  final int? id;
  final String? email;
  final String? fullName;
  final String? gender;
  final String? mobileNumber;
  final bool? isEmailVerified;

  AppUserMin({
    this.id,
    this.email,
    this.fullName,
    this.gender,
    this.mobileNumber,
    this.isEmailVerified,
  });

  factory AppUserMin.fromJson(Map<String, dynamic> json) {
    return AppUserMin(
      id: json['id'] ?? json['userId'],
      email: json['email'],
      fullName: json['fullName'] ?? json['fullname'] ?? json['name'],
      gender: json['gender'],
      mobileNumber: (json['mob_no'] ?? json['mobile'] ?? json['mobileNumber'])?.toString(),
      isEmailVerified: json['isemailverified'] ?? json['emailVerified'] ?? json['isEmailVerified'],
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'fullName': fullName,
      'gender': gender,
      'mob_no': mobileNumber == null ? null : int.tryParse(mobileNumber!),
    }..removeWhere((k, v) => v == null);
  }
} 