import 'package:anoopam_mission/widgets/amrut_vachan_widget.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AmrutVachanSection extends StatefulWidget {
  const AmrutVachanSection({super.key});

  @override
  State<AmrutVachanSection> createState() => _AmrutVachanSectionState();
}

class _AmrutVachanSectionState extends State<AmrutVachanSection> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Image(
                image: AssetImage('assets/icons/amrutvachan.png'),
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              Text(
                'menu.amrutVachan'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.56,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    children: const [
                      SizedBox(
                        width: 320,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: AmrutVachanWidget(
                            title: "Amrut Vachan",
                            imagePath: "assets/images/person1.png",
                            text:
                                "Even if the atmosphere becomes impure, stressful, or chaotic, chanting mantras can purify it.",
                            textGujarati:
                                "ગમે એવું અશુદ્ધ વાતાવરણ ઊભું થયું હોય,\nમાથાકૂટ થઈ હોય, ગોટાળો થયો હોય,\nઅશાંત કરે, આનંદ જતો રહે એવું વાતાવરણ\nથયું હોય તો તે પણ મંત્રજાપથી શુદ્ધ થઈ જાય.",
                          ),
                        ),
                      ),
                      // const SizedBox(
                      //   width: 2,
                      // ),
                      SizedBox(
                        width: 320,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.0, left: 8),
                          child: AmrutVachanWidget(
                            title: "Amrut Vachan",
                            imagePath: "assets/images/person2.png",
                            text:
                                "Always stay positive in life because positive thinking is the greatest strength.",
                            textGujarati:
                                "જીવનમાં હંમેશાં સકારાત્મક રહો,\nકારણ કે સકારાત્મક વિચાર શક્તિ સૌથી મોટી શક્તિ છે.",
                          ),
                        ),
                      ),
                      // const SizedBox(
                      //   width: 2,
                      // ),
                      SizedBox(
                        width: 320,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: AmrutVachanWidget(
                            title: "Amrut Vachan",
                            imagePath: "assets/images/person3.png",
                            text:
                                "Peace is the source of inner joy; only a calm mind leads to a happy life.",
                            textGujarati:
                                "શાંતિ એ અંદરના આનંદનો સ્ત્રોત છે,\nમાત્ર મનની શાંતિથી જ સુખી જીવન મળી શકે છે.",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 5),
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: const WormEffect(
                      activeDotColor: Colors.orange,
                      dotColor: Colors.grey,
                      dotHeight: 10,
                      dotWidth: 10,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
