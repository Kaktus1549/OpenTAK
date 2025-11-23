import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:opentak_app/pages/models/enums/_nav_status.dart';
import 'package:opentak_app/pages/settings.dart';



class ControlButtonsContainer extends StatelessWidget {
  final NavigationStates currentState;
  final void Function(NavigationStates)? navigationUpdate;

  const ControlButtonsContainer({super.key, required this.currentState, this.navigationUpdate});

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
              child: NavigationButton(
                currentState: currentState,
                navigationUpdate: navigationUpdate,
              ),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
      },
    );
  }
}

class NavigationButton extends StatefulWidget {
  final NavigationStates currentState;
  final void Function(NavigationStates)? navigationUpdate;
  const NavigationButton({super.key, required this.currentState, this.navigationUpdate});

  @override
  State<NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<NavigationButton> {
  late NavigationStates currentState;

  void _toggleNavigation() {
    setState(() {
      if (widget.navigationUpdate != null) {
        currentState = NavigationStates.values[(currentState.index + 1) % NavigationStates.values.length];
        widget.navigationUpdate!(currentState);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    currentState = widget.currentState;
  }

  @override
  Widget build(BuildContext context) {
    final asset = currentState == NavigationStates.centred
        ? 'assets/icons/centred.svg'
        : currentState == NavigationStates.decentred
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