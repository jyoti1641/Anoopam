import 'package:flutter/material.dart';

class VandanSahebjiSection extends StatefulWidget {
  const VandanSahebjiSection({super.key});

  @override
  State<VandanSahebjiSection> createState() => _VandanSahebjiSectionState();
}

class _VandanSahebjiSectionState extends State<VandanSahebjiSection> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Image(
                image: AssetImage('assets/icons/vandan_sahebji.png'),
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              const Text(
                'Vandan Sahebji',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
