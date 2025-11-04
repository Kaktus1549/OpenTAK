import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 52.5,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.93),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          iconSize: 35,
          icon: SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/sos.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          onPressed: () {
            // Handle SOS button press
          },
        ),
      )
    );
  }
}