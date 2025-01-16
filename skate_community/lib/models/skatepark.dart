// lib/models/skatepark.dart

class Skatepark {
  final String id;
  final String name;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final bool indoor;
  final bool? hasWc;
  final String lightedUntil;
  final String size;

  Skatepark({
    required this.id,
    required this.name,
    required this.locationName,
    this.latitude,
    this.longitude,
    required this.indoor,
    this.hasWc,
    required this.lightedUntil,
    required this.size,
  });
}

//   factory Skatepark.fromMap(Map<String, dynamic> map) {
//     return Skatepark(
//       skateparkid: map['id'] as String,
//       name: map['naam'] as String,
//       locationname: map['locatie'] as String,
//       latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
//       longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
//       indoor: map['indoor'] as bool,
//       haswc: map['has_toiletten'] as bool?,
//       lighteduntil: map['verlichting'] as String,
//       size: map['grootte'] as String,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': skateparkid,
//       'naam': name,
//       'locatie': locationname,
//       'latitude': latitude,
//       'longitude': longitude,
//       'indoor': indoor,
//       'has_toiletten': haswc,
//       'verlichting': lighteduntil,
//       'grootte': size,
//     };
//   }
// }
