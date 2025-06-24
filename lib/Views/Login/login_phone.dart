import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:anoopam_mission/models/country.dart';
import 'package:anoopam_mission/Views/Home/main_page.dart';
import 'package:anoopam_mission/Views/Login/otp_verification.dart';
import 'package:anoopam_mission/widgets/privacy_policy_btn.dart';
import 'package:anoopam_mission/Views/Login/login_email.dart';

class LoginScreen2 extends StatefulWidget {
  const LoginScreen2({super.key, String? phoneNumber, String? dialCode});

  @override
  State<LoginScreen2> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen2> {
  late final TextEditingController _phoneNumberController = TextEditingController();

  // State variable for the selected country
  Country? _selectedCountry;

  // Example list of countries with flag asset paths
  final List<Country> _countries = [
  Country(name: 'In', code: 'IN', dialCode: '+91', flagAsset: 'assets/flags/in.png', maxLength: 10), // India typically has 10 digits
  Country(name: 'US', code: 'US', dialCode: '+1', flagAsset: 'assets/flags/us.png', maxLength: 10), // US typically has 10 digits
  Country(name: 'UK', code: 'GB', dialCode: '+44', flagAsset: 'assets/flags/gb.png', maxLength: 10), // UK mobile numbers are typically 10 digits after 07
  Country(name: 'Ca', code: 'CA', dialCode: '+1', flagAsset: 'assets/flags/ca.png', maxLength: 10), // Canada typically has 10 digits
  Country(name: 'Au', code: 'AU', dialCode: '+61', flagAsset: 'assets/flags/au.png', maxLength: 9), // Australia mobile numbers are typically 9 digits after 04
  // Add more countries as needed, ensuring you have their flag assets and maxLength
];

  @override
  void initState() {
    super.initState();
    // Set India as the default selected country
    _selectedCountry = _countries.firstWhere((country) => country.code == 'IN');
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Logo/Icon
                const Image(
                  image: AssetImage('assets/logos/Mission.png'),
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8), // Spacing
                const Text(
                  "Login to Your Account",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 24,
                    color: Color(0xff3a57e8),
                  ),
                ),
                const SizedBox(height: 30), // Spacing
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sign In",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 24,
                      color: Color(0xff000000),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Spacing
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align items at the start of the cross axis
                  children: [
                    Expanded(
                      flex: 6, // Give the country dropdown less flex
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<Country>(
                            value: _selectedCountry,
                            hint: const Text('Select Country/Region'),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                              border: InputBorder.none,
                              labelText: "Country/Region",
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 18,
                                color: Color(0xff000000),
                              ),
                            ),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            onChanged: (Country? newValue) {
                              setState(() {
                                _selectedCountry = newValue;
                              });
                            },
                            items: _countries.map<DropdownMenuItem<Country>>((Country country) {
                              return DropdownMenuItem<Country>(
                                value: country,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      country.flagAsset,
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${country.name} (${country.dialCode})'),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // Spacing between the two fields
                    Expanded(
                      flex: 9, // Give the phone number field more flex
                      child: TextField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone, // Set keyboard type to phone
                        obscureText: false, // Phone number is usually not obscured
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 18,
                          color: Color(0xff000000),
                        ),
                        // ADDED: TextInputFormatters for length validation
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(_selectedCountry?.maxLength),
                          FilteringTextInputFormatter.digitsOnly, // Ensures only digits are entered
                        ],
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          labelText: "Phone number",
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          filled: true,
                          fillColor: const Color(0x00f2f2f3),
                          isDense: false,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          prefixIcon: const Icon(Icons.phone),
                          // prefixText: _selectedCountry?.dialCode ?? ' ',
                          // prefixStyle: const TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
                  child: Text(
                    'We\'ll call or text you to confirm your number. Standard messages and data rates may apply.',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: MaterialButton(
                        onPressed: () {
                          // You would typically handle phone number login logic here
                          print("Continue Button Tapped!");
                          print("Selected Country: ${_selectedCountry?.name} (${_selectedCountry?.dialCode})");
                          print("Phone Number: ${_phoneNumberController.text}");
                          // Navigate to the OTP Verification Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMobileNoScreen(
                                phoneNumber: _phoneNumberController.text,
                                dialCode: _selectedCountry?.dialCode,
                              ),
                            ),
                          );
                        },
                        color: const Color(0xff3a57e8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.all(16),
                        textColor: const Color(0xffffffff),
                        height: 40,
                        minWidth: 140,
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Spacing after "Or Continue with"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Color(0xff9e9e9e),
                          height: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Or Continue with",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Color(0xff9e9e9e),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16), // Spacing after "Or Continue with"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Email Button (now navigates to login_email.dart)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print("Email Button Tapped!");
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen1()), // Navigating to login_email.dart
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xffffffff),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: const Color(0xff9e9e9e), width: 1),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image(
                                image: AssetImage('assets/icons/Mail-96.png'),
                                height: 25,
                                width: 25,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                                child: Text(
                                  "Email",
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Color(0xff000000),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Spacing between buttons

                    // Google Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print("Google Button Tapped!");
                          // Add your navigation or action for the Google button here
                        },
                        child: Container(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xffffffff),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: const Color(0xff9e9e9e), width: 1),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image(
                                image: AssetImage('assets/icons/Google-96.png'),
                                height: 25,
                                width: 25,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                                child: Text(
                                  "Google",
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Color(0xff000000),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Spacing between buttons

                    // Apple Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print("Apple Button Tapped!");
                          // Add your navigation or action for the Apple button here
                        },
                        child: Container(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xffffffff),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: const Color(0xff9e9e9e), width: 1),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image(
                                image: AssetImage('assets/icons/Apple-96.png'),
                                height: 25,
                                width: 25,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                                child: Text(
                                  "Apple",
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Color(0xff000000),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32), // Spacing before privacy policy
                // Privacy Policy
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distributes space evenly
                  children: [
                    const PrivacyPolicyButton(),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the Home Screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign in as a Guest",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Colors.indigo, // A distinct color for a link
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Spacing at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
