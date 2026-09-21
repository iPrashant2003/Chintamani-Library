class Branch {
  final String id;
  final String name;
  final String shortName;
  final String subtitle;
  final String address;
  final String mapUrl;
  final String phone;
  final String? email;
  final String openingHours;
  final int totalSeats;
  final int availableSeats;
  final int occupiedSeats;
  final String status; // "Open", "Closed"
  final String? image;

  const Branch({
    required this.id,
    required this.name,
    required this.shortName,
    required this.subtitle,
    required this.address,
    required this.mapUrl,
    required this.phone,
    this.email,
    this.openingHours = '06:00 AM – 11:00 PM',
    this.totalSeats = 180,
    this.availableSeats = 52,
    this.occupiedSeats = 128,
    this.status = 'Open',
    this.image,
  });

  double get occupancyPercent {
    if (totalSeats <= 0) return 0.0;
    return (occupiedSeats / totalSeats).clamp(0.0, 1.0);
  }

  factory Branch.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] as String? ?? '';
    final isMehdawal = rawName.toLowerCase().contains('mehdawal');

    final fallback = isMehdawal ? mehdawalBranch : khalilabadBranch;

    return Branch(
      id: json['id'] as String? ?? fallback.id,
      name: rawName.isNotEmpty ? rawName : fallback.name,
      shortName: json['shortName'] as String? ?? fallback.shortName,
      subtitle: json['subtitle'] as String? ?? fallback.subtitle,
      address: json['address'] as String? ?? fallback.address,
      mapUrl: json['mapUrl'] as String? ?? fallback.mapUrl,
      phone: json['phone'] as String? ?? fallback.phone,
      email: json['email'] as String? ?? fallback.email,
      openingHours: json['openingHours'] as String? ?? fallback.openingHours,
      totalSeats: (json['totalSeats'] as num?)?.toInt() ?? fallback.totalSeats,
      availableSeats: (json['availableSeats'] as num?)?.toInt() ?? fallback.availableSeats,
      occupiedSeats: (json['occupiedSeats'] as num?)?.toInt() ?? fallback.occupiedSeats,
      status: json['status'] as String? ?? fallback.status,
      image: json['image'] as String? ?? fallback.image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'subtitle': subtitle,
      'address': address,
      'mapUrl': mapUrl,
      'phone': phone,
      'email': email,
      'openingHours': openingHours,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'occupiedSeats': occupiedSeats,
      'status': status,
      'image': image,
    };
  }

  Branch copyWith({
    String? id,
    String? name,
    String? shortName,
    String? subtitle,
    String? address,
    String? mapUrl,
    String? phone,
    String? email,
    String? openingHours,
    int? totalSeats,
    int? availableSeats,
    int? occupiedSeats,
    String? status,
    String? image,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      subtitle: subtitle ?? this.subtitle,
      address: address ?? this.address,
      mapUrl: mapUrl ?? this.mapUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      openingHours: openingHours ?? this.openingHours,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      occupiedSeats: occupiedSeats ?? this.occupiedSeats,
      status: status ?? this.status,
      image: image ?? this.image,
    );
  }

  // ===========================================================================
  // THE TWO OFFICIAL CHINTA MANI LIBRARY BRANCHES
  // ===========================================================================
  static const Branch khalilabadBranch = Branch(
    id: 'chintamani-khalilabad',
    name: 'Chinta Mani Library',
    shortName: 'Khalilabad',
    subtitle: 'Khalilabad Branch',
    address: 'Main Road, Khalilabad, Sant Kabir Nagar, Uttar Pradesh 272175',
    mapUrl: 'https://maps.app.goo.gl/RjjdGmMsiEKkJn7F7',
    phone: '+91 9415919277',
    email: 'khalilabad@chintamanilibrary.com',
    openingHours: '06:00 AM – 11:00 PM (Daily)',
    totalSeats: 65,
    availableSeats: 15,
    occupiedSeats: 50,
    status: 'Open',
  );

  static const Branch mehdawalBranch = Branch(
    id: 'chintamani-mehdawal',
    name: 'Chinta Mani Digital Library',
    shortName: 'Mehdawal',
    subtitle: 'Mehdawal Branch',
    address: 'Station Road, Mehdawal, Sant Kabir Nagar, Uttar Pradesh 272202',
    mapUrl: 'https://maps.app.goo.gl/6snL6CTrmxak4zsa8',
    phone: '+91 9415919277',
    email: 'mehdawal@chintamanilibrary.com',
    openingHours: '06:00 AM – 11:00 PM (Daily)',
    totalSeats: 120,
    availableSeats: 34,
    occupiedSeats: 86,
    status: 'Open',
  );

  static const List<Branch> officialBranches = [
    khalilabadBranch,
    mehdawalBranch,
  ];

  static const Branch defaultBranch = khalilabadBranch;
  static const List<Branch> defaultBranches = officialBranches;
}
