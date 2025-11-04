import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class ControlButtonsContainer extends StatelessWidget {
  const ControlButtonsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 105,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.93),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SettingsButton(),
            ),
          ),

          const SizedBox(
            width: 40,
            child: Divider(
              color: Color(0xFFD3D3D3),
              thickness: 0.5,
              height: 0,
            ),
          ),

          Expanded(
            child: Center(
              child: NavigationButton(),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      iconSize: 35,
      icon: Container(
        padding: const EdgeInsets.only(left: 0.65),
        child: SizedBox(
          width: 35,
          height: 35,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/settings.svg',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
      onPressed: () {
        // Handle settings button press
      },
    );
  }
}

class NavigationButton extends StatefulWidget {
  const NavigationButton({super.key});

  @override
  State<NavigationButton> createState() => _NavigationButtonState();
}

enum NavigationStates{
  decentred,
  centred,
  heading,
}

class _NavigationButtonState extends State<NavigationButton> {
  NavigationStates _currentState = NavigationStates.decentred;

  void _toggleNavigation() {
    setState(() {
      _currentState = NavigationStates.values[(_currentState.index + 1) % NavigationStates.values.length];
    });
  }

  @override
  void initState() {
    super.initState();
    _currentState = NavigationStates.decentred;
  }

  @override
  Widget build(BuildContext context) {
    final asset = _currentState == NavigationStates.centred
        ? 'assets/icons/centred.svg'
        : _currentState == NavigationStates.decentred
            ? 'assets/icons/decentred.svg'
            : 'assets/icons/compass.svg';

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      iconSize: 35,
      icon: SizedBox(
        width: 35,
        height: 35,
        child: Center(
          child: SvgPicture.asset(
            asset,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
      ),
      onPressed: _toggleNavigation,
    );
  }
}