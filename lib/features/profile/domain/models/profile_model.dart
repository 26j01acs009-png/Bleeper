class ProfileModel {
  final String id;
  final String? email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? location;
  final String? website;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.location,
    this.website,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      gender: json['gender'],
      location: json['location'],
      website: json['website'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'display_name': displayName,
      'bio': bio,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'gender': gender,
      'location': location,
      'website': website,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
