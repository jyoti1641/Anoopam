import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For the pencil icon
import 'package:anoopam_mission/widgets/profile_input_field.dart'; // Import the new input field widget
import 'package:anoopam_mission/widgets/profile_dropdown_field.dart'; // Import the new dropdown field widget
import 'package:anoopam_mission/Views/Login/login_phone.dart';
import 'package:anoopam_mission/widgets/privacy_policy_btn.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatefulWidget {
  // Add a constructor to accept the phone number
  final String? phoneNumber;
  final String? dialCode;

  const ProfileScreen({
    super.key,
    this.phoneNumber,
    this.dialCode,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedGender; // For dropdown
  String? _selectedAgeGroup; // For dropdown
  File? _imageFile; // To store the selected image file

  // Local variable to hold the phone number for display
  late String _displayPhoneNumber;

  @override
  void initState() {
    super.initState();
    // Initialize the display phone number.
    // If a phone number is passed, use it. Otherwise, default to an empty string
    // or a placeholder if you want the user to enter it.
    _displayPhoneNumber = '';
    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      _displayPhoneNumber = '${widget.dialCode ?? '+91'} ${widget.phoneNumber}';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Optional: Show a brief confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image updated!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _saveProfile() {
    // Implement your save logic here
    print('First Name: ${_firstNameController.text}');
    print('Last Name: ${_lastNameController.text}');
    print('Email: ${_emailController.text}');
    print('Gender: $_selectedGender');
    print('Age Group: $_selectedAgeGroup');
    print(
        'Profile Image Path: ${_imageFile?.path}'); // Print image path if available
    print(
        'Registered Phone Number: $_displayPhoneNumber'); // Include the phone number

    // Show a SnackBar to confirm the save action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile saved successfully!'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('My Profile'.tr()),
        centerTitle: false,
        elevation: 1,
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture Section
            Stack(
              children: [
                InkWell(
                  // Added InkWell for ripple effect on tapping profile pic area
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(60),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        Colors.grey.shade900, // Lighter grey placeholder
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : null, // Display selected image
                    child: _imageFile == null
                        ? const Icon(
                            Icons.person,
                            size: 60, // Slightly smaller icon for better fit
                            color: Colors.white, // Grey icon for placeholder
                          )
                        : null, // Only show person icon if no image is selected
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    // Added InkWell for ripple effect on edit icon
                    onTap: _pickImage, // Call the image picker function
                    borderRadius: BorderRadius.circular(
                        18), // Match container's border radius
                    child: Container(
                      padding: const EdgeInsets.all(
                          8), // Increased padding for a larger touch target
                      decoration: BoxDecoration(
                        color: Colors.blue, // Edit icon background
                        borderRadius: BorderRadius.circular(
                            18), // Slightly larger border radius
                        border: Border.all(
                            color: Colors.white,
                            width: 2), // White border for contrast
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.pencil,
                        color: Colors.white,
                        size: 16, // Slightly smaller icon to fit padding
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Display the dynamic phone number here
            Text(
              _displayPhoneNumber.isNotEmpty
                  ? _displayPhoneNumber
                  : 'No phone number added'.tr(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _displayPhoneNumber.isNotEmpty
                        ? Theme.of(context).colorScheme.onBackground
                        : Theme.of(context).disabledColor,
                  ),
            ),
            // Option to add/edit phone number if it's empty
            if (_displayPhoneNumber.isEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen2(
                        phoneNumber: widget.phoneNumber,
                        dialCode: widget.dialCode,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Add Phone Number'.tr(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            const SizedBox(height: 16),

            // Input Fields
            ProfileInputField(
              controller: _firstNameController,
              hintText: 'First Name'.tr(),
            ),
            const SizedBox(height: 20),
            ProfileInputField(
              controller: _lastNameController,
              hintText: 'Last Name'.tr(),
            ),
            const SizedBox(height: 20),
            ProfileInputField(
              controller: _emailController,
              hintText: 'Email Address'.tr(),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),

            // Gender and Age Group Dropdowns
            Row(
              children: [
                Expanded(
                  child: ProfileDropdownField(
                    labelText: 'Gender'.tr(),
                    value: _selectedGender,
                    items: const ['Male', 'Female', 'Other'],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ProfileDropdownField(
                    labelText: 'Age Group'.tr(),
                    value: _selectedAgeGroup,
                    items: const ['< 18', '18-25', '26-35', '36-50', '> 50'],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAgeGroup = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32), // Increased space before button
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'SAVE PROFILE'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Distributes space evenly
              children: [
                const PrivacyPolicyButton(),
              ],
            ),
            const SizedBox(height: 32), // Space for bottom navigation bar
          ],
        ),
      ),
    );
  }
}
