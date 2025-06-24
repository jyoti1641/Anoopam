import 'dart:async';
import 'package:anoopam_mission/Views/Home/main_page.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/widgets/otp_digit_field.dart'; // Adjust path if needed
// You might need to add a package for animations, e.g., Lottie:
// import 'package:lottie/lottie.dart'; // Add lottie to your pubspec.yaml if you use it

class EditMobileNoScreen extends StatefulWidget {
  final String phoneNumber;
  final String? dialCode;

  const EditMobileNoScreen({
    super.key,
    required this.phoneNumber,
    this.dialCode,
  });

  @override
  State<EditMobileNoScreen> createState() => _EditMobileNoScreenState();
}

class _EditMobileNoScreenState extends State<EditMobileNoScreen> {
  // OTP input controllers
  final TextEditingController _otpDigit1Controller = TextEditingController();
  final TextEditingController _otpDigit2Controller = TextEditingController();
  final TextEditingController _otpDigit3Controller = TextEditingController();
  final TextEditingController _otpDigit4Controller = TextEditingController();

  // Focus nodes
  final FocusNode _otpDigit1Focus = FocusNode();
  final FocusNode _otpDigit2Focus = FocusNode();
  final FocusNode _otpDigit3Focus = FocusNode();
  final FocusNode _otpDigit4Focus = FocusNode();

  // Timer variables for "Request New OTP"
  Timer? _timer;
  int _start = 60; // Initial cooldown (e.g., 60 seconds)

  // Boolean to track if OTP is fully entered (for auto-verify behavior)
  bool _isOtpComplete = false; // Changed to be used

  @override
  void initState() {
    super.initState();
    // Start the timer for OTP resend cooldown
    startResendTimer();

    // Listen to all OTP digit controllers to determine if OTP is complete
    _otpDigit1Controller.addListener(_checkOtpCompletion);
    _otpDigit2Controller.addListener(_checkOtpCompletion);
    _otpDigit3Controller.addListener(_checkOtpCompletion);
    _otpDigit4Controller.addListener(_checkOtpCompletion);
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the resend timer
    _otpDigit1Controller.dispose();
    _otpDigit2Controller.dispose();
    _otpDigit3Controller.dispose();
    _otpDigit4Controller.dispose();
    _otpDigit1Focus.dispose();
    _otpDigit2Focus.dispose();
    _otpDigit3Focus.dispose();
    _otpDigit4Focus.dispose();
    super.dispose();
  }

  // New method to check if all OTP digits are entered
  void _checkOtpCompletion() {
    setState(() {
      _isOtpComplete = _otpDigit1Controller.text.isNotEmpty &&
          _otpDigit2Controller.text.isNotEmpty &&
          _otpDigit3Controller.text.isNotEmpty &&
          _otpDigit4Controller.text.isNotEmpty;
    });
    // Optional: Auto-verify if OTP is complete
    if (_isOtpComplete) {
      _verifyOtp();
    }
  }

  void startResendTimer() {
    setState(() {
      _start = 120; // Reset timer to 2 minutes (120 seconds)
    });

    _timer?.cancel(); // Cancel any existing timer before starting a new one
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> _verifyOtp() async {
    String otp = _otpDigit1Controller.text +
        _otpDigit2Controller.text +
        _otpDigit3Controller.text +
        _otpDigit4Controller.text;

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 OTP digits.')),
      );
      return; // Exit if OTP is not complete
    }

    print('OTP entered: $otp');

    // Simulate an API call for OTP verification
    // Replace this with your actual API call
    bool isOtpValid = await Future.delayed(const Duration(seconds: 2), () {
      // Example: Consider '1234' as a valid OTP
      return otp == '1234';
    });

    if (isOtpValid) {
      _showSuccessDialog();
      // Optionally navigate after a short delay or user interaction
      // Future.delayed(const Duration(seconds: 2), () {
      //   Navigator.of(context).pop(); // Go back or navigate to a new screen
      // });
    } else {
      _showFailureDialog();
      // Keep the user on the same page for correction
    }
  }

  void _requestNewOtp() {
    print('Resend OTP tapped, requesting new OTP...');
    // Implement actual API call to request a new OTP
    // On success, clear OTP fields and restart the timer
    _otpDigit1Controller.clear();
    _otpDigit2Controller.clear();
    _otpDigit3Controller.clear();
    _otpDigit4Controller.clear();
    _otpDigit1Focus.requestFocus(); // Focus on the first field

    startResendTimer();
    // Optionally show a confirmation message that a new OTP has been sent.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New OTP sent to your number.')),
    );
  }

  // Helper to format seconds into MM:SS
  String _formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String remainingSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$remainingSeconds";
  }

  // --- Dialog Widgets ---

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Tick Mark (using a simple checkmark for demonstration)
                // For a more advanced animation, consider using the 'lottie' package
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                // If using Lottie:
                // Lottie.asset(
                //   'assets/tick_animation.json', // Replace with your Lottie animation file
                //   width: 100,
                //   height: 100,
                //   repeat: false,
                // ),
                const SizedBox(height: 20),
                const Text(
                  "OTP Verified!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your mobile number has been successfully verified.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      // Navigate to the OTP Verification Screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(
                            // phoneNumber: widget.phoneNumber, // Pass the number from EditMobileNoScreen's widget property
                            // dialCode: widget.dialCode, // Pass the dial code
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3a57e8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Can dismiss by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Invalid OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "The One Time Password you entered is incorrect. Please try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      // Clear OTP fields and allow user to re-enter
                      _otpDigit1Controller.clear();
                      _otpDigit2Controller.clear();
                      _otpDigit3Controller.clear();
                      _otpDigit4Controller.clear();
                      _otpDigit1Focus.requestFocus(); // Focus on the first field
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      "TRY AGAIN",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "OTP Verification",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            color: Color(0xff000000),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Please enter One Time Password (OTP) sent to your Mobile Number for Verification",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 18,
                color: Color(0xff000000),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${widget.dialCode ?? ''} ${widget.phoneNumber}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    color: Color(0xff000000),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    print("Edit phone number tapped!");
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "EDIT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OtpDigitField(
                  controller: _otpDigit1Controller,
                  focusNode: _otpDigit1Focus,
                  autoFocus: true,
                  nextFocusNode: _otpDigit2Focus,
                ),
                OtpDigitField(
                  controller: _otpDigit2Controller,
                  focusNode: _otpDigit2Focus,
                  prevFocusNode: _otpDigit1Focus,
                  nextFocusNode: _otpDigit3Focus,
                ),
                OtpDigitField(
                  controller: _otpDigit3Controller,
                  focusNode: _otpDigit3Focus,
                  prevFocusNode: _otpDigit2Focus,
                  nextFocusNode: _otpDigit4Focus,
                ),
                OtpDigitField(
                  controller: _otpDigit4Controller,
                  focusNode: _otpDigit4Focus,
                  prevFocusNode: _otpDigit3Focus,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Timer and Resend OTP section ---
            GestureDetector(
              onTap: _start == 0 ? _requestNewOtp : null,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Haven't received a code? ",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: _start == 0
                          ? "Send again"
                          : "Send again in ${_formatDuration(_start)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        fontSize: 16,
                        color: _start == 0 ? Theme.of(context).primaryColor : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- End Timer and Resend OTP section ---

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: MaterialButton(
                onPressed: _verifyOtp,
                color: const Color(0xff3a57e8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textColor: Colors.white,
                child: const Text(
                  "VERIFY",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
