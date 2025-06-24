// lib/models/country.dart (or at the top of your file)
class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flagAsset; // Path to your flag asset
  final int? maxLength; // Added maxLength property

  Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flagAsset,
    this.maxLength, // Make it nullable if not all countries have a strict max length
  });
}